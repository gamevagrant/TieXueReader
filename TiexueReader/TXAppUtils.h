//
//  TXAppUtils.h
//  TiexueReader
//
//  Created by 齐宇 on 14-2-27.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXBookData.h"
#import "TXActivityIndicatorView.h"


typedef NS_ENUM(NSInteger, AppTheme)
{
    THEME_NORMAL = 1,
    THEME_NIGHT
};


@interface TXAppUtils : NSObject
@property (nonatomic) AppTheme theme;//主题样式
@property (nonatomic,strong) UIColor *navigationBarBackGroundColor;//导航条背景颜色
@property (nonatomic,strong) UIColor *toolBarBackGroundColor;//工具栏的北京颜色 包括tabbar
@property (nonatomic,strong) UIColor *tableViewBackGroundColor;//表格等数据源控件的背景颜色
@property (nonatomic,strong) UIColor *tableViewCellBackGroundColor;//表格cell背景色
@property (nonatomic,strong) UIColor *titleCellBackGroundColor;//标题格子的背景颜色
@property (nonatomic,strong) UIColor *pageBackGroundColor;//读书页面纸张颜色
@property (nonatomic,strong) UIColor *interactionTint;//各种图标、按钮、可交互文字的色调
@property (nonatomic,strong) UIColor *fontTint;//字体颜色
@property (nonatomic,strong) UIColor *titleFontTint;//标题字体颜色


@property (nonatomic,strong) TXActivityIndicatorView *indicator;//活动指示器
@property (nonatomic) BOOL needUpdateBookShelf;//需要刷新书架

+ (TXAppUtils *)instance;

+ (NSString *)getBookFolderPathWithBookID:(NSInteger)bookID;
+ (NSString *)getBookPathWithBookID:(NSInteger)bookName chapterID:(NSInteger)chapterID;
+ (NSString *)getImageCacheFolderPath;
+ (NSString *)getUserConfigFilePath;

+ (BOOL)saveBookWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID data:(NSData *)data;
//加载图片
+ (void)loadImageByThreadWithView:(UIImageView *)view url:(NSString *)url;
//从缓存中取图片如果缓存中没有则去下载
+ (UIImage *)getImageFromCacheWithURL:(NSURL *)url;
//同步本地书架
+ (void)syncBookShelf;
//获取app信息
+ (void)getAppInfoCompletionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler;
//跳转到app商城
+ (void)gotoAppStore;

+ (void)clearDownLoadFolder;
+ (void)clearUserConfigFile;
+ (void)clearImageCache;
+ (void)clearCaches;

+ (BOOL)hasBookFileWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID;

//判断当前网络连接是否为WIFI
+ (BOOL)isEnableWIFI;
//判断当前网络连接是否为3G/2G网络
+ (BOOL)isEnableWWAN;
//判断是否有网络
+ (BOOL)hasNetworking;

//显示提示框
+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message ;
+ (NSString *)getOffsetKeyWithAttributr:(NSDictionary *)attribute;
+ (NSString *)md5:(NSString *)str;
+ (id) createRoundedRectImage:(UIImage*)image;
+ (NSString *)getTimeIntervalFromTimestamp:(NSTimeInterval)timestamp;
+ (BOOL) validateEmail:(NSString *)email;
+ (BOOL) validatePassword:(NSString *)passWord;
+ (unsigned long long) getMillisecondTimestampWithDate:(NSDate *)date;
@end
