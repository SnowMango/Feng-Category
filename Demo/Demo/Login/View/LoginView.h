//
//  LoginView.h
//  qingsongshi
//
//  Created by 郑丰 on 2017/1/7.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView<UITextFieldDelegate>

typedef void (^ClicksAlertBlock)(NSString *acount, NSString *password);
@property (nonatomic, copy, readonly) ClicksAlertBlock clickBlock;

@property(nonatomic,strong)UITextField *textField1;

@property(nonatomic,strong)UITextField *textField2;

@property(nonatomic,strong)UIButton *loginBtn;

@property(nonatomic,strong)UILabel *titleLabel;

- (void)setClickBlock:(ClicksAlertBlock)clickBlock;

- (void)loadSubView;
@end
