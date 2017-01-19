//
//  SystemViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/18.
//
//

#import "SystemViewController.h"
#import "ImageResultViewController.h"

@interface SystemViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic)UIImagePickerController *picker;
@end

@implementation SystemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.picker = [[UIImagePickerController alloc] init];
}

- (IBAction)showPhotoLibrary
{
    self.picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    
    [self presentViewController:self.picker animated:YES completion:^{
        
    }];
}

- (IBAction)showPhotoAlbum
{
    self.picker.sourceType =UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    
    [self presentViewController:self.picker animated:YES completion:^{
        
    }];
}

- (IBAction)showCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.picker.sourceType =UIImagePickerControllerSourceTypeCamera;
        self.picker.delegate = self;
        self.picker.allowsEditing = YES;
        
        [self presentViewController:self.picker animated:YES completion:^{
            
        }];
    }else{
        NSLog(@"Camera is unavailable ");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"info = %@",info);
        
        [self performSegueWithIdentifier:@"systemImage" sender:info];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ImageResultViewController *vc = segue.destinationViewController;
    vc.imageInfo = sender;
}
@end
