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
#import "AAPLEAGLLayer.h"

@interface PlayerView : UIView<P2PUDPClientUpdate>
{
    AAPLEAGLLayer *_glLayer;
}
@property (nonatomic, strong) P2PUDPClient* udp;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *videoLayer;

@property (nonatomic, strong) H264Decoder*decoder;

//@property (nonatomic, weak) IBOutlet UIImageView *showView;
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
    self.videoLayer.backgroundColor = [[UIColor greenColor] CGColor];
    
    //set Timebase
       
    // connecting the videolayer with the view
    
    [[self layer] addSublayer:_videoLayer];
}

- (void)udpClient:(P2PUDPClient*)client refreshData:(NSData *)data
{
//    NSLog(@" length=%@", @(data.length));
   CMSampleBufferRef sampleBuffer= [self.decoder decode:data];
    
    size_t length = CMSampleBufferGetTotalSampleSize(sampleBuffer);
    NSLog( @"sampleBuffer length= %@", @(length));
    if (sampleBuffer) {
        [_videoLayer enqueueSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
    }
}

@end


@interface PlayerViewController ()
@property (nonatomic, strong) P2PTCPClient* tcp;

@end

@implementation PlayerViewController
- (void)dealloc{
//    self.tcp = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tcp = [P2PTCPClient new];
//    self.tcp.socketHost = self.ip;
}

@end
