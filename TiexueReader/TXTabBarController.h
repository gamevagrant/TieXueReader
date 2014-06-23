//
//  SVScrollViewController.h
//  SlideView
//
//  Created by 齐宇 on 14-4-2.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXTabBarPageView.h"
#import "TXTabBarButtonsView.h"
#import "TXTabBarPageView.h"

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define STATUS_BAR_HEGHT (IS_IOS7 ? [UIApplication sharedApplication].statusBarFrame.size.height : 0.0f)
#define TABBAR_HEIGHT 40


@protocol TXTabBarContentViewDataSource <NSObject>
@required

//获取总共的页数
- (NSInteger)tabBarContentView:(TXTabBarPageView *)tabBarContentView;

//获取指定页码要显示的内容
- (UIViewController *)tabBarContentView:(TXTabBarPageView *)tabBarContentView pageAtIndex:(NSInteger)index;

@optional


@end


@interface TXTabBarController : UIViewController<UIScrollViewDelegate,UIScrollViewDelegate,TXTabBarContentViewDataSource,TXTabBarButtonsViewDelegate>
@property (nonatomic,strong) TXTabBarButtonsView *tabBarTopView;        //上边的tabbar
@property (nonatomic,strong) TXTabBarPageView *tabBarPageView;          //下边滚动的翻页区域
@property (nonatomic, assign) id <TXTabBarContentViewDataSource> dataSource;
@end



