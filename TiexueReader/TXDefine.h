//
//  TXNotificationName.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-26.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

//-----------------------------------
#pragma mark - 客户端配置

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
#define VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define AppID @"886546701"
#define API_ROOT @"http://androidapi.junshishu.com/"

#pragma mark - 读书配置
#define FONT_SIZE_MIN 18
#define FONT_SIZE_STEP 2

//---------------------------------------------------------
#pragma mark - ui元素

#define STATUS_BAR_HEGHT (IS_IOS7 ? [UIApplication sharedApplication].statusBarFrame.size.height : 0.0f)
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//---------------------------------------------------------
#define TAG_CUSTOM_BASE 10000 //tag的基数 tag0-100为保留值 所以自定义tag值要加上这个基数
//---------------------------------------------------
#pragma mark - 消息名称

#define CHANGE_LIGHT @"TX_CHANGE_LIGHT"//改变频幕亮度
#define CHANGE_FONTSIZE @"TX_CHANGE_FONTSIZE"//改变字体大小
#define CHANGE_LINE_SPACE @"TX_CHANGE_LINE_SPACE"//改变行间距
#define CHANGE_NIGHT_MODEL @"TX_CHANGE_NIGHT_MODEL"//改变夜间模式
#define CHANGE_CURRENT_PAGE @"TX_CHANGE_CURRENT_PAGE"//更改当前页
#define PUSH_BOOKINFO_PAGE @"TX_PUSH_BOOKINFO_PAGE"//跳转到书籍详情页面
#define PUSH_READ_PAGE @"TX_PUSH_READ_PAGE"//跳转到阅读页面


#define CHANGE_THEME @"TX_CHANGE_THEME"//更改主题

//----------------------------------------------------------
#pragma mark - 颜色

#define COLOR_FLESH_LIGHT [UIColor colorWithRed:242.0f/255.0f green:235.0f/255.0f blue:222.0f/255.0f alpha:1.0f] //肉色
#define COLOR_FLESH_NORMAL [UIColor colorWithRed:236.0f/255.0f green:225.0f/255.0f blue:209.0f/255.0f alpha:1.0f]
#define COLOR_FLESH_DARK [UIColor colorWithRed:236.0f/255.0f green:201.0f/255.0f blue:165.0f/255.0f alpha:1.0f]

#define COLOR_RED_DARK [UIColor colorWithRed:169.0f/255.0f green:0.0f/255.0f blue:18.0f/255.0f alpha:1.0f]//红色

#define COLOR_BLACK_LIGHT [UIColor colorWithRed:95.0f/255.0f green:57.0f/255.0f blue:57.0f/255.0f alpha:1.0f]//黑色
#define COLOR_BLACK_NORMAL [UIColor colorWithRed:36.0f/255.0f green:36.0f/255.0f blue:36.0f/255.0f alpha:1.0f]//黑色
#define COLOR_BLACK_DARK [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f]//黑色

#define COLOR_BLUE_LIGHT [UIColor colorWithRed:122.0f/255.0f green:213.0f/255.0f blue:241.0f/255.0f alpha:1.0f]//蓝色
#define COLOR_BLUE_NORMAL [UIColor colorWithRed:62.0f/255.0f green:153.0f/255.0f blue:226.0f/255.0f alpha:1.0f]//蓝色
#define COLOR_BLUE_DARK [UIColor colorWithRed:28.0f/255.0f green:138.0f/255.0f blue:206.0f/255.0f alpha:1.0f]//蓝色

#define COLOR_GREEN_NORMAL [UIColor colorWithRed:179.0f/255.0f green:222.0f/255.0f blue:68.0f/255.0f alpha:1.0f]//绿色
#define COLOR_GREEN_DARK [UIColor colorWithRed:152.0f/255.0f green:197.0f/255.0f blue:45.0f/255.0f alpha:1.0f]//绿色

#define COLOR_WHITE_LIGHT [UIColor colorWithRed:247.0f/255.0f green:247.0f/255.0f blue:247.0f/255.0f alpha:1.0f]//白色
#define COLOR_WHITE_NORMAL [UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:1.0f]//白色
#define COLOR_WHITE_DARK [UIColor colorWithRed:227.0f/255.0f green:227.0f/255.0f blue:227.0f/255.0f alpha:1.0f]//白色
#define COLOR_WHITE_NORMAL_ALPHA [UIColor colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:0.0f]//白色

#define COLOR_GRAY_LIGHT [UIColor colorWithRed:147.0f/255.0f green:147.0f/255.0f blue:147.0f/255.0f alpha:1.0f]//灰色
#define COLOR_GRAY_NORMAL [UIColor colorWithRed:127.0f/255.0f green:127.0f/255.0f blue:127.0f/255.0f alpha:1.0f]//灰色
#define COLOR_GRAY_DARK [UIColor colorWithRed:107.0f/255.0f green:107.0f/255.0f blue:107.0f/255.0f alpha:1.0f]//灰色

//------------------------------------------------------------------
#pragma mark - 提示

#define TIPS_NETWORK_OUTAGES @"无法连接网络"
#define TIPS_DATA_ANOMALIES @"数据异常"
#define TIPS_REQUEST_FAILS @"请求失败"

