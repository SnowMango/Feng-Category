//
//  ClientViewController.m
//  VideoDemo
//
//  Created by zhengfeng on 17/2/15.
//  Copyright © 2017年 zhengfeng. All rights reserved.
//

#import "ClientViewController.h"
#import "P2PTCPClient.h"
#import "P2PUDPClient.h"
#import "PlayerViewController.h"

@interface ClientViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ClientViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)startLook:(NSString *)ip
{

    if (!ip.length) {
        ip = @"172.30.220.250";
    }
    [self performSegueWithIdentifier:@"Player" sender:ip];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.text) {
        [self startLook:textField.text];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Player"]) {
        PlayerViewController *vc = segue.destinationViewController;
        vc.ip = sender;
    }
}

@end
