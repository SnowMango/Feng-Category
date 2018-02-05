//
//  ZFPriceSettingViewController.m
//  yang
//
//  Created by 郑丰 on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFPriceSettingViewController.h"
#import "ZFPriceSystomEditViewController.h"
#import "ZFPriceSystom.h"
#import "SVProgressHUD.h"
#import "ZFLocalDataManager.h"

@interface ZFPriceSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *showData;
@end

@implementation ZFPriceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]  style:0 target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.showData = [NSMutableArray arrayWithArray:self.systoms];
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPriceSystomClick:(id)sender {
    [self performSegueWithIdentifier:@"priceSystomEdit" sender:nil];
}


- (void)showDeletePriceSystomAlert:(NSIndexPath *)indexPath
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"\n是否删除该定价？" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    
    ZFPriceSystom* systom = self.showData[indexPath.row];
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        [weakSelf deletePriceSystom:systom];
        [weakSelf.tableView reloadData];
        
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)deletePriceSystom:(ZFPriceSystom*)systom
{
    BOOL ret = [[ZFLocalDataManager shareInstance] deletePriceSystom:systom];
    if (!ret) {
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    [self.showData removeObject:systom];
    if (self.didEdit) {
        self.didEdit(self.showData);
    };
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"priceSystomEdit"]) {
        ZFPriceSystom *editPriceSystom = sender;
        if (!sender) {
            editPriceSystom = [[ZFPriceSystom alloc] init];
        }
        ZFPriceSystomEditViewController *vc = segue.destinationViewController;
        vc.systom = editPriceSystom;
        __weak typeof(self)weakSelf = self;
        vc.compelte = ^(BOOL finish) {
            if (finish) {
                if (!sender) {
                    [weakSelf.showData addObject:editPriceSystom];
                }
                if (weakSelf.didEdit) {
                    weakSelf.didEdit(weakSelf.showData);
                }
                [weakSelf.tableView reloadData];
            }
        };
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFPriceSettingCellId" forIndexPath:indexPath];
    ZFPriceSystom* systom = self.showData[indexPath.row];
    cell.textLabel.text = systom.name;
    
    return cell;
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
        [self showDeletePriceSystomAlert:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZFPriceSystom* systom = self.showData[indexPath.row];
    [self performSegueWithIdentifier:@"priceSystomEdit" sender:systom];
}


@end
