//
//  ZFBillViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/30.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillViewController.h"
#import "ZFBillDetailViewController.h"
#import "ZFBillDateViewController.h"
#import "ZFBillPriceSystomViewController.h"
#import "ZFBillStatusViewController.h"
#import "ZFBillAddViewController.h"
#import "Model.h"
#import "ZFBillStatusSettingViewController.h"

#import "MiniPlayerView.h"
#import "ZFLocalDataManager.h"
#import "SVProgressHUD.h"

@interface ZFBillViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *priceSystomLb;

@property (weak, nonatomic) IBOutlet UILabel *timeLb;
@property (weak, nonatomic) IBOutlet UILabel *numberLb;
@property (weak, nonatomic) IBOutlet UILabel *amountLb;

@property (weak, nonatomic) IBOutlet UILabel *statusLb;
@property (weak, nonatomic) IBOutlet UILabel *incomeLb;

@end

@implementation ZFBillViewCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFBillViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    ZFBillDateViewController *billDateVC;
    ZFBillPriceSystomViewController *billPriceSystomVC;
    ZFBillStatusViewController *billStatusVC;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *billNumberTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *billNumberLb;
@property (weak, nonatomic) IBOutlet UILabel *incomeTitleLb;
@property (weak, nonatomic) IBOutlet UILabel *incomeLb;

@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UIButton *systomBtn;
@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@property (weak, nonatomic) IBOutlet MiniPlayerView *miniView;

@property (strong, nonatomic) NSMutableArray <ZFBill*>*billList;
@property (strong, nonatomic) NSArray *showData;
@property (strong, nonatomic) NSDictionary *showInfo;

@property (strong, nonatomic) NSDate *showStartDate;
@property (strong, nonatomic) NSDate *showEndDate;
@property (strong, nonatomic) ZFPriceSystom *showPriceSystom;
@property (strong, nonatomic) ZFBillStatus *showStatus;

@property (strong, nonatomic) ZFPriceSystom *allSystom;
@property (strong, nonatomic) ZFBillStatus *allStatus;

@property (nonatomic) long billCount;
@property (nonatomic) double totalIncome;

@end

@implementation ZFBillViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allSystom = [[ZFPriceSystom alloc] init];
    self.allSystom.name = @"全部定价";
    
    self.allStatus = [[ZFBillStatus alloc] init];
    self.allStatus.name = @"全部标记";
    
    self.showPriceSystom = self.allSystom;
    self.showStatus = self.allStatus;
    
    [self updateDateBtn];
    [self updatePriceSystomBtn];
    [self updateStatusBtn];
    self.billList = [NSMutableArray arrayWithArray:[[ZFLocalDataManager shareInstance] allBill]];
    [self updateData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBillNotication:)
                                                 name:kBillNeedUpdateUINotification object:nil];
    
}

- (void)updateBillNotication:(NSNotification *)notification
{
    self.billList = [NSMutableArray arrayWithArray:[[ZFLocalDataManager shareInstance] allBill]];
    [self backgrandUpdateData];
    [self updatePriceSystomBtn];
    [self updateStatusBtn];
}

- (void)backgrandUpdateData
{
    dispatch_queue_t global =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global,^{
        [self filterShowBill];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.billNumberLb.text = @(self.billCount).stringValue;
            self.incomeLb.text = @(self.totalIncome).stringValue;
            [self.tableView reloadData];
        });
    });
}
- (void)updateData
{
    [SVProgressHUD showWithStatus:@"loading..."];
    dispatch_queue_t global =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(global,^{
        [self filterShowBill];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismissWithDelay:0.25];
            self.billNumberLb.text = @(self.billCount).stringValue;
            self.incomeLb.text = @(self.totalIncome).stringValue;
            [self.tableView reloadData];
        });
    });
}

- (void)updateWithBillData:(NSArray*)billData
{
    NSDateFormatter *mat =[[NSDateFormatter alloc] init];
    mat.dateFormat = @"yyyy-MM-dd";
    NSMutableDictionary *showTem= [NSMutableDictionary dictionary];
    double totalIncome = 0;
    for (ZFBill *bill in billData) {
        NSString *key = [mat stringFromDate:bill.time];
        totalIncome += bill.income;
        NSMutableArray*mu = [NSMutableArray arrayWithArray:[showTem objectForKey:key]];
        [mu addObject:bill];
        [showTem setObject:mu forKey:key];
    }
    self.billCount = billData.count;
    self.totalIncome = totalIncome;
    self.showInfo = showTem;
    self.showData = [self.showInfo.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        NSDate *date1 = [mat dateFromString:obj1];
        NSDate *date2 = [mat dateFromString:obj2];
        return [date2 compare:date1];
    }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"billDetail"]) {
        ZFBillDetailViewController *vc = segue.destinationViewController;
        vc.showBill = sender;
        __weak typeof(self) weakSelf = self;
        vc.change = ^(BOOL finish) {
            if (finish) {
                [weakSelf.tableView reloadData];
            }
        };
    }else if ([segue.identifier isEqualToString:@"addBill"]) {
        ZFBillAddViewController *vc = segue.destinationViewController;
        __weak typeof(self) weakSelf = self;
        vc.systom = sender;
        vc.compelte = ^(ZFBill *bill) {
            [weakSelf.billList addObject:bill];
            
            [weakSelf updateData];
        };
    }
}
#pragma mark - miniView
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect moveArea = CGRectMake(0,
                                 self.topLayoutGuide.length,
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.view.bounds) - self.topLayoutGuide.length *2);
    self.miniView.enbleMoveArea = moveArea;
    
}
#pragma mark - 添加
- (IBAction)miniViewTap:(UITapGestureRecognizer *)sender {
    
    NSArray * systoms = [ZFLocalDataManager shareInstance].allPriceSystom;
    if (systoms.count) {
        if (systoms.count == 1) {
            [self performSegueWithIdentifier:@"addBill" sender:systoms.firstObject];
        }else{
            billPriceSystomVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFBillPriceSystomViewController"];
            billPriceSystomVC.showData = systoms;
            __weak typeof(self) weakSelf = self;
            billPriceSystomVC.complete = ^(ZFPriceSystom *systom) {
                [weakSelf performSegueWithIdentifier:@"addBill" sender:systom];
            };
            [self.view.window addSubview:billPriceSystomVC.view];
        }
    }else{
        [SVProgressHUD showInfoWithStatus:@"请添加定价"];
        [SVProgressHUD dismissWithDelay:0.5];
        self.tabBarController.selectedIndex = 1;
    }
}
#pragma mark -删除
- (void)showDeleteBillAlert:(ZFBill *)bill
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"\n是否删除该订单？" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;

    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        [weakSelf deleteBill:bill];
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)deleteBill:(ZFBill*)bill
{
    BOOL ret = [[ZFLocalDataManager shareInstance] deleteBill:bill];
    if (!ret) {
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    [self.billList removeObject:bill];
    
    [self updateData];
}

#pragma mark - 筛选 btn click -
- (IBAction)clickDateBtn:(UIButton *)sender
{
    [self showDateSelectView];
}

- (IBAction)clickPriceSystomBtn:(UIButton *)sender
{
    [self showPriceSystomSelectView];
}
- (IBAction)clickStatusSystomBtn:(UIButton *)sender
{
    [self showStatusSelectView];
}
#pragma mark -筛选-

- (void)filterShowBill
{
    NSArray *filter = self.billList.copy;
    //时间
    if (self.showStartDate && self.showEndDate) {
        NSPredicate *pre =[NSPredicate predicateWithFormat:@"time >= %@ AND time <= %@", self.showStartDate, [self.showEndDate dateByAddingTimeInterval:24*3600 - 1]];
        NSArray *result = [filter filteredArrayUsingPredicate:pre];
        NSLog(@"Date:%@", result);
        filter = result;
    }
    //定价
    if (self.showPriceSystom != self.allSystom) {
        NSPredicate *pre =[NSPredicate predicateWithFormat:@"systomId == %@", self.showPriceSystom.identifier];
        NSArray *result = [filter filteredArrayUsingPredicate:pre];
        NSLog(@"Systom:%@", result);
        filter = result;
    }
    //标记
    if (self.showStatus != self.allStatus) {
        NSPredicate *pre =[NSPredicate predicateWithFormat:@"status.identifier == %@", self.showStatus.identifier];
        NSArray *result = [filter filteredArrayUsingPredicate:pre];
        NSLog(@"Status:%@", result);
        filter = result;
    }
    [self updateWithBillData:filter];
}


- (void)showDateSelectView
{
    billDateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFBillDateViewController"];
    __weak typeof(self) weakSelf = self;
    billDateVC.complete = ^(NSDate *start, NSDate *end) {
        weakSelf.showStartDate = start;
        weakSelf.showEndDate = end;
        [weakSelf updateDateBtn];
        [weakSelf updateData];
    };
    [self.view.window addSubview:billDateVC.view];
    
}

- (void)showPriceSystomSelectView
{
    NSArray *priceSystom =[ZFLocalDataManager shareInstance].allPriceSystom;
    if (!priceSystom.count) {
        [SVProgressHUD showInfoWithStatus:@"未添加定价表"];
        [SVProgressHUD dismissWithDelay:0.5];
        return ;
    }
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:self.allSystom];
    [temp addObjectsFromArray:priceSystom];
    billPriceSystomVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFBillPriceSystomViewController"];
    billPriceSystomVC.showData = temp;
    billPriceSystomVC.selectSystom = self.showPriceSystom;
    __weak typeof(self) weakSelf = self;
    billPriceSystomVC.complete = ^(ZFPriceSystom *systom) {
        weakSelf.showPriceSystom = systom;
        [weakSelf updatePriceSystomBtn];
        [weakSelf updateData];
    };
    [self.view.window addSubview:billPriceSystomVC.view];
}
- (void)showStatusSelectView
{
    NSArray *billStatis =[ZFLocalDataManager shareInstance].allBillStatus;
    if (!billStatis.count) {
        [SVProgressHUD showInfoWithStatus:@"未添加标记"];
        [SVProgressHUD dismissWithDelay:0.5];
        return ;
    }
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:self.allStatus];
    [temp addObjectsFromArray:billStatis];
    billStatusVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFBillStatusViewController"];
    billStatusVC.showData = temp;
    billStatusVC.selectStatus = self.showStatus;
    __weak typeof(self) weakSelf = self;
    billStatusVC.complete = ^(ZFBillStatus *status) {
        weakSelf.showStatus = status;
        [weakSelf updateStatusBtn];
        [weakSelf updateData];
    };
    [self.view.window addSubview:billStatusVC.view];
}
#pragma mark - update筛选 -
- (void)updateDateBtn
{
    NSString *title = @"所有日期";
    NSCalendar *canlender = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    if (self.showStartDate && self.showEndDate) {
        NSDateFormatter *matter = [[NSDateFormatter alloc] init];
        if ([canlender isDate:self.showStartDate inSameDayAsDate:self.showEndDate]) {
            matter.dateFormat = @"yyyy-MM-dd";
            title = [matter stringFromDate:self.showStartDate];
        }else{
            matter.dateFormat = @"MM/dd";
            title = [NSString stringWithFormat:@"%@-%@",
                     [matter stringFromDate:self.showStartDate],
                     [matter stringFromDate:self.showEndDate]];
        }
    }
    [self.dateBtn setTitle:title forState:UIControlStateNormal];
}

- (void)updatePriceSystomBtn
{
    NSString *title = self.showPriceSystom.name;
    [self.systomBtn setTitle:title forState:UIControlStateNormal];
}
- (void)updateStatusBtn
{
    NSString *title = self.showStatus.name;
    [self.statusBtn setTitle:title forState:UIControlStateNormal];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.showInfo.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *billList = self.showInfo[self.showData[section]];
    return billList.count? billList.count*2-1: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellOtherId"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellOtherId"];
        }
        cell.contentView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        return cell;
    }
    ZFBill *bill = self.showInfo[self.showData[indexPath.section]][indexPath.row/2L];
    
    ZFBillViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFBillViewCellId" forIndexPath:indexPath];
    NSDateFormatter *mat =[[NSDateFormatter alloc] init];
    mat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    cell.priceSystomLb.text = bill.systomName;
    cell.timeLb.text = [mat stringFromDate:bill.time];

    cell.statusLb.text = bill.status.name;
    
    cell.numberLb.text = [NSString stringWithFormat:@"购买%@个菜品",@(bill.itemCount)];
    cell.amountLb.text = [NSString stringWithFormat:@"总计:￥%@",@(bill.amount)];
    cell.incomeLb.text = [NSString stringWithFormat:@"实收:￥%@",@(bill.income)];;
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = self.showData[section];
    return title;
}

//delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2) {
        return NO;
    }
    return TRUE;
}

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
        ZFBill *bill = self.showInfo[self.showData[indexPath.section]][indexPath.row/2L];
        [self showDeleteBillAlert:bill];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2) {
        return 10;
    }
    return 80;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2) {
        return;
    }
    ZFBill *bill = self.showInfo[self.showData[indexPath.section]][indexPath.row/2L];
    [self performSegueWithIdentifier:@"billDetail" sender:bill];
}




@end
