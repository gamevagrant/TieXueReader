//
//  TXSetupViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-17.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXSetupViewController.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"
#import "TXUserData.h"
#import "TXDefine.h"
#import "TXAppUtils.h"
#import "MobClick.h"


@interface TXSetupViewController ()
@property (strong, nonatomic) TXUserData *userData;
@end

@implementation TXSetupViewController
{
    AppTheme _theme;
}

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
    self.tableView.delegate = self;
    self.nightSwitch.on = [TXUserConfig instance].isNightMode;
    [self updateTheme];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TXUserData *data = [TXUserConfig instance].userData;
    if (data)
    {
        self.userData = data;
        [self didLogin];
    }
    
    if (_theme != [TXAppUtils instance].theme) {
        [self updateTheme];
    }
    //友盟监控
    [MobClick beginLogPageView:@"设置"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //友盟监控
    [MobClick endLogPageView:@"设置"];
}
- (void)updateTheme
{
    self.tabBarController.tabBar.tintColor = [TXAppUtils instance].interactionTint;
    self.tabBarController.tabBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.navigationController.navigationBar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.navigationBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [TXAppUtils instance].titleFontTint,NSForegroundColorAttributeName, nil];
    
    self.navigationController.toolbar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.toolbar.barTintColor = [TXAppUtils instance].toolBarBackGroundColor;
    self.tableView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    [self.tableView reloadData];
    _theme = [TXAppUtils instance].theme;
}

//- (void)setUserData:(TXUserData *)userData
//{
//    _userData = userData;
//    [self didLogin];
//}

//登陆成功后
- (void)didLogin
{
    self.nameLabel.text = self.userData.userName;
    self.nameLabel.textColor = [TXAppUtils instance].interactionTint;
    self.goldLabel.text = [NSString stringWithFormat:@"%ld", (long)self.userData.gold];
    self.accountCell.accessoryType = UITableViewCellAccessoryNone;
}

//注销成功后
- (void)didCancellation
{
    self.userData = nil;
    [TXUserConfig instance].userData = nil;
    self.nameLabel.text = @"登录铁血帐号";
    self.nameLabel.textColor = [TXAppUtils instance].fontTint;
    self.goldLabel.text = nil;
    self.accountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.userData)
    {
        return NO;
    }
    return YES;
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
- (IBAction)nightModleChange:(id)sender
{
    UISwitch *sw = sender;
    BOOL isOn = sw.isOn;

    
    TXUserConfig *userConfig = [TXUserConfig instance];
    userConfig.isNightMode = isOn;
    
    
    //发送 更改主题的消息
    AppTheme theme = isOn?THEME_NIGHT:THEME_NORMAL;
    [[TXAppUtils instance] setTheme:theme];
    [self updateTheme];

}

- (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *alert = (UIAlertView*)[theTimer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:NO];
    
}
#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = cell.reuseIdentifier;
    if ([identifier isEqual:@"Score"])
    {
        [[TXAppUtils instance].indicator startAnimating];
        self.view.userInteractionEnabled = NO;
        //初始化控制器
        SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
        //设置代理请求为当前控制器本身
        storeProductViewContorller.delegate = self;
        storeProductViewContorller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        //加载一个新的视图展示
        [storeProductViewContorller loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : AppID} completionBlock:^(BOOL result, NSError *error) {
            //block回调
            [[TXAppUtils instance].indicator stopAnimating];
            self.view.userInteractionEnabled = YES;
            if(error)
            {
                [TXAppUtils showAlertWithTitle:@"连接失败" Message:error.localizedDescription];
            }else
            {
                //模态弹出appstore
                [self presentViewController:storeProductViewContorller animated:YES completion:^{
                    
                }];
            }
        }];

    }else
    if ([identifier isEqual:@"ClearCacheCell"] )
    {
        //清除缓存
        [TXAppUtils clearCaches];
        
        [self showAlertWithMessage:@"清理完毕"];
        [TXAppUtils instance].needUpdateBookShelf = YES;
        
    }else if([identifier isEqual:@"AccountCell"] )
    {
        if (self.userData)
        {
            
            NSString *title = [NSString stringWithFormat:@"铁血帐号\n%@",self.userData.userName];
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:title
                                          delegate:self
                                          cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:@"注销"
                                          otherButtonTitles:nil];
            [actionSheet showInView:self.view];

        }
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [TXAppUtils instance].tableViewCellBackGroundColor;
    NSArray *subviews = cell.contentView.subviews;
    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            subView.tintColor = [TXAppUtils instance].interactionTint;
        }
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            if ([cell.reuseIdentifier isEqual:@"AccountCell"] && [TXUserConfig instance].userData) {
                label.textColor = [TXAppUtils instance].interactionTint;
            }else
            {
                
                label.textColor = [TXAppUtils instance].titleFontTint;
            }
            
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.backgroundView.backgroundColor = [TXAppUtils instance].titleCellBackGroundColor;
    NSArray *subviews = headerView.contentView.subviews;

    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            subView.tintColor = [TXAppUtils instance].interactionTint;
        }
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            label.textColor = [TXAppUtils instance].titleFontTint;
        }
    }
}
#pragma mark - actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self didCancellation];

    }
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
