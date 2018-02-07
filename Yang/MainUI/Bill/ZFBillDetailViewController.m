//
//  ZFBillDetailViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillDetailViewController.h"
#import "ZFBillStatusViewController.h"
#import "Model.h"

#import "ZFLocalDataManager.h"
#import "SVProgressHUD.h"
//酒水 糕点 锅仔 面食
@interface ZFBillDetailViewCell :UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLb;

@property (weak, nonatomic) IBOutlet UILabel *numberLb;

@property (weak, nonatomic) IBOutlet UILabel *priceLb;

@end

@implementation ZFBillDetailViewCell

@end


@interface ZFBillDetailViewController ()<UITextFieldDelegate, UITableViewDelegate,UITableViewDataSource>
{
    ZFBillStatusViewController *billStatusVC;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *systomLb;
@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@property (weak, nonatomic) IBOutlet UILabel *amountLb;
@property (weak, nonatomic) IBOutlet UILabel *numberLb;
@property (weak, nonatomic) IBOutlet UIButton *incomeBtn;

@property (nonatomic) BOOL isChange;
@end

@implementation ZFBillDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]  style:0 target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self updateUI];
}

- (void)updateUI
{
    self.amountLb.text = [NSString stringWithFormat:@"总计金额：%@",@(self.showBill.amount)];
    self.numberLb.text = [NSString stringWithFormat:@"菜品数量：%@",@(self.showBill.itemCount)];
    
    self.systomLb.text = self.showBill.systomName;
    
    NSDateFormatter *mat = [[NSDateFormatter alloc] init];
    mat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    self.timeLb.text = [mat stringFromDate:self.showBill.time];
    [self updateIncomeBtn];
    
    [self updateStatusBtn];
}

- (void)back:(id)sender
{
    if (self.change) {
        self.change(self.isChange);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateStatusBtn
{
    NSString *title = self.showBill.status.name;
    [self.statusBtn setTitle:title forState:UIControlStateNormal];
}
- (void)updateIncomeBtn
{
    NSString *title = [NSString stringWithFormat:@"实收:￥%@",@(self.showBill.income)];
    [self.incomeBtn setTitle:title forState:UIControlStateNormal];
}

- (IBAction)changeStatusBtnClick:(id)sender
{
    [self changeStatusSelectView];
}

- (IBAction)changeIncomeBtnClick:(id)sender
{
    [self showIncomeChangeView];
}

- (void)changeStatusSelectView
{
    NSArray*allStatus = [ZFLocalDataManager shareInstance].allBillStatus;
    billStatusVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFBillStatusViewController"];
    billStatusVC.showData = allStatus;
    billStatusVC.selectStatus = self.showBill.status;
    __weak typeof(self) weakSelf = self;
    billStatusVC.complete = ^(ZFBillStatus *status) {
        ZFBill *save = weakSelf.showBill.mutableCopy;
        save.status = status;
        if ([[ZFLocalDataManager shareInstance] saveBill:save]) {
            weakSelf.showBill.status = status;
            [weakSelf updateStatusBtn];
            weakSelf.isChange = YES;
        }else{
            [SVProgressHUD showErrorWithStatus:@"标记保存失败"];
            [SVProgressHUD dismissWithDelay:0.5];
        }
    };
    [self.view.window addSubview:billStatusVC.view];
}
- (void)showIncomeChangeView
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"实收金额" message:@"\n请输入实收金额(￥):" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    __weak typeof(vc) weakVC = vc;
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = weakSelf;
        textField.placeholder = @(weakSelf.showBill.income).stringValue;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = weakVC.textFields.firstObject;
        if (tf.text.length) {
            ZFBill *save = weakSelf.showBill.mutableCopy;
            save.income = tf.text.doubleValue;
            if (save.income == weakSelf.showBill.income) {
                return;
            }
            if ([[ZFLocalDataManager shareInstance] saveBill:save]) {
                weakSelf.isChange = YES;
                weakSelf.showBill.income = save.income;
                [weakSelf updateIncomeBtn];
            }else{
                [SVProgressHUD showErrorWithStatus:@"保存失败"];
                [SVProgressHUD dismissWithDelay:0.5];
            }
        }
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showBill.dishes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFBillDetailViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFBillDetailViewCellId" forIndexPath:indexPath];
    ZFDishes *dishes = self.showBill.dishes[indexPath.row];
    cell.nameLb.text = dishes.name;
    cell.numberLb.text = [NSString stringWithFormat:@"x%@", @(dishes.count)];
    cell.priceLb.text = [NSString stringWithFormat:@"￥%@", @(dishes.count*dishes.price)];
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL ret = YES;
    if ([string isEqualToString:@"."]) {
        ret = ![textField.text containsString:@"."];
        ret = textField.text.length ? ret: NO;
    }else if (![string isEqualToString:@""]){
        ret = [self checkNumber:string];
        BOOL cheek = textField.text.length ? ret: NO;
        if (cheek) {
            ret = [self checkFloatNumber:textField.text];
        }
    }
    return ret;
}

- (BOOL)checkFloatNumber:(NSString *)number
{
    NSString *regex = @"^[1-9][0-9]*($|(.[0-9]{0,1}$))";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:number];
    return isValid;
}

- (BOOL)checkNumber:(NSString *)number
{
    NSString *regex = @"^[0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:number];
    return isValid;
}



@end
