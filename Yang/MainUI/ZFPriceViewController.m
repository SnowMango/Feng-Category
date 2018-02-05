//
//  ZFPriceViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFPriceViewController.h"
#import "ZFPricePageViewController.h"
#import "ZFPriceListViewController.h"
#import "ZFPriceSystom.h"
#import "Macro.h"

#import "ZFPriceSettingViewController.h"
#import "ZFPriceSystomEditViewController.h"
#import "ZFLocalDataManager.h"

@interface ZFPriceViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@end

@implementation ZFPriceViewCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFPriceViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    ZFPricePageViewController *pageVC;
    NSMutableArray *pages;
}

@property (weak, nonatomic) IBOutlet UICollectionView *priceSystom;
@property (weak, nonatomic) IBOutlet UIView *contianerView;

@property (strong, nonatomic) NSMutableArray *systoms;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSString * currentIdentifier;
@end

@implementation ZFPriceViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pageVC = self.childViewControllers.firstObject;
    pageVC.delegate = self;
    pageVC.dataSource = self;
    self.systoms = [NSMutableArray arrayWithArray:[ZFLocalDataManager shareInstance].allPriceSystom];
    [self updatePageData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePriceSystomNotication:)
                                                 name:kPriceSystomNeedUpdateUINotification object:nil];
}

- (IBAction)addPriceSystomClick:(id)sender {
    [self performSegueWithIdentifier:@"showAddSystom" sender:nil];
}

- (void)updatePriceSystomNotication:(NSNotification *)notification
{
    self.systoms = [NSMutableArray arrayWithArray:[ZFLocalDataManager shareInstance].allPriceSystom];
    [self updatePageData];
}


- (void)updatePageData
{
    pages = [NSMutableArray array];
    self.currentIndex = 0;
    for (int i = 0; i < self.systoms.count; i++) {
        ZFPriceSystom * item = self.systoms[i];
        if ([item.identifier isEqualToString:self.currentIdentifier]) {
            self.currentIndex = i;
        }
        ZFPriceListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFPriceListViewController"];
        vc.items = item;
        [pages addObject:vc];
    }
    
    if (self.systoms.count) {
        ZFPriceSystom * item = self.systoms[self.currentIndex];
        self.currentIdentifier = item.identifier;
        self.contianerView.hidden = NO;
        [pageVC setViewControllers:@[pages[self.currentIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }else{
        self.contianerView.hidden = YES;
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"priceSetting"]) {
        ZFPriceSettingViewController *vc = segue.destinationViewController;
        vc.systoms = sender;
        __weak typeof(self)weakSelf = self;
        vc.didEdit = ^(NSArray *systoms) {
            weakSelf.systoms = [NSMutableArray arrayWithArray:systoms];
            [weakSelf updatePageData];
            [weakSelf.priceSystom reloadData];
        };
    }else if ([segue.identifier isEqualToString:@"showAddSystom"]) {
        
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
                    [weakSelf.systoms addObject:editPriceSystom];
                }
                [weakSelf updatePageData];
                [weakSelf.priceSystom reloadData];
            }
        };
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.systoms.count ? self.systoms.count +1 : 0;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFPriceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFPriceViewCellId" forIndexPath:indexPath];
    cell.titleLb.textColor = UICOLOR_HEX(0x333333);
    cell.contentView.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == self.systoms.count) {
        cell.titleLb.text = @"";
        cell.iconIV.image = [UIImage imageNamed:@"move_add"];
    }else{
        cell.iconIV.image = nil;
        ZFPriceSystom *systom = self.systoms[indexPath.row];
        cell.titleLb.text = systom.name;
        if (self.currentIndex == indexPath.row) {
            
            cell.titleLb.textColor = [UIColor whiteColor];
            cell.contentView.backgroundColor = UICOLOR_HEX(0x50C8EF);
        }
    }
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 100;
    CGFloat height = CGRectGetHeight(collectionView.bounds);
    return CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.systoms.count) {
        [self performSegueWithIdentifier:@"priceSetting" sender:self.systoms];
        return;
    }
    if (self.currentIndex == indexPath.row) {
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (self.currentIndex > indexPath.row) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    self.currentIndex = indexPath.row;
    [collectionView reloadData];
    [pageVC setViewControllers:@[pages[indexPath.row]] direction:direction animated:YES completion:nil];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [pages indexOfObject:viewController];
    if (index == 0 || index == NSNotFound ) {
        return nil;
    }
    index--;
    return pages[index];
}
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [pages indexOfObject:viewController];
    if (index == pages.count - 1 || index == NSNotFound ) {
        return nil;
    }
    index++;
    return pages[index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    NSInteger index = [pages indexOfObject:[pendingViewControllers firstObject]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    self.currentIndex = index;
    [self.priceSystom reloadData];
    [self.priceSystom selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}


@end
