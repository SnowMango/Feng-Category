//
//  CameraDIYViewController.m
//  DemoDev
//
//  Created by zhengfeng on 17/1/20.
//
//

#import "CameraDIYViewController.h"
#import "ImageResultViewController.h"
#import "FilterObject.h"
@interface CameraDIYCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIView *contentVew;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;


@end

@implementation CameraDIYCell



@end

@interface CameraDIYViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
{
    CGFloat beginGestureScale;
    CGFloat effectiveScale;
}
@property (nonatomic,strong) NSArray *filters;
@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *collectionView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *recrodTimeLabel;

/******** GPUImage Property ***********/
@property (nonatomic, weak) IBOutlet GPUImageView *cameraView;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
//@property (nonatomic, strong) GPUImageFilterGroup *normalFilter;
@property (nonatomic, strong) GPUImageFilter * currentFilter;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@end

@implementation CameraDIYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if !TARGET_OS_SIMULATOR
    self.filters = [[FilterObject new] filters];
    [self setupCapture];
    [self startCameraCapture];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didOrientationDeviceChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)didOrientationDeviceChange:(NSNotification *)noti
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    if (orientation == UIDeviceOrientationPortrait) {
        self.stillCamera.outputImageOrientation = orientation;
    }else if (UIDeviceOrientationIsLandscape(orientation)){
        self.stillCamera.outputImageOrientation = orientation;
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


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self stopCameraCapture];
    [self dissmissController];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)dissmissController
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelCamera:(UIButton *)sender {
    [self stopCameraCapture];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)controlBtn:(id)sender {
    [self takePicture];
}
- (IBAction)filterBtn:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    self.collectionView.hidden = !sender.selected;
}

#pragma mark - 初始化DIY相机
- (void)setupCapture
{
    self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    effectiveScale = 1;
    GPUImageFilter *filter = self.filters.firstObject[kFilterObjectKey];
    [self changeFilter:filter];
    
}

- (void)startCameraCapture
{
    [self.stillCamera startCameraCapture];
}

- (void)stopCameraCapture
{
    [self.stillCamera stopCameraCapture];
}
#pragma mark - 拍照
- (void)takePicture
{
    AVCaptureConnection *stillImageConnection = [self.stillCamera videoCaptureConnection];
    stillImageConnection.videoOrientation= self.stillCamera.outputImageOrientation;
    stillImageConnection.videoScaleAndCropFactor = effectiveScale;
    [self.stillCamera capturePhotoAsPNGProcessedUpToFilter:self.currentFilter withCompletionHandler:^(NSData *processedPNG, NSError *error) {
        UIImage * image = [UIImage imageWithData:processedPNG];
        [self performSegueWithIdentifier:@"DIYImage" sender:image];
    }];
}
#pragma mark - 切换滤镜

- (void)changeFilter:(GPUImageFilter*)filter
{
    [self.stillCamera removeAllTargets];
    [self.stillCamera addTarget:filter];
    [filter addTarget:self.cameraView];
    self.currentFilter = filter;
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
    NSLog(@"scale = %@", @(effectiveScale));
    if (effectiveScale < 1.0)
        effectiveScale = 1.0;
    CGFloat maxScaleAndCropFactor = [self.stillCamera videoCaptureConnection].videoMaxScaleAndCropFactor;
    if (effectiveScale > maxScaleAndCropFactor)
        effectiveScale = maxScaleAndCropFactor;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    self.cameraView.layer.affineTransform =CGAffineTransformMakeScale(effectiveScale, effectiveScale);
    [CATransaction commit];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DIYImage"]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        ImageResultViewController *vc = segue.destinationViewController;
        vc.imageInfo = sender;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filters.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CameraDIYCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cameraDIY" forIndexPath:indexPath];
    NSDictionary *filter = self.filters[indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",filter[kFilterNameKey]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GPUImageFilter *filter = self.filters[indexPath.row][kFilterObjectKey];
    if ([filter isEqual:self.currentFilter]) {
        return;
    }
    [self changeFilter:filter];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.01;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.01;
}

@end
