//
//  ZFBillPriceSystomViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillPriceSystomViewController.h"
#import "Macro.h"

@interface ZFBillPriceSystomCell : UITableViewCell

@end

@implementation ZFBillPriceSystomCell

-(void)awakeFromNib
{
    [super awakeFromNib];
}
@end

@interface ZFBillPriceSystomViewController ()
@property (nonatomic,weak) IBOutlet UITableView *tableView;

@end

@implementation ZFBillPriceSystomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    // Do any additional setup after loading the view.
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint loc = [[touches anyObject] locationInView:self.view];
    if (!CGRectContainsPoint(self.tableView.superview.frame, loc)) {
        [self.view removeFromSuperview];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFBillPriceSystomCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFBillPriceSystomCellId" forIndexPath:indexPath];
    
    ZFPriceSystom *systom = self.showData[indexPath.row];
    if ([self.selectSystom.identifier isEqualToString:systom.identifier]) {
        cell.textLabel.textColor = UICOLOR_HEX(0x50C8EF);
    }else{
        cell.textLabel.textColor = UICOLOR_HEX(0x333333);
    }
    cell.textLabel.text = systom.name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFPriceSystom *systom = self.showData[indexPath.row];
    if ([self.selectSystom.identifier isEqualToString:systom.identifier]) {
        return;
    }
    self.selectSystom = systom;
    if (self.complete) {
        self.complete(systom);
    }
    [self.view removeFromSuperview];
}


@end
