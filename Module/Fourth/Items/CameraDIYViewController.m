//
//  CameraDIYViewController.m
//  DemoDev
//
//  Created by zhengfeng on 17/1/20.
//
//

#import "CameraDIYViewController.h"

@interface CameraDIYViewController ()

/******** GPUImage Property ***********/
@property (nonatomic, weak) IBOutlet GPUImageView *cameraView;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageFilterGroup *normalFilter;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@end

@implementation CameraDIYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
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
    [self.navigationController  popViewControllerAnimated:YES];
}

#pragma mark - 初始化DIY相机
- (void)setupCapture
{
    self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
}


- (void)addFilter
{
    
}

- (void)removeFilter
{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}


@end
