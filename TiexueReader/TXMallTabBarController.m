//
//  TXMallViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-17.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallTabBarController.h"
#import "TXMallViewController.h"
#import "TXAppUtils.h"
#import "TXMallBookListViewController.h"
#import "TXEnumeUtils.h"
#import "MobClick.h"

@interface TXMallTabBarController ()

@end

@implementation TXMallTabBarController

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
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    
    self.tabBarTopView.layer.shadowOffset = CGSizeMake(0, 1);
    self.tabBarTopView.layer.shadowRadius = 3;
    self.tabBarTopView.layer.masksToBounds = NO;
    self.tabBarTopView.layer.shadowOpacity = 0.5;
    self.tabBarTopView.nameArray = [NSArray arrayWithObjects:@"推荐",@"完本",@"排行",@"分类",@"搜索", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self updateTheme];
    
    //友盟监控
    [MobClick beginLogPageView:@"书城"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"书城"];
}

- (void)updateTheme
{
    self.navigationController.navigationBar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.navigationBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [TXAppUtils instance].titleFontTint,NSForegroundColorAttributeName, nil];
    
    self.navigationController.toolbar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.toolbar.barTintColor = [TXAppUtils instance].toolBarBackGroundColor;
    self.tabBarTopView.backgroundColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.tabBarTopView.titleColorNormal = [TXAppUtils instance].titleFontTint;
    self.tabBarTopView.titleColorSelected = [TXAppUtils instance].interactionTint;
    self.tabBarPageView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
}

#pragma mark - TXTabBardataSource
- (UIViewController *)tabBarContentView:(TXTabBarPageView *)tabBarContentView pageAtIndex:(NSInteger)index
{
    NSString *identifier;
    switch (index) {
        case 0:
            identifier = @"MallViewController";
            break;
        case 1:
            identifier = @"MallBookListPageViewController";
            break;
        case 2:
            identifier = @"MallRankPageViewController";
            break;
        case 3:
            identifier = @"MallKindPageViewController";
            break;
        case 4:
            identifier = @"MallSearchViewController";
        default:
            break;
    }
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    if ([identifier isEqual: @"MallBookListPageViewController"])
    {
        ((TXMallBookListViewController *)controller).listType = [NSNumber numberWithInteger:(NSInteger)TX_ENUME_MALL_BOOKLIST_TYPE_END_QUAN_BU];
    }
    
    CGRect screenFrame = [UIScreen mainScreen].applicationFrame;
    controller.view.frame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height - 49);
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    return controller;
}

- (NSInteger)tabBarContentView:(TXTabBarPageView *)tabBarContentView
{
    return 5;
}


@end
