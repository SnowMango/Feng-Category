//
//  ToolViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/17.
//
//

#import "ToolViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ToolViewController ()

@end

@implementation ToolViewController
- (IBAction)flashlight:(UIButton *)sender {
    sender.selected = !sender.selected;
#if !TARGET_OS_SIMULATOR
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch] && [device hasFlash]){
        
        [device lockForConfiguration:nil];
        if (sender.selected) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
#else 
    NSLog(@"This is a simulator");
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
