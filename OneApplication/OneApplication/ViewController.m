//
//  ViewController.m
//  OneApplication
//
//  Created by zhengfeng on 17/1/9.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ViewController.h"


NSString * const kRootLaunchStoryboardKey = @"UILaunchStoryboardName";
NSString * const kRootGuideStoryboardKey = @"UIGuideStoryboardName";
NSString * const kRootLoginStoryboardKey = @"UILoginStoryboardName";
NSString * const kRootMainStoryboardKey = @"UIMainStoryboardFile";


@interface ViewController ()
{
    UIViewController *launch;
    UIViewController *guide;
    UIViewController *login;
    UIViewController *main;

    UIViewController *currentChild;
    UIInterfaceOrientation supportedInterface;
}

@end

@implementation ViewController


#pragma mark - Public
- (void)exitLogin
{
    [self showLoginUI];
    [main removeFromParentViewController];
    main = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    [self addChildViewController:main];
    
}
- (void)login
{
    [self showMainUI];
}
- (void)reLogin
{
    [self showLoginUI];
}
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"[[NSBundle mainBundle] infoDictionary] ->%@",[[NSBundle mainBundle] infoDictionary]);
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadChildrenViewController];
}

- (void)showLoginUI
{
    if (![currentChild isEqual:login]) {
        [self transitionFromOldViewController:currentChild toNewViewController:login];
    }
}
- (void)showMainUI
{
    if (![currentChild isEqual:main]) {
        [self transitionFromOldViewController:currentChild toNewViewController:main];
    }
}

//设置childViewControllerd的frame
- (void)fitFrameForChildViewController:(UIViewController *)chileViewController{
    chileViewController.view.frame = self.view.bounds;
}

#pragma mark - 切换ViewController
- (void)transitionFromOldViewController:(UIViewController *)oldViewController toNewViewController:(UIViewController *)newViewController {
    
    currentChild = newViewController;
    [self transitionFromViewController:oldViewController
                      toViewController:newViewController
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil completion:^(BOOL finished)
     {
         if (finished) {
             [newViewController didMoveToParentViewController:self];
         }else{
             currentChild = oldViewController;
         }
     }];
}

#pragma mark - ChildrenViewController
- (void)loadChildrenViewController
{
    main = [self viewControllerWithKey:kRootMainStoryboardKey];
    if (main) {
        [self addChildViewController:main];
    }
    login = [self viewControllerWithKey:kRootLoginStoryboardKey];
    if (login) {
        [self addChildViewController:login];
    }
    guide = [self viewControllerWithKey:kRootGuideStoryboardKey];
    if (guide) {
        [self addChildViewController:guide];
    }
    launch = [self viewControllerWithKey:kRootLaunchStoryboardKey];
    if (launch) {
        [self addChildViewController:launch];
    }
    currentChild = login;
    if (currentChild) {
        [self.view addSubview:currentChild.view];
    }
}

- (UIViewController *)viewControllerWithKey:(NSString *)key
{
    UIViewController *vc = nil;
    NSString *storyboardName = [[NSBundle mainBundle] infoDictionary][key];
    if ([self checkStoryboardName:storyboardName]) {
        vc = [UIStoryboard storyboardWithName:storyboardName bundle:nil].instantiateInitialViewController;
    }
    return vc;
}

- (BOOL)checkStoryboardName:(NSString *)name
{
    BOOL ret = NO;
    if (name.length) {
       ret = [[NSBundle mainBundle] pathForResource:name ofType:@"storyboardc"];
    }
    return ret;
}

#pragma mark - 旋转和状态栏
- (UIViewController *)root_topViewController
{
    UIViewController * topViewController = currentChild;
    if (currentChild) {
        while ([topViewController isKindOfClass:[UINavigationController class]]
               ||
               [topViewController isKindOfClass:[UITabBarController class]]) {
            if ([topViewController isKindOfClass:[UINavigationController class]] ) {
                topViewController = ((UINavigationController*)topViewController).topViewController;
            }else if ([topViewController isKindOfClass:[UITabBarController class]]) {
                topViewController = ((UITabBarController*)topViewController).selectedViewController;
            }
        }
    }
    return topViewController;
}
- (UIViewController *)childViewControllerForStatusBarStyle{
    return [self root_topViewController];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self root_topViewController]
            supportedInterfaceOrientations];
}
- (BOOL)shouldAutorotate
{
    return YES;
}



@end
