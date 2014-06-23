//
//  SVTabBarScrollView.h
//  SlideView
//
//  Created by 齐宇 on 14-4-2.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define STATUS_BAR_HEGHT (IS_IOS7 ? [UIApplication sharedApplication].statusBarFrame.size.height : 0.0f)
//按钮空隙
#define BUTTONGAP 5
//滑条宽度
#define CONTENTSIZEX 320
//按钮id
#define BUTTONID (sender.tag-100)
//滑动id
#define BUTTONSELECTEDID (scrollViewSelectedChannelID - 100)

@protocol TXTabBarButtonsViewDelegate;

@interface TXTabBarButtonsView : UIScrollView
@property (nonatomic,strong) NSArray *nameArray;//tab按钮名字的集合
@property (nonatomic,strong) id <TXTabBarButtonsViewDelegate> customDelegate;
@property (nonatomic,strong) UIColor *titleColorNormal;
@property (nonatomic,strong) UIColor *titleColorSelected;

- (void)setSelectedButton:(NSInteger)index;
@end


@protocol TXTabBarButtonsViewDelegate <NSObject>
@optional
- (void)changeSelectedWithIndex:(NSInteger)index;

@end