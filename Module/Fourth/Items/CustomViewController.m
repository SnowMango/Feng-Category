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

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180.0;};
static CGContextRef CreateCGBitmapContextForSize(CGSize size);
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow = (size.width * 4);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
                                     size.width,
                                     size.height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    CGContextSetAllowsAntialiasing(context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}

@interface CustomViewController ()
{
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
    UIDeviceOrientation deviceOrientation;
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

    if (orientation == UIDeviceOrientationPortrait) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
        self.previewLayer.frame = self.previewView.bounds;
        deviceOrientation = orientation;
    }else if (UIDeviceOrientationIsLandscape(orientation)){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        deviceOrientation = orientation;
        NSInteger angle = 180*orientation-630;
        [self.previewLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(angle))];
            self.previewLayer.frame = self.previewView.bounds;
    }
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self startRunning];
    [self didOrientationDeviceChange:nil];
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
    //画质
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
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
    effectiveScale = 1;
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
    UIDeviceOrientation curDeviceOrientation = deviceOrientation;
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    stillImageConnection.videoOrientation= avcaptureOrientation;
    stillImageConnection.videoScaleAndCropFactor = effectiveScale;
    BOOL isFront = self.videoInput.device.position == AVCaptureDevicePositionFront;
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
        image = [self newSquareOverlayedImageForCGImage:image.CGImage withOrientation:curDeviceOrientation frontFacing:isFront];
        [self performSegueWithIdentifier:@"customImage" sender:image];
    }];
}
/* 修正相机图片的方向 */
- (UIImage*)newSquareOverlayedImageForCGImage:(CGImageRef)        backgroundImage
                                 withOrientation:(UIDeviceOrientation)orientation
                                     frontFacing:(BOOL)isFrontFacing
{
    CGImageRef returnImage = NULL;
    CGRect backgroundImageRect = CGRectMake(0., 0., CGImageGetWidth(backgroundImage), CGImageGetHeight(backgroundImage));
    CGContextRef bitmapContext = CreateCGBitmapContextForSize(backgroundImageRect.size);
    CGContextClearRect(bitmapContext, backgroundImageRect);
    CGContextDrawImage(bitmapContext, backgroundImageRect, backgroundImage);
    CGFloat rotationDegrees = 0.;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            rotationDegrees = 90.;
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (isFrontFacing) rotationDegrees = 180.;
            else rotationDegrees = 0.;
            break;
        case UIDeviceOrientationLandscapeRight:
            if (isFrontFacing) rotationDegrees = 0.;
            else rotationDegrees = 180.;
            break;

        default:break; // leave the layer in its last known orientation
    }

    returnImage = CGBitmapContextCreateImage(bitmapContext);
    
    CGContextRelease (bitmapContext);
    UIImage *newimage = [UIImage imageWithCGImage:returnImage];
    newimage = [self imageRotatedByDegrees:rotationDegrees image:newimage];
    return newimage;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees image:(UIImage *)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;

    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
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
    if (device.position == AVCaptureDevicePositionBack&&[device lockForConfiguration:nil]) {
        device.torchMode = (NSInteger)mode;
        [device unlockForConfiguration];
        return YES;
    }
    return NO;
}


-(AVCaptureFlashMode)deviceFlash
{
    return self.videoInput.device.torchMode;
}
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"customImage"]) {
        ImageResultViewController *vc = segue.destinationViewController;
        vc.imageInfo = sender;
    }
    
}

@end
