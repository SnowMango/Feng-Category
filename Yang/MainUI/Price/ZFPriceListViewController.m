//
//  ZFPriceListViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFPriceListViewController.h"
#import "ZFDishesGroup.h"
#import "ZFDishes.h"

@interface ZFPriceListHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@end

@implementation ZFPriceListHeaderView
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFPriceListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
@end

@implementation ZFPriceListCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFPriceListSectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@end

@implementation ZFPriceListSectionCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end


@interface ZFPriceListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *sectionCollectionView;

@property (strong, nonatomic) NSMutableArray *showData;

@end

@implementation ZFPriceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showData = [NSMutableArray arrayWithArray:self.items.group];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

- (void)changePriceWithDishes:(ZFDishes *)pDishes
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"菜品价格" message:@"\n请输入菜品价格(￥):" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    __weak typeof(vc) weakVC = vc;
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = weakSelf;
        textField.placeholder = @(pDishes.price).stringValue;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = weakVC.textFields.firstObject;
        if (tf.text.length) {
            pDishes.price = tf.text.doubleValue;
            [weakSelf.listCollectionView reloadData];
        }
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
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
        ZFPriceListCell *listcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFPriceListCellId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.section];
        ZFDishes *dishes = group.dishes[indexPath.row];
        listcell.titleLb.text = dishes.name;
        listcell.priceLb.text = [NSString stringWithFormat:@"￥%@/%@",@(dishes.price),dishes.unit];
        cell = listcell;
    }else{
        ZFPriceListSectionCell *sectioncell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFPriceListSectionCellId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.row];
        sectioncell.titleLb.text = group.name;
        cell = sectioncell;
    }
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.listCollectionView) {
        ZFPriceListHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ZFPriceListHeaderViewId" forIndexPath:indexPath];
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
    CGFloat height = 44;
    if (collectionView == self.listCollectionView) {
        height = 50;
    }
    return CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.listCollectionView) {
        
        ZFDishesGroup *group = self.showData[indexPath.section];
        ZFDishes *dishes = group.dishes[indexPath.row];
        [self changePriceWithDishes:dishes];
        
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
