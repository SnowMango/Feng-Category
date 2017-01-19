//
//  ToolsViewController.m
//  OneApplication
//
//  Created by zhengfeng on 17/1/13.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ToolsViewController.h"
#import <Module.h>

@interface ToolsViewController ()
@property (nonatomic, strong) NSMutableArray *tool;
@end

@implementation ToolsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ModuleHandle * handle = [ModuleHandle handleWithClass:[ToolModule class]];
    [ModuleManager addModuleHandle:handle];
    self.tool = [NSMutableArray arrayWithArray:handle.modules];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tool.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][3];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    ToolModule * f = self.tool[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.text = f.title;
    cell.detailTextLabel.text = f.detail;
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToolModule *tool = self.tool[indexPath.row];
    tool.rootViewController.hidesBottomBarWhenPushed = YES;
    tool.rootViewController.title = tool.title;
    [self.navigationController  pushViewController:tool.rootViewController animated:YES];
}

@end
