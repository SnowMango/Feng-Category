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

#import <AACAudioTool/AACAudioTool.h>

@interface LiveViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,VTPCompressionSessionDelegate,AACEncoderDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
{
    VTPCompressionSession *_h264EncoderSesion;
    AACEncoder *_aacEncoder;
    dispatch_queue_t _encodeQueue;
}

@property (nonatomic, strong)AVCaptureSession           *videoCaptureSession;
@property (nonatomic)AVCaptureConnection *connection;
//音频设备输入
@property(nonatomic,strong)AVCaptureDeviceInput *audioInputDevice;
@property(nonatomic,strong)AVCaptureAudioDataOutput *audioDataOutput;

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

- (void)stopEncodeSession
{
    _h264EncoderSesion = nil;
    _aacEncoder = nil;
}

#pragma mark - camera
#pragma mark - video capture output delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.connection == connection) {
        [self encodeFrame:sampleBuffer];
    }else{
        [_aacEncoder encodeSampleBuffer:sampleBuffer];
    }
}

#pragma mark - 初始化设备
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
    //设置音频
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.audioInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc]init];
    if ([self.videoCaptureSession canAddInput:self.audioInputDevice]) {
        
        [self.videoCaptureSession addInput:self.audioInputDevice];
    }
    if ([self.videoCaptureSession canAddOutput:self.audioDataOutput]) {
        [self.videoCaptureSession addOutput:self.audioDataOutput];
    }

    
    // 设置采集图像的方向,ps:不设置方向,采集回来的图形会是旋转90度的
    AVCaptureConnection *connection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    [self.videoCaptureSession commitConfiguration];
    self.connection = connection;
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
    
    [self.audioDataOutput setSampleBufferDelegate:self queue:queue];
}

#pragma mark - AACEncode
- (void)startAACEncoderSession
{
    _aacEncoder = [[AACEncoder alloc] init];
    _aacEncoder.delegate = self;
    _aacEncoder.delegateQueue = _encodeQueue;
}
//AACEncoderDelegate
- (void)audioCompressionSession:(AACEncoder *)encoder didEncoderAACData:(NSData*)aacData
{
    [self sendAACData:aacData];
}

#pragma mark - videotoolbox methods
- (int)startEncodeSession:(int)width height:(int)height framerate:(int)fps bitrate:(int)bt
{
    [self startAACEncoderSession];
    _h264EncoderSesion = [[VTPCompressionSession alloc] initWithWidth:width height:height codec:kCMVideoCodecType_H264 error:nil];
    
    [_h264EncoderSesion setDelegate:self queue:_encodeQueue];
    // 设置实时编码输出，降低编码延迟
    [_h264EncoderSesion setValue:@(YES) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_RealTime error:nil];
    // h264 profile, 直播一般使用baseline，可减少由于b帧带来的延时
    [_h264EncoderSesion setValue:(__bridge NSString*)kVTProfileLevel_H264_Baseline_AutoLevel forProperty:(__bridge NSString*)kVTCompressionPropertyKey_ProfileLevel error:nil];
    
    // 设置编码码率(比特率)
     // bps
    [_h264EncoderSesion setValue:@(bt) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_AverageBitRate error:nil];
    // Bps
    [_h264EncoderSesion setValue:@[@(bt*2/8), @1] forProperty:(__bridge NSString*)kVTCompressionPropertyKey_DataRateLimits error:nil];
    
    // 设置关键帧间隔，即gop size
    [_h264EncoderSesion setValue:@(fps*2) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_MaxKeyFrameInterval error:nil];
    // 设置帧率，只用于初始化session，不是实际FPS
    [_h264EncoderSesion setValue:@(fps) forProperty:(__bridge NSString*)kVTCompressionPropertyKey_ExpectedFrameRate error:nil];
    
    // 开始编码
    [_h264EncoderSesion prepare];
    return 0;
}



#pragma mark - video h264 编码
- (void)encodeFrame:(CMSampleBufferRef )sampleBuffer
{
    [_h264EncoderSesion encodeSampleBuffer:sampleBuffer forceKeyframe:NO];
}

// VTPCompressionSessionDelegate
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
            
            [self sendH246Data:[self naluH264Data:(void *)spsData length:spsSize]];
            [self sendH246Data:[self naluH264Data:(void *)ppsData length:ppsSize]];
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
            [self sendH246Data:[self naluH264Data:data+offset+lengthInfoSize length:naluLength]];
            
            // 读取下一个nalu，一次回调可能包含多个nalu
            offset += lengthInfoSize + naluLength;
        }
    }
}

//h264 协议 start code
- (NSData *)naluH264Data:(void*)data length:(size_t)length
{
    // 添加4字节的 h264 协议 start code
    const Byte bytes[] = "\x00\x00\x00\x01";
    
    NSMutableData * nalu = [NSMutableData dataWithBytes:bytes length:sizeof(Byte)*4];
    [nalu appendBytes:data length:length];
    return nalu;
}

#pragma mark - 发送数据
- (void)sendData:(NSData *)data
{
    NSArray * sendIP =[self.tcp allContentHost];
    [self.upd sendMsg:data withHosts:sendIP];
}

#define Header_length 1
- (void)sendAACData:(NSData*)aacData
{
    Byte bytes[Header_length] = {'A'};
    NSMutableData * data = [NSMutableData dataWithBytes:bytes length:sizeof(Byte)*Header_length];
    [data appendData:aacData];
    [self sendData:data];
}

- (void)sendH246Data:(NSData*)h264Data
{
    Byte bytes[Header_length] = {'H'};
    NSMutableData * data = [NSMutableData dataWithBytes:bytes length:sizeof(Byte)*Header_length];
    [data appendData:h264Data];
    [self sendData:data];
}


@end
