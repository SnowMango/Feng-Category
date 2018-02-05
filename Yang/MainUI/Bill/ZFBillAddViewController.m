//
//  ZFBillAddViewController.m
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillAddViewController.h"
#import "ZFDishesGroup.h"
#import "ZFDishes.h"
#import "Macro.h"
#import "ZFLocalDataManager.h"
#import "SVProgressHUD.h"

@interface ZFBillAddListHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@end

@implementation ZFBillAddListHeaderView
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFBillAddListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;

@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (weak, nonatomic) IBOutlet UILabel *numberLb;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@end

@implementation ZFBillAddListCell
-(void)awakeFromNib
{
    [super awakeFromNib];
}
@end

@interface ZFBillAddListSectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@end

@implementation ZFBillAddListSectionCell
-(void)awakeFromNib
{
    [super awakeFromNib];

    
}
@end

@interface ZFBillAddViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *sectionCollectionView;

@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLb;
@property (weak, nonatomic) IBOutlet UILabel *numberDishesLb;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

@property (strong, nonatomic) NSArray *showData;

@property (strong, nonatomic) NSMutableDictionary *selectDishes;
@property (strong, nonatomic) NSMutableDictionary *allDishes;
@property (strong, nonatomic) NSMutableArray *selectDishesSort;

@property (strong, nonatomic) ZFBill *addBill;
@end

@implementation ZFBillAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showData = self.systom.group;
    self.selectDishes = [NSMutableDictionary dictionary];
    self.allDishes = [NSMutableDictionary dictionary];
    for ( ZFDishesGroup *g in self.showData) {
        for (ZFDishes * price in g.dishes) {
            [self.allDishes setObject:price forKey:price.identifier];
        }
    }
    [self reloadStatisticsData];
}

- (NSMutableArray *)selectDishesSort
{
    if (!_selectDishesSort) {
        _selectDishesSort =[NSMutableArray array];
    }
    return _selectDishesSort;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtn:(UIButton*)sender
{
    ZFBill *addBill = [self billWithCurrentData];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"实收金额" message:@"\n请输入实收金额(￥):" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = weakSelf;
        textField.text = @(addBill.amount).stringValue;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = vc.textFields.firstObject;
        if (tf.text.length) {
            addBill.income = tf.text.doubleValue;
            if ([[ZFLocalDataManager shareInstance] saveBill:addBill]) {
                if (weakSelf.compelte) {
                    weakSelf.compelte(addBill);
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                [SVProgressHUD showInfoWithStatus:@"保存失败"];
                [SVProgressHUD dismissWithDelay:0.5];
            }
        }
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (ZFBill *)billWithCurrentData
{
    ZFBill* addBill = [[ZFBill alloc] init];
    addBill.systomId =self.systom.identifier;
    addBill.systomName =self.systom.name;
    addBill.status = [ZFLocalDataManager shareInstance].defaultBillStatus;
    addBill.time = [NSDate date];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *idntifier in self.selectDishesSort) {
        ZFDishes *billDishes = self.selectDishes[idntifier];
        [temp addObject:billDishes];
    }
    addBill.dishes = temp;
    double count = 0;
    double totalPrice = 0;
    for (ZFDishes *prices in addBill.dishes) {
        count += prices.count;
        totalPrice += prices.count*prices.price;
    }
    addBill.amount = totalPrice;
    addBill.itemCount = count;    
    return addBill;
}

- (void)reloadStatisticsData
{
    double count = 0;
    double totalPrice = 0;
    for (ZFDishes *prices in self.selectDishes.allValues) {
        count += prices.count;
        totalPrice += prices.count*prices.price;
    }
    
    self.numberDishesLb.hidden = !count;
    if (count) {
        self.iconIV.image = [UIImage imageNamed:@"dishes"];
        self.numberDishesLb.text = @(count).stringValue;
        self.finishBtn.backgroundColor = UICOLOR_HEX(0x50C8EF);
        [self.finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    }else{
        self.iconIV.image = [UIImage imageNamed:@"bowl"];
        self.numberDishesLb.text = @"";
        self.finishBtn.backgroundColor = [UIColor darkGrayColor];
        [self.finishBtn setTitle:@"实收" forState:UIControlStateNormal];
    }
    self.totalPriceLb.text = [NSString stringWithFormat:@"总计:￥%@", @(totalPrice)];
}

#pragma mark - 添加或删除菜品

- (IBAction)addDishesBthClick:(UIButton*)sender
{
    NSInteger section = sender.tag/10000;
    NSInteger row = sender.tag%10000;
    ZFDishesGroup *group = self.showData[section];
    ZFDishes *dishes = group.dishes[row];
    [self billAddPriceDishes:dishes];
    [self.listCollectionView reloadData];
    [self reloadStatisticsData];
}
- (IBAction)subDishesBthClick:(UIButton*)sender
{
    NSInteger section = sender.tag/10000;
    NSInteger row = sender.tag%10000;
    ZFDishesGroup *group = self.showData[section];
    ZFDishes *dishes = group.dishes[row];
    [self billSubPriceDishes:dishes];
    [self.listCollectionView reloadData];
    [self reloadStatisticsData];
}

- (void)billAddPriceDishes:(ZFDishes*)dishes
{
    ZFDishes *price = self.selectDishes[dishes.identifier];
    if (!price) {
        price = dishes.mutableCopy;
        price.count = 0;
        [self.selectDishes setObject:price forKey:price.identifier];
    }
    if ([self.selectDishesSort indexOfObject:price.identifier] == NSNotFound) {
        [self.selectDishesSort addObject:price.identifier];
    }
    price.count++;
}

- (void)billSubPriceDishes:(ZFDishes*)dishes
{
    ZFDishes *price = self.selectDishes[dishes.identifier];
    if (!price) {
        return;
    }
    price.count--;
    if (!price.count) {
        [self.selectDishes removeObjectForKey:price.identifier];
        [self.selectDishesSort removeObject:price.identifier];
    }
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.listCollectionView) {
        return self.showData.count;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.listCollectionView) {
        ZFDishesGroup *group = self.showData[section];
        return group.dishes.count;
    }
    return self.showData.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.listCollectionView) {
        ZFBillAddListCell *listcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFBillAddListCellId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.section];
        ZFDishes *dishes = group.dishes[indexPath.row];
        listcell.titleLb.text = dishes.name;
        listcell.priceLb.text = [NSString stringWithFormat:@"￥%@/%@",@(dishes.price),dishes.unit];
        
        ZFDishes *seleDishes = self.selectDishes[dishes.identifier];
        
        listcell.subBtn.hidden = YES;
        listcell.numberLb.hidden = YES;
        if (seleDishes.count > 0) {
            listcell.subBtn.hidden = NO;
            listcell.numberLb.hidden = NO;
            listcell.numberLb.text = @(seleDishes.count).stringValue;
            if (seleDishes.count >= 100) {
                listcell.numberLb.text = @"99+";
            }
        }
        NSInteger tag = indexPath.row + indexPath.section*10000;
        listcell.addBtn.tag = tag;
        listcell.subBtn.tag = tag;
        cell = listcell;
    }else{
        ZFBillAddListSectionCell *sectioncell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFBillAddListSectionCellId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.row];
        sectioncell.titleLb.text = group.name;
        cell = sectioncell;
    }
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.listCollectionView) {
        ZFBillAddListHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ZFBillAddListHeaderViewId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.section];
        view.titleLb.text = group.name;
        return view;
    }
    return nil;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds) - 1;
    CGFloat height = 40;
    if (collectionView == self.listCollectionView) {
        height = 70;
    }
    return CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.listCollectionView) {
        return;
    }
    NSInteger section = indexPath.row;
    NSIndexPath *indexParh = [NSIndexPath indexPathForRow:0 inSection:section];
    UICollectionViewLayoutAttributes *attributes=[self.listCollectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexParh];
    
    [self.listCollectionView setContentOffset:attributes.frame.origin animated:YES];
    
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
