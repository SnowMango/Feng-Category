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

//@property (nonatomic, strong) P2PTCPClient* tcp;
@end

@implementation ClientViewController


- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tcp = [P2PTCPClient new];
//    self.tcp.socketHost = @"192.168.0.101";
}

- (void)startLook:(NSString *)ip
{

    if (!ip) {
        ip = @"192.168.0.101";
    }
    [self performSegueWithIdentifier:@"Player" sender:ip];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.text) {
        [self startLook:nil];
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
