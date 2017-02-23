//
//  PlayerViewController.m
//  VideoDemo
//
//  Created by 郑丰 on 2017/2/17.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "P2PTCPClient.h"
#import "P2PUDPClient.h"
#import "H264Decoder.h"


@interface PlayerView : UIView<P2PUDPClientUpdate>

@property (nonatomic, strong) P2PUDPClient* udp;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *videoLayer;

@property (nonatomic, strong) H264Decoder*decoder;

@property (nonatomic, weak) UITextView* info;

@end

@implementation PlayerView
- (void)dealloc{
    self.udp = nil;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        
        
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.udp = [P2PUDPClient new];
    self.udp.delegete = self;
    self.decoder = [H264Decoder new];

    self.videoLayer = [[AVSampleBufferDisplayLayer alloc] init];
    self.videoLayer.bounds = self.bounds;
    self.videoLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.videoLayer.backgroundColor = [[UIColor blackColor] CGColor];
    
    // connecting the videolayer with the view
    
    [[self layer] addSublayer:_videoLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.videoLayer.bounds = self.bounds;
    self.videoLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)udpClient:(P2PUDPClient*)client refreshVideoData:(NSData *)data
{
    /*
     CVPixelBufferRef PixelBuffer= [self.decoder deCompressedCMSampleBufferWithData:data];
     if (PixelBuffer) {
     [self dispatchPixelBuffer:PixelBuffer];
     }
     */
    CMSampleBufferRef sampleBuffer = [self.decoder sampleBufferWithData:data];
    [self enqueueSampleBuffer:sampleBuffer toLayer:self.videoLayer];
    if (sampleBuffer)
        CFRelease(sampleBuffer);
    NSString *text = self.info.text;
    NSString *newtext = [NSString stringWithFormat:@"%@\n video data size=%@",text,@(data.length)];
    self.info.text = newtext;
    [self.info scrollRangeToVisible:NSMakeRange(text.length, newtext.length - text.length)];
}

- (void)udpClient:(P2PUDPClient*)client refreshAudioData:(NSData *)data
{
    CMSampleBufferRef sampleBuffer = [self.decoder sampleBufferWithData:data];
    [self enqueueSampleBuffer:sampleBuffer toLayer:self.videoLayer];
    if (sampleBuffer)
        CFRelease(sampleBuffer);
    NSString *text = self.info.text;
    NSString *newtext = [NSString stringWithFormat:@"%@\n audio data size=%@",text,@(data.length)];
    self.info.text = newtext;
    [self.info scrollRangeToVisible:NSMakeRange(text.length, newtext.length - text.length)];
}


- (void)dispatchPixelBuffer:(CVPixelBufferRef) pixelBuffer
{
    if (!pixelBuffer){
        return;
    }
    //不设置具体时间信息
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    CFRelease(pixelBuffer);
    CFRelease(videoInfo);
    
    [self enqueueSampleBuffer:sampleBuffer toLayer:self.videoLayer];
    CFRelease(sampleBuffer);
}

- (void)enqueueSampleBuffer:(CMSampleBufferRef) sampleBuffer toLayer:(AVSampleBufferDisplayLayer*) layer
{
    if (sampleBuffer){
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
        
        CFRetain(sampleBuffer);
        if (layer.isReadyForMoreMediaData) {
            [layer enqueueSampleBuffer:sampleBuffer];
        }else{
            NSLog(@"no ready");
        }
        CFRelease(sampleBuffer);
        if (layer.status == AVQueuedSampleBufferRenderingStatusFailed){
            NSLog(@"ERROR: %@", layer.error);
        }
    }else{
        NSLog(@"ignore null samplebuffer");
    }  
}

- (void)enqueueAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer toLayer:(AVSampleBufferDisplayLayer*) layer
{
    if (sampleBuffer){
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DoNotDisplay, kCFBooleanTrue);
        
        CFRetain(sampleBuffer);
        if (layer.isReadyForMoreMediaData) {
            [layer enqueueSampleBuffer:sampleBuffer];
        }else{
            NSLog(@"no ready");
        }
        CFRelease(sampleBuffer);
        if (layer.status == AVQueuedSampleBufferRenderingStatusFailed){
            NSLog(@"ERROR: %@", layer.error);
        }
    }else{
        NSLog(@"ignore null samplebuffer");
    }
}


@end


@interface PlayerViewController ()
@property (nonatomic, strong) P2PTCPClient* tcp;
@property (weak, nonatomic) IBOutlet UITextView *logInfo;
@property (weak, nonatomic) IBOutlet PlayerView *playView;
@property (weak, nonatomic) IBOutlet UIButton *controlBtn;

@end

@implementation PlayerViewController
- (void)dealloc{
    self.tcp = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.playView.info = self.logInfo;
    self.tcp = [P2PTCPClient new];
    self.tcp.socketHost = self.ip;
}

- (IBAction)controlPlayer:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.tcp dissonnect];
    }else{
        self.tcp.socketHost = self.ip;
    }
}


@end
