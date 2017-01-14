//
//  ViewController.h
//  OneApplication
//
//  Created by zhengfeng on 17/1/9.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kRootLaunchStoryboardKey;
extern NSString * const kRootGuideStoryboardKey;
extern NSString * const kRootLoginStoryboardKey;
extern NSString * const kRootMainStoryboardKey;

@interface ViewController : UIViewController

- (void)exitLogin;
- (void)login;

- (void)showChildViewController:(NSString*)storyboardKey;

- (UIViewController *)rootChildViewController:(const NSString *)storyboardKey;
@end

