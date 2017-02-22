//
//  LiveViewController.m
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/17.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "LiveViewController.h"
#import <AVFoundation/AVFoundation.h>

#import <VideoToolbox/VideoToolbox.h>
#import "P2PUDPSever.h"
#import "P2PTCPSever.h"
#import "VideoToolboxPlus.h"

@interface LiveViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,VTPCompressionSessionDelegate>
{
    VTPCompressionSession *_encodeSesion;
    dispatch_queue_t _encodeQueue;
}

@property (nonatomic, strong)AVCaptureSession           *videoCaptureSession;
@property (nonatomic, strong) P2PUDPSever *upd;
@property (nonatomic, strong) P2PTCPSever *tcp;
@end

@implementation LiveViewController
- (void)dealloc{
    self.tcp = nil;
    self.upd = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _encodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self initVideoCaptrue];
    self.upd = [P2PUDPSever new];
    self.tcp = [P2PTCPSever new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self start];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stop];
}

- (void)start
{
    [self startEncodeSession:480 height:640 framerate:25 bitrate:640*1000];
    [self.videoCaptureSession startRunning];// 开始录像
}

- (IBAction)stop
{
    [self.videoCaptureSession stopRunning];
    [self stopEncodeSession];
}

#pragma mark - camera
#pragma mark - video capture output delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [self encodeFrame:sampleBuffer];
    
}

- (void)initVideoCaptrue
{
    self.videoCaptureSession = [[AVCaptureSession alloc] init];
    
    // 设置录像分辨率
    [self.videoCaptureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"No Video device found");
        return;
    }
    
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    if ([self.videoCaptureSession canAddInput:inputDevice]) {
        NSLog(@"add video input to video session: %@", inputDevice);
        [self.videoCaptureSession addInput:inputDevice];
    }
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    /*  support pixel format : 420v, 420f, BGRA */
    
    dataOutput.videoSettings =
    @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    if ([self.videoCaptureSession canAddOutput:dataOutput]) {
        NSLog(@"add video output to video session: %@", dataOutput);
        [self.videoCaptureSession addOutput:dataOutput];
    }
    
    // 设置采集图像的方向,ps:不设置方向,采集回来的图形会是旋转90度的
    AVCaptureConnection *connection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.videoCaptureSession commitConfiguration];
    
    // 添加预览
    CGRect frame = self.view.frame;
    frame.size.height -= 50;
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoCaptureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:frame];
    [self.view.layer addSublayer:previewLayer];
    
    // 摄像头采集queue
    dispatch_queue_t queue = dispatch_queue_create("VideoCaptureQueue", DISPATCH_QUEUE_SERIAL);
    [dataOutput setSampleBufferDelegate:self queue:queue]; // 摄像头数据输出delegate
}


#pragma mark - videotoolbox methods
- (int)startEncodeSession:(int)width height:(int)height framerate:(int)fps bitrate:(int)bt
{
    _encodeSesion = [[VTPCompressionSession alloc] initWithWidth:width height:height codec:kCMVideoCodecType_H264 error:nil];
    
    [_encodeSesion setDelegate:self queue:_encodeQueue];
    // 设置实时编码输出，降低编码延迟
    [_encodeSesion setValue:@(YES) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_RealTime error:nil];
    // h264 profile, 直播一般使用baseline，可减少由于b帧带来的延时
    [_encodeSesion setValue:(__bridge NSString*)kVTProfileLevel_H264_Baseline_AutoLevel forProperty:(__bridge NSString*)kVTCompressionPropertyKey_ProfileLevel error:nil];
    
    // 设置编码码率(比特率)
     // bps
    [_encodeSesion setValue:@(bt) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_AverageBitRate error:nil];
    // Bps
    [_encodeSesion setValue:@[@(bt*2/8), @1] forProperty:(__bridge NSString*)kVTCompressionPropertyKey_DataRateLimits error:nil];
    
    // 设置关键帧间隔，即gop size
    [_encodeSesion setValue:@(fps*2) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_MaxKeyFrameInterval error:nil];
    // 设置帧率，只用于初始化session，不是实际FPS
    [_encodeSesion setValue:@(fps) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_ExpectedFrameRate error:nil];
    
    // 开始编码
    [_encodeSesion prepare];
    return 0;
}

// 编码一帧图像，使用queue，防止阻塞系统摄像头采集线程
- (void) encodeFrame:(CMSampleBufferRef )sampleBuffer
{
    
    [_encodeSesion encodeSampleBuffer:sampleBuffer forceKeyframe:NO];
}

- (void) stopEncodeSession
{
    _encodeSesion = nil;
}

- (void)videoCompressionSession:(VTPCompressionSession *)compressionSession didEncodeSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self handleH264:sampleBuffer];
}

- (void)handleH264:(CMSampleBufferRef )sampleBuffer{
    // 判断当前帧是否为关键帧
    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
    
    // 获取sps & pps数据
    if (keyframe)
    {
        size_t spsSize, spsCount;
        size_t ppsSize, ppsCount;
        
        const uint8_t *spsData, *ppsData;
        
        CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
        OSStatus err0 = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 0, &spsData, &spsSize, &spsCount, 0 );
        OSStatus err1 = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(formatDesc, 1, &ppsData, &ppsSize, &ppsCount, 0 );
        
        if (err0==noErr && err1==noErr)
        {
            
            [self sendData:[self naluH264Data:(void *)spsData length:spsSize]];
            [self sendData:[self naluH264Data:(void *)ppsData length:ppsSize]];
//            NSLog(@"got sps/pps data. Length: sps=%zu, pps=%zu", spsSize, ppsSize);
        }
    }
    
    size_t lengthAtOffset, totalLength;
    char *data;
    
    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    OSStatus error = CMBlockBufferGetDataPointer(dataBuffer, 0, &lengthAtOffset, &totalLength, &data);
    
    if (error == noErr) {
        size_t offset = 0;
        const int lengthInfoSize = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
        // 循环获取nalu数据
        while (offset < totalLength - lengthInfoSize) {
            uint32_t naluLength = 0;
            memcpy(&naluLength, data + offset, lengthInfoSize); // 获取nalu的长度，
            
            // 大端模式转化为系统端模式
            naluLength = CFSwapInt32BigToHost(naluLength);

            // 保存nalu数据到文件
            [self sendData:[self naluH264Data:data+offset+lengthInfoSize length:naluLength]];
            
            // 读取下一个nalu，一次回调可能包含多个nalu
            offset += lengthInfoSize + naluLength;
        }
    }
}


- (void)sendData:(NSData *)h264
{
    NSArray * sendIP =[self.tcp allContentHost];
    [self.upd sendMsg:h264 withHosts:sendIP];
}

- (NSData *)naluH264Data:(void*)data length:(size_t)length
{
    // 添加4字节的 h264 协议 start code
    const Byte bytes[] = "\x00\x00\x00\x01";
    
    NSMutableData * nalu = [NSMutableData dataWithBytes:bytes length:sizeof(Byte)*4];
    [nalu appendBytes:data length:length];
    return nalu;
}

@end
