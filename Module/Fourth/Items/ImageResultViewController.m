//
//  ImageResultViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/19.
//
//

#import "ImageResultViewController.h"

@interface ImageResultViewController ()
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ImageResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage * image =  [self.imageInfo objectForKey:UIImagePickerControllerEditedImage];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.scrollView.contentSize = self.imageView.frame.size;
    [self.scrollView addSubview:self.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
