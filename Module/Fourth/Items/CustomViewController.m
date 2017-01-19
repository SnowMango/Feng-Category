//
//  CustomViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/19.
//
//

#import "CustomViewController.h"
#import "ImageResultViewController.h"

@interface CustomViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *changeCameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *stillImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}


- (IBAction)changeCameraDevice:(UIButton *)sender {
    }


- (IBAction)stillImage:(UIButton *)sender {
   
}


//取消
- (IBAction)doneAction:(id)sender {
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ImageResultViewController *vc = segue.destinationViewController;
    vc.imageInfo = sender;
}

@end
