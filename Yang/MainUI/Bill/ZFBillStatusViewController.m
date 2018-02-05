//
//  ZFBillStatusViewController.m
//  yang
//
//  Created by zhengfeng on 2018/1/31.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFBillStatusViewController.h"

@interface ZFBillStatusCell : UITableViewCell

@end

@implementation ZFBillStatusCell

-(void)awakeFromNib
{
    [super awakeFromNib];
}
@end


@interface ZFBillStatusViewController ()
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@end

@implementation ZFBillStatusViewController

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
    ZFBillStatusCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFBillStatusCellId" forIndexPath:indexPath];
    
    ZFBillStatus *status = self.showData[indexPath.row];
    if ([self.selectStatus.identifier isEqualToString:status.identifier]) {
        cell.textLabel.textColor = [UIColor colorWithRed:80.0/255 green:200.0/255 blue:239.0/255 alpha:1];
        
    }else{
        cell.textLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1];
    }
    cell.textLabel.text = status.name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFBillStatus *status = self.showData[indexPath.row];
    if ([self.selectStatus.identifier isEqualToString:status.identifier]) {
        return;
    }
    self.selectStatus = status;
    if (self.complete) {
        self.complete(status);
    }
    [self.view removeFromSuperview];
}



@end
