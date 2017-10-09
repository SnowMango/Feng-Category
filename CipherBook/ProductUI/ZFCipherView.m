//
//  ZFCipherView.m
//  CipherBook
//
//  Created by 郑丰 on 2017/10/2.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ZFCipherView.h"
#import "ZFCipherViewCell.h"
@interface ZFCipherView ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionViewFlowLayout *listLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *cardLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *fastLayout;
@end

@implementation ZFCipherView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubview];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupSubview];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updateSubview];
    
}

- (void)setupSubview
{
    self.listLayout = [[UICollectionViewFlowLayout alloc] init];
    self.listLayout.minimumLineSpacing = 10;
    self.listLayout.minimumInteritemSpacing = 0;
    self.listLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), 60);
    self.listLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.cardLayout = [[UICollectionViewFlowLayout alloc] init];
    self.cardLayout.minimumLineSpacing = 0;
    self.cardLayout.minimumInteritemSpacing = 0;
    self.cardLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.cardLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.fastLayout = [[UICollectionViewFlowLayout alloc] init];
    self.fastLayout.minimumLineSpacing = 0;
    self.fastLayout.minimumInteritemSpacing = 0;
    self.fastLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds)/4.0, CGRectGetWidth(self.bounds)/4.0);
    self.fastLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

    NSArray *arr = @[self.listLayout, self.cardLayout,self.fastLayout];
    self.itemsView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:arr[self.style]];
    [self.itemsView registerClass:[ZFCipherViewCell class]
       forCellWithReuseIdentifier:@"CellId"];
    self.itemsView.delegate = self;
    self.itemsView.dataSource = self;
    self.itemsView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:self.itemsView];
}

- (void)updateSubview
{
    self.itemsView.frame = self.bounds;
}


- (void)setStyle:(ZFCipherViewStyle)style
{
    _style = style;
    NSArray *arr = @[self.listLayout, self.cardLayout,self.fastLayout];
    [self.itemsView setCollectionViewLayout:arr[self.style] animated:YES];
    self.itemsView.pagingEnabled = _style&ZFCipherViewStyleCard;
}

- (void)reloadData
{
    [self.itemsView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFCipherViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    cell.clipher = self.items[indexPath.row];
    return cell;
}
#pragma mark - UICollectionViewDelegate

@end
