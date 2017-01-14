//
//  RootViewController.m
//  Demo
//
//  Created by zhengfeng on 16/11/4.
//
//

#import "RootViewController.h"
#import "ModuleManager.h"

@interface RootViewController ()
{
    NSDictionary *_dictCustomerProperty;
}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"MainBundle->%@", [NSBundle mainBundle].bundlePath);
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    
    ModuleHandle * example = [ModuleHandle handleWithClass:[ExampleModule class]];
    [ModuleManager addModuleHandle:example];
    
    ModuleHandle * tool = [ModuleHandle handleWithClass:[ToolModule class]];
    [ModuleManager addModuleHandle:tool];
    
    self.functions = [NSMutableArray arrayWithArray:example.modules];
    [self.functions addObjectsFromArray:tool.modules];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.functions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][3];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    Module * f = self.functions[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.text = f.title;
    cell.detailTextLabel.text = f.detail;
    cell.imageView.image = [UIImage imageNamed:f.loadingImage];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self.functions exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Module *function = self.functions[indexPath.row];
    function.rootViewController.title = function.title;
    [self.navigationController  pushViewController:function.rootViewController animated:YES];
}



@end
