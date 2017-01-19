//
//  CustomViewController.h
//  DemoDev
//
//  Created by 郑丰 on 2017/1/19.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface CustomViewController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    IBOutlet UIView *previewView;
    IBOutlet UISegmentedControl *camerasControl;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureStillImageOutput *stillImageOutput;
    
    BOOL detectFaces;
    dispatch_queue_t videoDataOutputQueue;
    UIView *flashView;
    
    UIImage *square;
    
    BOOL isUsingFrontFacingCamera;
    CIDetector *faceDetector;
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
}

@end
