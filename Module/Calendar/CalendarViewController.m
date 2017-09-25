//
//  CalendarViewController.m
//  DemoDev
//
//  Created by zhengfeng on 2017/8/17.
//
//

#import "CalendarViewController.h"

@interface CalendarViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSArray *tableData;
@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}





#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][0];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}


@end
