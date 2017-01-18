//
//  ExampleViewController.m
//  OneApplication
//
//  Created by zhengfeng on 17/1/13.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ExampleViewController.h"
#import <Module.h>
#import "BaseJSON.h"
@interface ExampleViewController ()
@property (nonatomic, strong) NSMutableArray *example;
@end

@implementation ExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ModuleHandle * handle = [ModuleHandle handleWithClass:[ExampleModule class]];
    
    [ModuleManager addModuleHandle:handle];
    self.example = [NSMutableArray arrayWithArray:handle.modules];
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    self.tableView.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.example.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][3];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    ExampleModule * f = self.example[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.text = f.title;
    cell.detailTextLabel.text = f.detail;
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExampleModule *example = self.example[indexPath.row];
    example.rootViewController.hidesBottomBarWhenPushed = YES;
    example.rootViewController.title = example.title;
    [self.navigationController  pushViewController:example.rootViewController animated:YES];
}

@end
