//
//  ZFBillStatusSettingViewController.m
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillStatusSettingViewController.h"
#import "ZFBillStatus.h"
#import "ZFLocalDataManager.h"

@interface  ZFBillStatusSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;
@end

@implementation ZFBillStatusSettingCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end


@interface ZFBillStatusSettingViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *showData;

@property (strong, nonatomic) ZFBillStatus *defaultStatus;
@property (nonatomic) BOOL isChange;
@end

@implementation ZFBillStatusSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray*allStatus = [ZFLocalDataManager shareInstance].allBillStatus;
    self.showData = [NSMutableArray arrayWithArray:allStatus];
    self.defaultStatus = [ZFLocalDataManager shareInstance].defaultBillStatus;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addStatusClick:(id)sender {
    [self changeStatusName:nil];
}

- (IBAction)setDefaultStatusClick:(UIButton*)sender {
    ZFBillStatus* status = self.showData[sender.tag];
    if ([[ZFLocalDataManager shareInstance] setDefaultBillStatus:status]) {
        self.defaultStatus = status;
        [self.tableView reloadData];
    }
}


- (void)changeStatusName:(ZFBillStatus *)status
{
    ZFBillStatus *editStatus = status;
    if (!editStatus) {
        editStatus = [[ZFBillStatus alloc] init];
    }
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"\n请输入订单标记名:" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = weakSelf;
        textField.placeholder = editStatus.name;
        textField.returnKeyType = UIReturnKeyDone;
    }];
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = vc.textFields.firstObject;
        if (tf.text.length) {
            ZFBillStatus *save = editStatus.mutableCopy;
            save.name = tf.text;
            if ([[ZFLocalDataManager shareInstance] saveBillStatus:save]) {
                editStatus.name = save.name;
                if (!status) {
                    [weakSelf.showData addObject:editStatus];
                }
                if ([weakSelf.defaultStatus.identifier isEqualToString:status.identifier]) {
                    [[ZFLocalDataManager shareInstance] setDefaultBillStatus:editStatus];
                }
                weakSelf.isChange = YES;
                [weakSelf.tableView reloadData];
            }
        }
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFBillStatusSettingCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFBillStatusSettingCellId" forIndexPath:indexPath];
    ZFBillStatus* status = self.showData[indexPath.row];
    cell.titleLb.text = status.name;
    cell.defaultBtn.tag = indexPath.row;
    if ([self.defaultStatus.identifier isEqualToString:status.identifier]) {
        cell.defaultBtn.hidden = YES;
    }else{
        cell.defaultBtn.hidden = NO;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFBillStatus* status = self.showData[indexPath.row];
    return ![self.defaultStatus.identifier isEqualToString:status.identifier];
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        ZFBillStatus* status = self.showData[indexPath.row];
        if ([[ZFLocalDataManager shareInstance] deleteBillStatus:status]) {
            [self.showData removeObject:status];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFBillStatus* status = self.showData[indexPath.row];
    [self changeStatusName:status];
}

@end
