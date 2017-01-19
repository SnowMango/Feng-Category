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
    
    self.imageView = [[UIImageView alloc] initWithImage:_imageInfo];
    self.scrollView.contentSize = self.imageView.frame.size;
    [self.scrollView addSubview:self.imageView];
}



@end
