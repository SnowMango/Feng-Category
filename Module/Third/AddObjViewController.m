//
//  AddObjViewController.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import "AddObjViewController.h"
#import "CoreDataManager.h"
#import "EntityHeader.h"
#import "BingRelationViewController.h"
@interface AddObjViewController ()<UITextFieldDelegate>

@property (nonatomic, assign) NSString *classString;
@end

@implementation AddObjViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)addTeacher:(id)sender {
    self.classString = @"Teacher";
    [self showInputHumanInfo];
}

- (IBAction)addStudent:(id)sender {
    self.classString = @"Student";
    [self showInputHumanInfo];
}

- (void)showInputHumanInfo
{
    UIAlertController *vc =[UIAlertController alertControllerWithTitle:@"Input" message:@"People Info" preferredStyle:YES];

    NSMutableArray * keys = [[Human propertykeys] mutableCopy];
    if ([self.classString isEqualToString:@"Teacher"]) {
        [keys addObjectsFromArray:[Teacher propertykeys]];
        [keys removeObject:@"students"];
        vc.message = @"Teacher Info";
    }else{
        [keys addObjectsFromArray:[Student propertykeys]];
        [keys removeObject:@"teacher"];
        vc.message = @"Student Info";
    }
    [keys enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = obj;
            if (idx == keys.count - 1) {
                textField.delegate = self;
                textField.tag = NSIntegerMax;
            }
        }];
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == NSIntegerMax) {
        UIAlertController *vc = (UIAlertController *)self.navigationController.visibleViewController;
        if (![vc isKindOfClass:[UIAlertController class]]) {
            return;
        }
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        BOOL infoValid = YES;
        for (int i = 0; i < vc.textFields.count; i++) {
            UITextField * tf = vc.textFields[i];
            NSString * value = tf.text;
            if (!value.length ) {infoValid = NO;break;}
            data[tf.placeholder] = value;
        }
        data[@"age"] =  @([data[@"age"] integerValue]);
        [vc dismissViewControllerAnimated:YES completion:^{
            if (infoValid) {
                id sender = [[CoreDataManager shareInstance] writeObjectWithEntityName:self.classString forData:data];
                
                [self performSegueWithIdentifier:@"NewRelation" sender:sender];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BingRelationViewController * vc = [segue destinationViewController];
    vc.info = sender;
}

@end
