//
//  TXMainTabBarViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-31.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMainTabBarViewController.h"
#import "TXAppUtils.h"
#import "TXActivityIndicatorView.h"

@interface TXMainTabBarViewController ()

@end

@implementation TXMainTabBarViewController

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
    [self.view addSubview:[TXAppUtils instance].indicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBar.tintColor = [TXAppUtils instance].interactionTint;
    self.tabBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    CATransition* animation = [CATransition animation];
    [animation setDuration:0.3f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.view layer]addAnimation:animation forKey:@"switchView"];
}





@end
