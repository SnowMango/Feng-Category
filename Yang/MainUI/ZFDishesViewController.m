//
//  ZFDishesViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/30.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFDishesViewController.h"
#import "ZFDishesGroup.h"
#import "ZFDishes.h"
#import "ZFDishesEditViewController.h"
#import "ZFDishesGroupEditViewController.h"
#import "Macro.h"

#import "ZFLocalDataManager.h"

@interface ZFDishesListHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@end

@implementation ZFDishesListHeaderView
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFDishesListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *detailLb;

@end

@implementation ZFDishesListCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end
@interface ZFDishesListSectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@end

@implementation ZFDishesListSectionCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end


@interface ZFDishesViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    ZFDishesEditViewController *editDishesVC;
}
@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *sectionCollectionView;

@property (strong, nonatomic) NSMutableArray *showData;

@end

@implementation ZFDishesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showData = [NSMutableArray arrayWithArray:[ZFLocalDataManager shareInstance].allDishesGroup];
//饿了么  美团外卖  堂吃
}

- (void)showEditDishes:(ZFDishes*)dishes
{
    editDishesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFDishesEditViewController"];
    editDishesVC.editDishes = dishes;
    __weak typeof(self)weakSelf = self;
    editDishesVC.compelte = ^(BOOL finish) {
        if (finish) {
            [[ZFLocalDataManager shareInstance] saveDishesGroup:dishes.group];
            [weakSelf.listCollectionView reloadData];
            [weakSelf.sectionCollectionView reloadData];
        }
    };
    [self.view.window addSubview:editDishesVC.view];
    
}

- (IBAction)addDishesGroup
{
    [self performSegueWithIdentifier:@"editGroup" sender:nil];
}

- (IBAction)editDishesGroupClick:(UIButton*)sender
{
    ZFDishesGroup *group = self.showData[sender.tag];
    [self performSegueWithIdentifier:@"editGroup" sender:group];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editGroup"]) {
        ZFDishesGroup *editDishesGroup = sender;
        if (!sender) {
            editDishesGroup = [[ZFDishesGroup alloc] init];
        }
        ZFDishesGroupEditViewController*vc =segue.destinationViewController;
        vc.editGroup = editDishesGroup;
        __weak typeof(self)weakSelf = self;
        vc.compelte = ^(BOOL finish) {
            if (finish) {
                if (!sender) {
                    [self.showData addObject:editDishesGroup];
                }
                [weakSelf.listCollectionView reloadData];
                [weakSelf.sectionCollectionView reloadData];
            }
        };
        vc.deleteGroup = ^(BOOL finish) {
            if (finish) {
                if (sender) {
                    [self.showData removeObject:sender];
                }
                [weakSelf.listCollectionView reloadData];
                [weakSelf.sectionCollectionView reloadData];
            }
        };
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
        return group.dishes.count ;
    }
    return self.showData.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.listCollectionView) {
        ZFDishesListCell *listcell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFDishesListCellId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.section];
        ZFDishes *dishes = group.dishes[indexPath.row];
        listcell.titleLb.text =  dishes.name;
        listcell.detailLb.text = [NSString stringWithFormat:@"计价单位:%@",dishes.unit];
        cell = listcell;
    }else{
        ZFDishesListSectionCell *sectioncell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFDishesListSectionCellId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.row];
        sectioncell.titleLb.text = group.name;
        
        cell = sectioncell;
    }
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.listCollectionView) {
        ZFDishesListHeaderView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ZFDishesListHeaderViewId" forIndexPath:indexPath];
        ZFDishesGroup *group = self.showData[indexPath.section];
        view.titleLb.text = group.name;
        view.editBtn.tag = indexPath.section;
        return view;
    }
    return nil;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = CGRectGetWidth(collectionView.bounds);
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
        
        [self showEditDishes:dishes];
        return;
    }
    if (indexPath.row == self.showData.count) {
        
    }else{
        NSInteger section = indexPath.row;
        NSIndexPath *indexParh = [NSIndexPath indexPathForRow:0 inSection:section];
        UICollectionViewLayoutAttributes *attributes=[self.listCollectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexParh];
        
        [self.listCollectionView setContentOffset:attributes.frame.origin animated:YES];
    }
}

@end
