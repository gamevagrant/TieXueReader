//
//  TXLoginAccountViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-29.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXLoginAccountViewController.h"
#import "TXSourceManager.h"
#import "TXUserData.h"
#import "TXUserConfig.h"
#import "TXAppUtils.h"

@interface TXLoginAccountViewController ()

@end

@implementation TXLoginAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (IBAction)didEnterAccount:(id)sender {
    [self.passWordTextField becomeFirstResponder];
}

- (IBAction)didEnterPassWord:(id)sender {
    [sender resignFirstResponder];
    NSString *account = self.accountTextField.text;
    NSString *passWord = self.passWordTextField.text;
    [self loginWithAccount:account passWord:passWord];
}

- (IBAction)backGroundTap:(id)sender {
    [self.accountTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    
    
}

- (IBAction)loginBtnPress:(id)sender {
    NSString *account = self.accountTextField.text;
    NSString *passWord = self.passWordTextField.text;
    [self loginWithAccount:account passWord:passWord];
}

- (void)loginWithAccount:(NSString *)account passWord:(NSString *)passWord
{
    [TXSourceManager loginWithAccount:account passWord:passWord completionHandler:^(TXUserData *data, NSError *error) {
        if (data)
        {
            TXUserConfig *config = [TXUserConfig instance];
            config.userData = data;
            [TXAppUtils syncBookShelf];

            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [TXAppUtils showAlertWithTitle:@"失败" Message:error.localizedDescription];
        }

    }];
    
}



@end
