//
//  LZFCalendarView.m
//  LayoutTest
//
//  Created by zhengfeng on 2017/9/8.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "LZFCalendarView.h"


#define CELL_HEIGHT 40
#define HEADER_HEIGHT 50
#define TITLE_HEIGHT 32

#define CACHE_COUNT 5

@interface LZFCalendarView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView * headerView;
@property (nonatomic, strong) UICollectionView *calendarView;

@property (nonatomic, strong) NSArray *headerItems;
@property (nonatomic, strong) NSDate *currentMidMonth;
@property (nonatomic) CGFloat org;

@property (nonatomic, strong) NSMutableArray *monthList;
@property (nonatomic, strong) NSMutableArray *selectDayList;

@end

@implementation LZFCalendarView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupProperty];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupUI];
    [self setupProperty];
}

- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), TITLE_HEIGHT)];
    self.headerView.backgroundColor = [UIColor clearColor];
    [self addSubview: self.headerView];
    NSArray *titles = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    
    CGFloat weekH = CGRectGetHeight(self.headerView.frame);
    CGFloat offset = (int)CGRectGetWidth(self.frame)%7/2.0;
    CGFloat weekW = ceilf(CGRectGetWidth(self.headerView.frame)/7.0) - 1;
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < titles.count; i++) {
        UILabel *week = [[UILabel alloc] initWithFrame:CGRectMake(offset + i*weekW, 0, weekW, weekH)];
        week.textAlignment = NSTextAlignmentCenter;
        week.textColor = [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];
        week.text = titles[i];
        week.font = [UIFont systemFontOfSize:14];
        [self.headerView addSubview:week];
        [temp addObject:week];
    }
    self.headerItems = temp;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 10.0;
    flowLayout.minimumInteritemSpacing = 0;
    CGRect rect = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.headerView.frame));
    self.calendarView = [[UICollectionView alloc] initWithFrame:rect
                                           collectionViewLayout:flowLayout];
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    [self.calendarView registerClass:[LZFCalendarCell class] forCellWithReuseIdentifier:@"CalendarCellId"];
    [self.calendarView registerClass:[LZFCalendarHeaderCell class]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CalendarHeaderId"];
    self.calendarView.backgroundColor = [UIColor whiteColor];
    self.calendarView.showsVerticalScrollIndicator = NO;
    self.calendarView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.calendarView];
    [self bringSubviewToFront:self.headerView];
}

- (void)setupProperty
{
   self.startDate = [NSDate date];
   self.fireDate = [NSDate distantPast];
   self.calendarSelectType = LZFCalendarViewSelectionMultiple;
   self.selectDayList = [NSMutableArray array];
}

- (void)setCalendarSelectType:(LZFCalendarViewSelectionType)calendarSelectType
{
   _calendarSelectType = calendarSelectType;
   self.calendarView.allowsMultipleSelection = _calendarSelectType;
}

- (NSMutableArray *)selectDayList
{
   if (!_selectDayList) {
      self.selectDayList = [NSMutableArray array];
   }
   return _selectDayList;
}

- (void)addSelectDay:(NSDate *)day
{
    [self.selectDayList addObject:day];

}
- (void)removeSelectDay:(NSDate *)day
{
    [self.selectDayList removeObject:day];
}

- (void)addSelectDays:(NSArray *)days
{
    [self.selectDayList addObjectsFromArray:days];
}
- (void)removeSelectDays:(NSArray *)days
{
    [self.selectDayList removeObjectsInArray:days];
}


- (NSArray *)currentSelectDays
{
   return self.selectDayList;
}

- (void)loadMonthData:(NSDate *)midMonth
{
   self.monthList = [NSMutableArray array];
   self.currentMidMonth = midMonth;
   NSDate *oneDay = [midMonth firstDayOfMonth];
   NSInteger mid = floor(CACHE_COUNT/2.0);
   for (int i = 0; i < CACHE_COUNT; i++) {
      [self.monthList addObject:[oneDay addMonths:i - mid]];
   }
}

- (void)updateCalendarView
{
   [self.calendarView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.calendarView.contentInset = UIEdgeInsetsZero;
    [self updateSubviewsLayout];
}

-(void)setStartDate:(NSDate *)startDate
{
   _startDate = startDate;
   [self loadMonthData:_startDate];
   CGFloat headerH = HEADER_HEIGHT;
   NSIndexPath *fistIndex = [NSIndexPath indexPathForRow:0 inSection:floor(CACHE_COUNT/2.0)];
   CGRect f = [self.calendarView layoutAttributesForItemAtIndexPath:fistIndex].frame;
   CGFloat top = CGRectGetMinY(f);
   self.org = top - headerH - 20;
   self.calendarView.contentOffset = CGPointMake(0, self.org);
}

- (void)updateSubviewsLayout
{
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), TITLE_HEIGHT);
    self.calendarView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.headerView.frame));
    CGFloat weekW = ceilf(CGRectGetWidth(self.headerView.frame)/7.0) - 1;
    CGFloat weekH = CGRectGetHeight(self.headerView.frame);
    CGFloat offset = (int)CGRectGetWidth(self.calendarView.frame)%7/2.0;
    [self.headerItems enumerateObjectsUsingBlock:^(UILabel *week, NSUInteger idx, BOOL * _Nonnull stop) {
        week.frame = CGRectMake(offset+ idx*weekW, 0, weekW, weekH);
    }];
}

- (BOOL)isContentDay:(NSDate *)day
{
    NSCalendar *ca = [NSCalendar currentCalendar];
    for (NSDate *date in self.selectDayList) {
        if ([ca isDate:day inSameDayAsDate:date]) {
            return YES;
        }
    }
    return NO;
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
   return self.monthList.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   NSDate *month = self.monthList[section];
   NSInteger weak = [month numberOfWeeks];
   return weak*7;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   LZFCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCellId" forIndexPath:indexPath];
   
   NSDate *month = self.monthList[indexPath.section];
   NSInteger weak = [month weeklyOrdinality] - 1;
    if (weak == 0) {
        weak = 7;
    }
   NSDate *day =  [month addDays:indexPath.row - weak];
   if (indexPath.row >= weak && month.month == day.month) {
      cell.cellDay = day;
      NSTimeInterval max = MAX(self.startDate.timeIntervalSince1970, self.fireDate.timeIntervalSince1970);
      NSTimeInterval min = MIN(self.startDate.timeIntervalSince1970, self.fireDate.timeIntervalSince1970);
      if (cell.cellDay.timeIntervalSince1970 < min || cell.cellDay.timeIntervalSince1970 > max) {
         cell.userInteractionEnabled = NO;
      }else{
         cell.userInteractionEnabled = YES;
      }
      if ([self isContentDay:cell.cellDay]) {
         [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:0];
         cell.selected = YES;
      }
       if ([[NSCalendar currentCalendar] isDate:day inSameDayAsDate:[NSDate date]]) {
           cell.selectIV.hidden = cell.selected;
       }else{
           cell.selectIV.hidden = YES;
       }
   }else{
      cell.cellDay = nil;
       cell.selectIV.hidden = YES;
   }
   return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LZFCalendarHeaderCell*view= [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CalendarHeaderId" forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
       NSDate *month = self.monthList[indexPath.section];
       view.cellMonth = month;
    }
    return view;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = ceilf(CGRectGetWidth(collectionView.frame)/7.0) - 1;
    CGFloat height = CELL_HEIGHT;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat offset = (int)CGRectGetWidth(collectionView.frame)%7/2.0;
    return UIEdgeInsetsMake(0, offset, 0, offset);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat width = CGRectGetWidth(collectionView.frame);
    CGFloat height = HEADER_HEIGHT;
    return CGSizeMake(width, height);
}

#pragma mark - UICollectionViewDelegate
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LZFCalendarCell *cell = (LZFCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectDayList addObject:cell.cellDay];
    if (self.selectDay) {
        self.selectDay(cell.cellDay);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
   LZFCalendarCell *cell = (LZFCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
   [self.selectDayList removeObject:cell.cellDay];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LZFCalendarCell *cell = (LZFCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.cellDay) {
        return NO;
    }
    NSTimeInterval max = MAX(self.startDate.timeIntervalSince1970, self.fireDate.timeIntervalSince1970);
    NSTimeInterval min = MIN(self.startDate.timeIntervalSince1970, self.fireDate.timeIntervalSince1970);
    if (cell.cellDay.timeIntervalSince1970 < min || cell.cellDay.timeIntervalSince1970 > max) {
        return NO;
    }
    return YES;
}

- (void)scrollViewDidScroll:(UICollectionView *)scrollView
{
    //floor(CACHE_COUNT/2.0)
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)scrollView.collectionViewLayout;
    CGFloat changeSize = (CELL_HEIGHT+layout.minimumLineSpacing)*5 - layout.minimumLineSpacing + HEADER_HEIGHT;//cell heeght + line + header
    CGFloat sub = self.calendarView.contentOffset.y - self.org;
    if (changeSize <= fabs(sub) ) {
        BOOL upOrDown = scrollView.contentOffset.y > self.org;
        if (upOrDown) {
           [self loadMonthData:[self.currentMidMonth addMonths:1]];
        }else{
            [self loadMonthData:[self.currentMidMonth addMonths:-1]];
        }
        [self.calendarView reloadData];
        self.calendarView.contentOffset = CGPointMake(0, self.org + fabs(sub) - changeSize);
    }
}

@end

static UIImage *todayImage = nil;
@implementation LZFCalendarCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    CGFloat size = MIN(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    self.selectIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    self.selectIV.contentMode = UIViewContentModeCenter;
    if (!todayImage) {
        todayImage = [self tadayImage];
    }
    self.selectIV.hidden = YES;
    self.selectIV.image = todayImage;
    self.selectIV.center = self.contentView.center;
    [self.contentView addSubview:self.selectIV];
    self.solar = [[UILabel alloc] init];
    self.solar.font = [UIFont systemFontOfSize:14];
    self.solar.textColor = [self normalColor];
    self.solar.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.solar];
    self.Lunar = [[UILabel alloc] init];
    self.Lunar.font = [UIFont systemFontOfSize:10];
    self.Lunar.textColor = [self normalColor];
    self.Lunar.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.Lunar];
}

- (void)setSelected:(BOOL)selected
{
   [super setSelected:selected];
   if (!self.userInteractionEnabled) {
      return;
   }
   if (self.cellDay == nil) {
        return;
    }
   if (self.selected) {
      self.solar.textColor = [self selcetColor];
      self.Lunar.textColor = [self selcetColor];
   }else{
      self.solar.textColor = [self normalColor];
      self.Lunar.textColor = [self normalColor];
   }
}

- (UIImage*)tadayImage
{
    CGFloat height = MIN(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    CGSize size = CGSizeMake(height, height);
    UIGraphicsBeginImageContext(size);
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    bezier.lineWidth = 1;
    CGFloat radius = size.width/2.0 -bezier.lineWidth;
    [bezier addArcWithCenter:CGPointMake(size.width/2.0, size.height/2.0) radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    [[self selcetColor] setStroke];
    [bezier stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
   [super setUserInteractionEnabled:userInteractionEnabled];
   if (self.cellDay == nil) {
       return;
   }
   if (self.userInteractionEnabled) {
      if (self.selected) {
         self.solar.textColor = [self selcetColor];
         self.Lunar.textColor = [self selcetColor];
      }else{
         self.solar.textColor = [self normalColor];
         self.Lunar.textColor = [self normalColor];
      }
   }else{
      self.solar.textColor = [self noEnabledbleColer];
      self.Lunar.textColor = [self noEnabledbleColer];
   }
}

- (UIColor *)normalColor
{
   return  [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
}

- (UIColor *)selcetColor
{
   return  [UIColor colorWithRed:80.0/255 green:200.0/255 blue:239.0/255 alpha:1];
}
- (UIColor *)noEnabledbleColer
{
   return  [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1];
}


- (void)layoutSubviews
{
   [super layoutSubviews];
   CGFloat size = MIN(CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
   self.selectIV.frame = CGRectMake(0, 0, size, size);
   self.selectIV.center = self.contentView.center;
   self.solar.frame = CGRectMake(CGRectGetMidX(self.contentView.frame) - size/2.0,
                                 CGRectGetMidY(self.contentView.frame) - self.solar.font.lineHeight,
                                 size, self.solar.font.lineHeight);
   self.Lunar.frame = CGRectMake(CGRectGetMidX(self.contentView.frame) - size/2.0, CGRectGetMaxY(self.solar.frame),
                                 size, self.Lunar.font.lineHeight);
}

- (void)setCellDay:(NSDate *)cellDay
{
   _cellDay = cellDay;
   if (_cellDay) {
      self.Lunar.text = [self lunarTextWithDay:_cellDay];
      self.solar.text = [self solarTextWithDay:_cellDay];
   }else{
      self.Lunar.text = nil;
      self.solar.text = nil;
   }
   
}

- (NSString *)solarTextWithDay:(NSDate *)day
{
   NSCalendar *ca =[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
   NSDateComponents *com = [ca components:NSCalendarUnitDay fromDate:day];
   return @(com.day).stringValue;
}
- (NSString *)lunarTextWithDay:(NSDate *)day
{
   Lunar *l = [LZFCalendar solarToLunar:day];
   return [LZFCalendar lunarDays][l.lunarDay];
}

@end


@implementation LZFCalendarHeaderCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
   self.monthTitle = [[UILabel alloc] initWithFrame:self.bounds];
   self.monthTitle.font = [UIFont systemFontOfSize:14];
   self.monthTitle.textAlignment = NSTextAlignmentCenter;
   self.monthTitle.textColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
   [self addSubview:self.monthTitle];
}

- (void)layoutSubviews
{
   [super layoutSubviews];
   [self updateTitleWithMonth:self.cellMonth];
}

- (void)updateTitleWithMonth:(NSDate*)month
{
   if (self.cellMonth) {
      NSCalendar *ca =[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
      NSDateComponents *com = [ca components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:_cellMonth];
      NSString *text = [NSString stringWithFormat:@"%@年%@月",@([com year]),@([com month])];
      CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:self.monthTitle.font}];
      self.monthTitle.frame = CGRectMake(0, 0, size.width, size.height);
      CGFloat weekW = ceilf(CGRectGetWidth(self.bounds)/7.0) - 1;
      CGFloat weekH = CGRectGetHeight(self.frame);
      CGFloat offset = (int)CGRectGetWidth(self.frame)%7/2.0;
      NSInteger index = [_cellMonth weeklyOrdinality] - 1;
      CGRect r = CGRectMake(offset+ index*weekW, 0, weekW, weekH);
      self.monthTitle.text = text;
      
      if (CGRectGetMidX(r) + size.width/2.0 > CGRectGetWidth(self.bounds)) {
         self.monthTitle.center = CGPointMake(CGRectGetWidth(self.bounds) - size.width/2.0, CGRectGetMidY(self.bounds));
      }else if (CGRectGetMidX(r) > size.width/2.0) {
         self.monthTitle.center = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(self.bounds));
      }else{
         self.monthTitle.center = CGPointMake(size.width/2.0, CGRectGetMidY(self.bounds));
      }
      
   }else{
      self.monthTitle.text = nil;
   }
}

-(void)setCellMonth:(NSDate *)cellMonth
{
   _cellMonth = cellMonth;
   [self updateTitleWithMonth:_cellMonth];
}


@end











