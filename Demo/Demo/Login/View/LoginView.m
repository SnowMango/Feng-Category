//
//  LoginView.m
//  qingsongshi
//
//  Created by 郑丰 on 2017/1/7.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "LoginView.h"

@implementation LoginView {
    
    UIVisualEffectView *smallView;
    
    UIImageView* imgLeftHand;
    UIImageView* imgRightHand;
    
    UIImageView* imgLeftHandGone;
    UIImageView* imgRightHandGone;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatVisulBg];
        [self creatSubViews];
        
    }
    return self;
}


- (void)loadSubView
{
    [self creatVisulBg];
    [self creatSubViews];
}

- (void)creatVisulBg {
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.bounds];
    
    imageview.image = [UIImage imageNamed:@"bg.jpeg"];
    imageview.contentMode = UIViewContentModeScaleToFill;
    imageview.userInteractionEnabled = YES;
    [self addSubview:imageview];
    
    UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectview.frame = CGRectMake(0, 0, imageview.frame.size.width, imageview.frame.size.height);
    [imageview addSubview:effectview];
    
}

- (void)creatSubViews {

    //猫头
    UIImageView* imgLogin = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2 - 211 / 2, 150-99, 211, 108)];
    imgLogin.image = [UIImage imageNamed:@"owl-login"];
    imgLogin.layer.masksToBounds = YES;
    [self addSubview:imgLogin];
    
    //捂眼的左右爪
    imgLeftHand = [[UIImageView alloc] initWithFrame:CGRectMake(10, 90, 40, 65)];
    imgLeftHand.image = [UIImage imageNamed:@"owl-login-arm-left"];
    [imgLogin addSubview:imgLeftHand];
    
    imgRightHand = [[UIImageView alloc] initWithFrame:CGRectMake(imgLogin.frame.size.width / 2 + 60, 90, 40, 65)];
    imgRightHand.image = [UIImage imageNamed:@"owl-login-arm-right"];
    [imgLogin addSubview:imgRightHand];
    
    imgLeftHandGone = [[UIImageView alloc] initWithFrame:CGRectMake(10, 90-22, 40, 65)];
    imgLeftHandGone.image = [UIImage imageNamed:@"icon_hand"];
    [imgLogin addSubview:imgLeftHandGone];
    
    
    imgRightHandGone = [[UIImageView alloc] initWithFrame:CGRectMake(imgLogin.frame.size.width / 2 + 60, 90-22, 40, 65)];
    imgRightHandGone.image = [UIImage imageNamed:@"icon_hand"];
    [imgLogin addSubview:imgRightHandGone];
    
    smallView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    smallView.frame = CGRectMake(20, 150, CGRectGetWidth(self.frame)-40, CGRectGetWidth(self.frame)-40);
    smallView.layer.cornerRadius = 5;
    smallView.layer.masksToBounds = YES;
    [self addSubview:smallView];
    
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, smallView.frame.size.width-20, 20)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    [smallView addSubview:self.titleLabel];
    
    self.textField1 = [[UITextField alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame)+15, smallView.frame.size.width-40, 40)];
    self.textField1.delegate = self;
    self.textField1.layer.cornerRadius = 5;
    self.textField1.layer.borderWidth = .5;
    self.textField1.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField1.layer.borderColor = [UIColor grayColor].CGColor;
    self.textField1.placeholder = @"请输入账号";
    self.textField1.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.textField1.frame), CGRectGetHeight(self.textField1.frame))];
    self.textField1.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgUser = [[UIImageView alloc] initWithFrame:CGRectMake(9, 9, 22, 22)];
    imgUser.image = [UIImage imageNamed:@"iconfont-user"];
    [self.textField1.leftView addSubview:imgUser];
    [smallView addSubview:self.textField1];
    
    self.textField2 = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.textField1.frame), CGRectGetMaxY(self.textField1.frame)+10, CGRectGetWidth(self.textField1.frame), CGRectGetHeight(self.textField1.frame))];
    self.textField2.delegate = self;
    self.textField2.layer.cornerRadius = 5;
    self.textField2.layer.borderWidth = .5;
    self.textField2.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField2.layer.borderColor = [UIColor grayColor].CGColor;
    self.textField2.placeholder = @"请输入密码";
    self.textField2.secureTextEntry = YES;
    self.textField2.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.textField2.frame), CGRectGetHeight(self.textField2.frame))];
    self.textField2.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 28, 28)];
    imgPwd.image = [UIImage imageNamed:@"iconfont-password"];
    [self.textField2.leftView addSubview:imgPwd];
    [smallView addSubview:self.textField2];
    
    
    self.loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.textField2.frame)+10, smallView.frame.size.width-20, 40)];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    self.loginBtn.layer.cornerRadius = 5;
    [self.loginBtn setBackgroundColor:[UIColor colorWithRed:83/255.0 green:149/255.0 blue:232/255.0 alpha:1]];
    [self.loginBtn addTarget:self action:@selector(LoginAction:) forControlEvents:UIControlEventTouchUpInside];
    [smallView addSubview:self.loginBtn];
    
    
    smallView.frame = CGRectMake(20, 150, CGRectGetWidth(self.frame)-40, CGRectGetMaxY(self.loginBtn.frame)+15);
    
}


- (void)LoginAction:(UIButton *)sender{
    [self endEditing:YES];
    if (_clickBlock) {
        _clickBlock(self.textField1.text, self.textField2.text);
    }
}
- (void)setClickBlock:(ClicksAlertBlock)clickBlock{
    _clickBlock = [clickBlock copy];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}


//猫咪动画
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.isSecureTextEntry) {
        [self showAnimation];
    }else{
        [self hiddenAnimation];
    }
}

- (void)showAnimation
{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        imgLeftHand.transform = CGAffineTransformMakeTranslation(50, -30);
        imgRightHand.transform = CGAffineTransformMakeTranslation(-48, -30);
        imgLeftHandGone.transform = CGAffineTransformMakeTranslation(55, 30);
        imgRightHandGone.transform = CGAffineTransformMakeTranslation(-43, 30);
        
    } completion:^(BOOL b){
    }];
}

- (void)hiddenAnimation
{
    [UIView animateWithDuration:0.5 animations:^{
        imgLeftHand.transform = CGAffineTransformIdentity;
        imgRightHand.transform = CGAffineTransformIdentity;
        imgLeftHandGone.transform = CGAffineTransformIdentity;
        imgRightHandGone.transform = CGAffineTransformIdentity;
    } completion:^(BOOL b) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.isSecureTextEntry) {
        [self hiddenAnimation];
    }
}


@end

