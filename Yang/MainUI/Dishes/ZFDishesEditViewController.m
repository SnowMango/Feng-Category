//
//  ZFDishesEditViewController.m
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFDishesEditViewController.h"
#import "SVProgressHUD.h"

@interface ZFDishesEditViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *unitTF;
@end

@implementation ZFDishesEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.nameTF.text = self.editDishes.name;
    self.nameTF.userInteractionEnabled = !self.nameTF.text.length;
    self.unitTF.placeholder = self.editDishes.unit;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint loc = [[touches anyObject] locationInView:self.view];
    if (!CGRectContainsPoint(self.nameTF.superview.frame, loc)) {
        [self.view removeFromSuperview];
    }
}

- (IBAction)cancelBtn:(id)sender
{
    if (self.compelte) {
        self.compelte(NO);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeFromSuperview];
}
- (IBAction)doneBtn:(id)sender
{
    if (!self.nameTF.text.length) {
        [SVProgressHUD showErrorWithStatus:@"请输入名称"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    self.editDishes.name = self.nameTF.text;
    if (self.unitTF.text.length) {
        self.editDishes.unit = self.unitTF.text;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.compelte) {
        self.compelte(YES);
    }
    [self.view removeFromSuperview];
}

/**
 *  键盘弹出
 */
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    /* 获取键盘的高度 */
    NSDictionary *userInfo = aNotification.userInfo;
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = aValue.CGRectValue;
    /* 输入框上移 */
    CGFloat padding = 20;
    UIView *moveView = self.nameTF.superview;
    if (CGRectGetMaxY(moveView.frame)+padding > CGRectGetMinY(keyboardRect)) {
        CGFloat offset = CGRectGetMaxY(moveView.frame)+padding - CGRectGetMinY(keyboardRect);
        moveView.transform = CGAffineTransformMakeTranslation(0, -offset);
    }
}

/**
 *  键盘退出
 */
- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    /* 输入框下移 */
    self.nameTF.superview.transform = CGAffineTransformIdentity;
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
