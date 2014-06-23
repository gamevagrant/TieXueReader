//
//  TXRegisteredTableViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-30.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXRegisteredTableViewController.h"
#import "TXAppUtils.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"

@interface TXRegisteredTableViewController ()

@end

@implementation TXRegisteredTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTheme];
}

- (void)updateTheme
{
    self.view.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    NSArray *subviews = self.view.subviews;
    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            subView.tintColor = [TXAppUtils instance].interactionTint;
        }
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            label.textColor = [TXAppUtils instance].fontTint;
        }
    }
    
}

- (IBAction)enterAccountEnd:(id)sender
{
    [self.passWordTextField becomeFirstResponder];
}

- (IBAction)enterPassWordEnd:(id)sender
{
    [self.passWordAgainTextField becomeFirstResponder];
}

- (IBAction)enterPassWordAgainEnd:(id)sender
{
    [sender resignFirstResponder];
    [self registeredAccount];
    
}

- (IBAction)backGroundTap:(id)sender
{
    
    [self.accountTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    [self.passWordAgainTextField resignFirstResponder];

}

- (IBAction)pressRegisteredBtn:(id)sender
{
    [self registeredAccount];
}

- (void)registeredAccount
{

    NSString *account = self.accountTextField.text;
    NSString *passWord = self.passWordTextField.text;
    NSString *passWordAgain = self.passWordAgainTextField.text;
    
    if (account == nil)
    {
        [self showAlertWithMessage:@"请输入帐号"];
    }else if (passWord == nil)
    {
        [self showAlertWithMessage:@"请输入密码"];
    }else if ( ![passWord isEqualToString:passWordAgain])
    {
        [self showAlertWithMessage:@"两次输入的密码不一致"];
    }else if (![TXAppUtils validatePassword:passWord])
    {
        [self showAlertWithMessage:@"密码需要为6到20位由大小写子母和数字组成，不能使用特殊字符"];
    }else
    {
        [TXSourceManager registrationWithAccount:account password:passWord completionHandler:^(TXUserData *data, NSError *error) {
            if (data)
            {
                [TXUserConfig instance].userData = data;
                [TXAppUtils showAlertWithTitle:@"成功" Message:@"注册成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                [TXAppUtils showAlertWithTitle:@"失败" Message:error.localizedDescription];
            }
        }];
        
        
        
    }
   
}

- (void)showAlertWithMessage:(NSString *)message

{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:self
                                   selector:@selector(timerFireMethod:)
                                   userInfo:alert
                                    repeats:NO];
    
    [alert show];
}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *alert = (UIAlertView*)[theTimer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    
}



@end
