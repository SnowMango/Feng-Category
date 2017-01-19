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



@end
