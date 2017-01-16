//
//  ThirdViewController.m
//  DemoDev
//
//  Created by zhengfeng on 16/11/28.
//  Copyright © 2016年 zhengfeng. All rights reserved.
//

#import "ThirdViewController.h"
#import "CoreDataManager.h"
#import "EntityHeader.h"
#import "BingRelationViewController.h"
#import <CoreData/CoreData.h>

@interface ThirdViewController ()<UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray * teachers;
@property (nonatomic, strong) NSArray * students;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateData];
}

- (void)updateData
{
    self.teachers = [[CoreDataManager shareInstance] readObjectsWithEntityName:@"Teacher" sorts:nil predicate:nil];
    self.students = [[CoreDataManager shareInstance] readObjectsWithEntityName:@"Student" sorts:nil predicate:nil];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section) {
        return self.students.count;
    }
    return self.teachers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @[@"Basic",@"Value1",@"Value2",@"Subtitle"][1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section) {
        Student *s =  self.students[indexPath.row];
        cell.textLabel.text = s.name;
        NSString *detail = nil;
        if (s.teacher) {
            detail= s.teacher.name;
        }else{
            detail = s.grade;
        }
        cell.detailTextLabel.text = detail;
    }else{
        Teacher *t =  self.teachers[indexPath.row];
        cell.textLabel.text = t.name;
        cell.detailTextLabel.text = t.subject;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id deleteObj = indexPath.section? self.students[indexPath.row]:self.teachers[indexPath.row];
        [[CoreDataManager shareInstance].viewContext deleteObject:deleteObj];
        [self updateData];
        [[CoreDataManager shareInstance] synchronize];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id sender = indexPath.section? self.students[indexPath.row]:self.teachers[indexPath.row];
    [self performSegueWithIdentifier:@"reRelation" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reRelation"]) {
        BingRelationViewController * vc = [segue destinationViewController];
        vc.info = sender;
    }
}



@end
