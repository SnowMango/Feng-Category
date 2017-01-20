//
//  CustomViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/19.
//
//

#import "CustomViewController.h"
#import "ImageResultViewController.h"
#import <AssertMacros.h>

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@interface CustomViewController ()
{
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
}
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *changeCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *stillImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;

@end

@implementation CustomViewController

- (void)dealloc
{
    [self teardownCapture];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
#if !TARGET_OS_SIMULATOR
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    [self setupCapture];
    [self startRunning];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientationDeviceChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didOrientationDeviceChange:(NSNotification *)noti
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
//    CGAffineTransform transform ;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            
            [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            [self.previewLayer  setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self.previewLayer  setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self.previewLayer  setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
            break;
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        default: break; // leave the layer in its last known orientation
    }

}


- (BOOL)shouldAutorotate
{
    return ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait);
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startRunning];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopRunning];
}

- (IBAction)flashlight:(id)sender
{
    if (!self.videoInput) {
        return;
    }
    BOOL flash = [self deviceFlash];
    if ([self setDeviceFlash:!flash]) {
        [self.flashBtn setTitle:flash?@"开":@"关" forState:UIControlStateNormal];
    }
}

- (void)teardownCapture
{
    self.stillImageOutput = nil;
    self.videoInput = nil;
    self.previewLayer  = nil;
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
    self.session = nil;
}
- (IBAction)switchBtn:(UIButton *)sender {
    [self switchCamera];
}

#pragma mark - 初始化DIY相机
- (void)setupCapture
{
    //session
    AVCaptureSession * session = [AVCaptureSession new];
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//        [session setSessionPreset:AVCaptureSessionPreset1280x720];
//    else
//        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    self.session = session;

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    device.torchMode = AVCaptureTorchModeAuto;
    device.flashMode = AVCaptureFlashModeAuto;
    [device unlockForConfiguration];
    NSError *error;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    effectiveScale = 0;
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    [self.flashBtn setTitle:[self deviceFlash]?@"开":@"关" forState:UIControlStateNormal];
    self.stillImageOutput = [AVCaptureStillImageOutput new];
    if ( [self.session canAddOutput:self.stillImageOutput] ){
        self.stillImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        [self.session addOutput:self.stillImageOutput];
    }
    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    self.previewLayer.frame = rootLayer.bounds;
    [rootLayer addSublayer:self.previewLayer];
}

- (void)startRunning
{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}
- (void)stopRunning
{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

#pragma mark - AVCaptureVideoOrientation 方向
-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result++;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result--;
    return result;
}

#pragma mark - 拍照
- (IBAction)takePicture
{
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    stillImageConnection.videoOrientation= avcaptureOrientation;
    stillImageConnection.videoScaleAndCropFactor = effectiveScale;
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return ;
        }
        NSData *jpegData =[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,
//                                                                    imageDataSampleBuffer,
//                                                                    kCMAttachmentMode_ShouldPropagate);
//        NSDictionary *attachmentsDic = (__bridge NSDictionary *)attachments;
//        NSLog(@"attachmentsDic= %@",attachmentsDic);
        UIImage *image = [UIImage imageWithData:jpegData];
        [self performSegueWithIdentifier:@"customImage" sender:image];
    }];
}
#pragma mark - 切换摄像头
-(void)switchCamera
{
    AVCaptureDevicePosition desiredPosition = self.videoInput.device.position;
    if (desiredPosition) {
        desiredPosition = (desiredPosition - 1)? 1 : 2;
    }else{
        desiredPosition = AVCaptureDevicePositionBack;
    }
    
    NSArray *deices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *deivce in deices) {
        if (deivce.position == desiredPosition) {
            [self.session beginConfiguration];
            self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:deivce error:nil];
            for (AVCaptureInput *oldInput in self.session.inputs) {
                [self.session removeInput:oldInput];
            }
            if ([self.session canAddInput:self.videoInput]) {
                [self.session addInput:self.videoInput];
            }
            [self.session commitConfiguration];
            break;
        }
    }
}

#pragma mark - 手势变焦

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        beginGestureScale = effectiveScale;
    }
    return YES;
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    effectiveScale = beginGestureScale * recognizer.scale;
    if (effectiveScale < 1.0)
        effectiveScale = 1.0;
    CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
    if (effectiveScale > maxScaleAndCropFactor)
        effectiveScale = maxScaleAndCropFactor;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
    [CATransaction commit];
}


#pragma mark - flashlight 闪光灯
- (BOOL)setDeviceFlash:(AVCaptureFlashMode)mode
{
    AVCaptureDevice *device = self.videoInput.device;
    if ([device lockForConfiguration:nil]) {
        device.torchMode = (NSInteger)mode;
        device.flashMode = mode;
        [device unlockForConfiguration];
        return YES;
    }
    return NO;
}


-(AVCaptureFlashMode)deviceFlash
{
    return self.videoInput.device.flashMode;
}
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"customImage"]) {
        ImageResultViewController *vc = segue.destinationViewController;
        vc.imageInfo = sender;
    }
    
}

@end
