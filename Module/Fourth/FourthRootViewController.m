//
//  FourthRootViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/14.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "FourthRootViewController.h"

@interface FourthRootViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSArray *sources;

@end

@implementation FourthRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    self.sources = @[@{@"System":@"system"}, @{@"Custom":@"custom"}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][3];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * s = self.sources[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.text = s.allKeys.firstObject;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * s = self.sources[indexPath.row];
    [self performSegueWithIdentifier:s.allValues.firstObject sender:nil];
}

@end
