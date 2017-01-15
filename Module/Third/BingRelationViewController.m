//
//  BingRelationViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import "BingRelationViewController.h"
#import "CoreDataManager.h"
#import "EntityHeader.h"


@interface BingRelationViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray * teachers;
@property (nonatomic, strong) NSArray * students;

@property (nonatomic) BOOL isTeacherOfInfo;
@end

@implementation BingRelationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    self.title = @"relation";
    self.teachers = [[CoreDataManager shareInstance] readObjectsWithEntityName:@"Teacher" sorts:nil predicate:nil];
    self.students = [[CoreDataManager shareInstance] readObjectsWithEntityName:@"Student" sorts:nil predicate:nil];
    
    if ([self.info isKindOfClass:[Teacher class]]){
        self.isTeacherOfInfo = YES;
    }
    [self updateInfoLabel];
    
}
- (void)updateInfoLabel
{
    NSString *text = nil;
    if ([self.info isKindOfClass:[Teacher class]]){
        text = @"Teacher";
        Teacher*t = (Teacher *)self.info;
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"name",t.name];
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"age",t.age];
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"subject",t.subject];
    }else{
        text = @"Student";
        Student *s = (Student *)self.info;
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"name",s.name];
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"age",s.age];
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"grade",s.grade];
        text = [NSString stringWithFormat:@"%@\n%@:%@",text,@"teacher",s.teacher.name];
    }

    self.infoLabel.text = text;
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isTeacherOfInfo) {
        return self.students.count;
    }else{
        return self.teachers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][0];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    BOOL selected = NO;
    if (self.isTeacherOfInfo) {
        Teacher *t = (Teacher *)self.info;
        Student *s =  self.students[indexPath.row];
        cell.textLabel.text = s.name;
        NSString *detail = nil;
        if (s.teacher) {
            detail= s.teacher.name;
        }else{
            detail = s.grade;
        }
        selected = [t.students containsObject:s];
        cell.detailTextLabel.text = detail;
    }else{
        Student *s = (Student *)self.info;
        Teacher *t =  self.teachers[indexPath.row];
        cell.textLabel.text = t.name;
        cell.detailTextLabel.text = t.subject;
        selected = [s.teacher isEqual:t];
    }
    if (selected) {
        cell.backgroundColor = [UIColor redColor];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id data = nil;
    if (self.isTeacherOfInfo) {
        data = self.students[indexPath.row];
        Teacher *t = (Teacher *)self.info;
        NSMutableSet *mset = [NSMutableSet setWithSet:t.students];
        [mset addObject:data];
        t.students = mset;
    }else{
        data = self.teachers[indexPath.row];
        Student *s = (Student *)self.info;
        s.teacher = data;
    }
    [self updateInfoLabel];
    
    [tableView reloadData];
}

@end
