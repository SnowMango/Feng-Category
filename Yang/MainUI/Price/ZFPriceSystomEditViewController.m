//
//  ZFPriceSystomEditViewController.m
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFPriceSystomEditViewController.h"
#import "Model.h"
#import "ZFLocalDataManager.h"
#import "SVProgressHUD.h"

@interface ZFPriceSystomEditHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLb;

@end

@implementation ZFPriceSystomEditHeaderView
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFPriceSystomEditCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *detailLb;

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@end

@implementation ZFPriceSystomEditCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFPriceSystomEditViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *showData;
@property (strong, nonatomic) NSMutableDictionary *allPriceDishes;
@property (strong, nonatomic) NSMutableDictionary *allDishesGroup;
@end

@implementation ZFPriceSystomEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showData = [ZFLocalDataManager shareInstance].allDishesGroup;
    
    self.allPriceDishes = [NSMutableDictionary dictionary];
    for (ZFDishesGroup* group in self.systom.group) {
        for (ZFDishes*pDishes in group.dishes) {
            if (pDishes) {
                [self.allPriceDishes setObject:pDishes forKey:pDishes.identifier];
            }
        }
    }
    self.allDishesGroup = [NSMutableDictionary dictionary];
    for (ZFDishesGroup* group in self.showData) {
        [self.allDishesGroup setObject:group forKey:group.identifier];
    }
    self.nameTF.text = self.systom.name;
    
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneBtn:(id)sender
{
    if (!self.nameTF.text.length) {
        [SVProgressHUD showErrorWithStatus:@"请输入名称"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    ZFPriceSystom *save = self.systom.mutableCopy;
    save.name = self.nameTF.text;
    NSMutableArray *group = [NSMutableArray array];
    for (ZFDishesGroup* dishesGroup in self.showData) {
        ZFDishesGroup *priceGroup = dishesGroup.mutableCopy;
        NSMutableArray *temp = [NSMutableArray array];
        for (ZFDishes*dishes in dishesGroup.dishes) {
            ZFDishes* priceDishes = self.allPriceDishes[dishes.identifier];
            if (priceDishes) {
                priceDishes.group = priceGroup;
                [temp addObject:priceDishes];
            }
        }
        if (temp.count) {
            priceGroup.dishes = temp;
            [group addObject:priceGroup];
        }
    }
    save.group = group;
    BOOL ret = [[ZFLocalDataManager shareInstance] savePriceSystom:save];
    if (!ret) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    self.systom.name = save.name;
    self.systom.group = save.group;
    if (self.compelte) {
        self.compelte(YES);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)removePriceDishesClick:(UIButton*)sender
{
    NSInteger section = sender.tag/10000;
    NSInteger row = sender.tag%10000;
    ZFDishesGroup *group = self.showData[section];
    ZFDishes *dishes = group.dishes[row];
    [self.allPriceDishes removeObjectForKey:dishes.identifier];
    [self.collectionView reloadData];
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
            [weakSelf.allPriceDishes setObject:pDishes forKey:pDishes.identifier];
            [weakSelf.collectionView reloadData];
        }
    }]];

    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.showData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ZFDishesGroup *group = self.showData[section];
    return group.dishes.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFPriceSystomEditCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFPriceSystomEditCellId" forIndexPath:indexPath];
    ZFDishesGroup *group = self.showData[indexPath.section];
    ZFDishes *dishes = group.dishes[indexPath.row];
    cell.titleLb.text =  dishes.name;
    cell.detailLb.text = [NSString stringWithFormat:@"计价单位:%@",dishes.unit];
    ZFDishes *pDishes = self.allPriceDishes[dishes.identifier];
    NSInteger tag = indexPath.row + indexPath.section*10000;
    cell.editBtn.hidden = YES;
    cell.editBtn.tag = tag;
    if (pDishes) {
        cell.editBtn.hidden = NO;
        cell.detailLb.text = [NSString stringWithFormat:@"￥%@/%@",@(pDishes.price), dishes.unit];
        [cell.editBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    }

    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ZFPriceSystomEditHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ZFPriceSystomEditHeaderViewId" forIndexPath:indexPath];
    ZFDishesGroup *group = self.showData[indexPath.section];
    view.titleLb.text = group.name;
    return view;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
    CGFloat height = 60;
    return CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFDishesGroup *group = self.showData[indexPath.section];
    ZFDishes *dishes = group.dishes[indexPath.row];
    ZFDishes *pDishes = self.allPriceDishes[dishes.identifier];
    if (!pDishes) {
        pDishes = dishes.mutableCopy;
    }
    [self changePriceWithDishes:pDishes];
}

#pragma mark -UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.nameTF == textField) {
        return YES;
    }
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
