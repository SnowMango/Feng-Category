//
//  ZFDishesGroupEditViewController.m
//  yang
//
//  Created by zhengfeng on 2018/2/2.
//  Copyright © 2018年 zhengfeng. All rights reserved.
//

#import "ZFDishesGroupEditViewController.h"
#import "ZFDishesEditViewController.h"
#import "ZFDishes.h"
#import "ZFLocalDataManager.h"
#import "SVProgressHUD.h"

@interface  ZFDishesGroupEditCell : UITableViewCell


@end

@implementation ZFDishesGroupEditCell
-(void)awakeFromNib
{
    [super awakeFromNib];
    
}
@end

@interface ZFDishesGroupEditViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    ZFDishesEditViewController *editDishesVC;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (strong, nonatomic) NSMutableArray *showData;
@end

@implementation ZFDishesGroupEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]  style:0 target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];

    self.nameTF.text = self.editGroup.name;
    self.deleteBtn.hidden = !self.editGroup.name;
    self.nameTF.delegate = self;
    self.showData = [NSMutableArray arrayWithArray:self.editGroup.dishes];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addDishesClick:(id)sender {
    [self showEditDishes:nil];
}
- (IBAction)doneBtn:(id)sender
{
    ZFDishesGroup *save = self.editGroup.mutableCopy;
    if (self.nameTF.text.length) {
        save.name = self.nameTF.text;
    }
    save.dishes = self.showData;
    BOOL ret = [[ZFLocalDataManager shareInstance] saveDishesGroup:save];
    if (!ret) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        [SVProgressHUD dismissWithDelay:0.5];
        return;
    }
    self.editGroup.name = save.name;
    self.editGroup.dishes = save.dishes;
    if (self.compelte) {
        self.compelte(YES);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteGroupClick:(id)sender
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"\n删除会丢失菜品\n且需要重新保存相关定价" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        BOOL ret = [[ZFLocalDataManager shareInstance] deleteDishesGroup:weakSelf.editGroup];
        if (!ret) {
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
            [SVProgressHUD dismissWithDelay:0.5];
            return;
        }
        if (weakSelf.deleteGroup) {
            weakSelf.deleteGroup(YES);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)showEditDishes:(ZFDishes*)dishes
{
    ZFDishes *editDishes = dishes;
    if (!editDishes) {
        editDishes = [[ZFDishes alloc] init];
        editDishes.group = self.editGroup;
    }
    editDishesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZFDishesEditViewController"];
    editDishesVC.editDishes = editDishes;
    __weak typeof(self)weakSelf = self;
    
    editDishesVC.compelte = ^(BOOL finish) {
        if (finish) {
            if (!dishes) {
                [weakSelf.showData addObject:editDishes];
            }
            [weakSelf.listTableView reloadData];
        }
    };
    
    [self.view.window addSubview:editDishesVC.view];
}

- (void)deleteDishes:(ZFDishes *)dishes
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"\n删除菜品需要重新保存相关定价" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取 消" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"确 定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        [weakSelf.showData removeObject:dishes];
        [weakSelf.listTableView reloadData];
    }]];
    
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFDishesGroupEditCell*cell = [tableView dequeueReusableCellWithIdentifier:@"ZFDishesGroupEditCellId" forIndexPath:indexPath];
    ZFDishes *dishes = self.showData[indexPath.row];
    cell.textLabel.text = dishes.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"计价单位：%@",dishes.unit];
    return cell;
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        ZFDishes *dishes = self.showData[indexPath.row];
        if (!self.editGroup.name) {
            [self.showData removeObject:dishes];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }else{
            [self deleteDishes:dishes];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFDishes *dishes = self.showData[indexPath.row];
    [self showEditDishes: dishes];
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


@end
