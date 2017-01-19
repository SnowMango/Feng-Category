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

    [self showCamera];
}


- (IBAction)changeCameraDevice:(UIButton *)sender {
    }


- (IBAction)stillImage:(UIButton *)sender {
   
}


//取消
- (IBAction)doneAction:(id)sender {
    
    
}

- (void)showCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        int flag = 0;
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            flag++;
        }
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            flag++;
            if (flag== 1) {
                
            }
        }
        if (flag == 1) {
            self.changeCameraBtn.userInteractionEnabled = NO;
            [self.changeCameraBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"info = %@",info);
    [self performSegueWithIdentifier:@"customImage" sender:info];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ImageResultViewController *vc = segue.destinationViewController;
    vc.imageInfo = sender;
}

@end
