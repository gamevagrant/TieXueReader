//
//  TXAppUtils.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-27.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "TXAppUtils.h"
#import "TXDefine.h"
#import "Reachability.h"
#import "TXUserConfig.h"
#import "TXSourceManager.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaPremultipliedLast  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast)
#else
#define kCGImageAlphaPremultipliedLast  kCGImageAlphaPremultipliedLast
#endif
@interface TXAppUtils ()

@end

static NSMutableDictionary *imageCache;//图片缓存字典 md5(url)为KEY nsdata为value
static TXAppUtils *_instance;
BOOL hasAlert;

@implementation TXAppUtils
+ (TXAppUtils *)instance
{
    if (!_instance) {
        _instance = [[TXAppUtils alloc]init];
        hasAlert = NO;
        _instance.needUpdateBookShelf = YES;
    }
    return _instance;
}

#pragma mark - 全局配置 数据 方法
- (void)setTheme:(AppTheme)theme
{
    _theme = theme;
    switch (theme) {
        case THEME_NIGHT:
            _instance.navigationBarBackGroundColor = COLOR_BLACK_NORMAL;//导航条背景颜色
            _instance.toolBarBackGroundColor = COLOR_BLACK_NORMAL;//工具栏的北京颜色 包括tabbar
            _instance.tableViewBackGroundColor = COLOR_BLACK_NORMAL;//表格等数据源控件的背景颜色
            _instance.tableViewCellBackGroundColor = COLOR_BLACK_NORMAL;//表格cell背景色
            _instance.titleCellBackGroundColor = COLOR_BLACK_NORMAL;//标题格子的背景颜色
            _instance.pageBackGroundColor = COLOR_BLACK_DARK;//读书页面纸张颜色
            _instance.interactionTint = COLOR_RED_DARK;//各种图标、按钮、可交互文字的色调
            _instance.fontTint = COLOR_GRAY_NORMAL;//字体颜色
            _instance.titleFontTint = COLOR_WHITE_DARK;
            break;
            
        default:
            _instance.navigationBarBackGroundColor = COLOR_WHITE_NORMAL;//导航条背景颜色
            _instance.toolBarBackGroundColor = COLOR_WHITE_NORMAL;//工具栏的北京颜色 包括tabbar
            _instance.tableViewBackGroundColor = COLOR_WHITE_NORMAL;//表格等数据源控件的背景颜色
            _instance.tableViewCellBackGroundColor = COLOR_WHITE_NORMAL;//表格cell背景色
            _instance.titleCellBackGroundColor = COLOR_WHITE_DARK;//标题格子的背景颜色
            _instance.pageBackGroundColor = COLOR_FLESH_NORMAL;//读书页面纸张颜色
            _instance.interactionTint = COLOR_RED_DARK;//各种图标、按钮、可交互文字的色调
            _instance.fontTint = COLOR_GRAY_NORMAL;//字体颜色
            _instance.titleFontTint = COLOR_BLACK_NORMAL;//标题字体颜色
            break;
    }
    [[UIApplication sharedApplication]setStatusBarStyle:theme==THEME_NIGHT?UIStatusBarStyleLightContent:UIStatusBarStyleDefault animated:NO];
    
    NSNumber *data = [NSNumber numberWithInteger:theme];
    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: data,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_THEME object:nil userInfo:info];
}
//取得活动指示器对象
- (TXActivityIndicatorView *)indicator
{
    if (!_indicator)
    {
        CGFloat width = 180;
        CGFloat height = 130;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        TXActivityIndicatorView *indicator = [[TXActivityIndicatorView alloc]initWithFrame:CGRectMake(screenWidth/2 - width/2, screenHeight*0.4 - height/2, width, height)];
        self.indicator = indicator;
        
    }
    return _indicator;
}

//保存书籍数据到固定位置
+ (BOOL)saveBookWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID data:(NSData *)data
{
    //获取图书目录
    NSString *bookPath = [TXAppUtils getBookFolderPathWithBookID:bookID];
    //文件路径
    NSString *filePath = [bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li",(long)chapterID]];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //判断下载目录存不存在
    if (![fm fileExistsAtPath:bookPath])
    {
        NSLog(@"下载目录不存在，开始创建下载目录");
        //创建目录
        if(![fm createDirectoryAtPath:bookPath withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSLog(@"不能创建下载目录");
            return NO;
        }
    }
    //更改当前目录
    [fm changeCurrentDirectoryPath:bookPath];
    
    //将数据写入文件
    if (![fm createFileAtPath:filePath contents:data attributes:nil])
    {
        NSLog(@"文件保存失败");
        return NO;
    }else
    {
//        NSLog(@"写入成功:%@",filePath);
//        NSArray *dirArr = [fm contentsOfDirectoryAtPath:bookPath error:nil];
//        NSLog(@"%@",dirArr);
    }
    
    return YES;
}

//判断章节文件是否已经下载
+ (BOOL)hasBookFileWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID
{
    BOOL hasFile = NO;
    NSString *file = [self getBookPathWithBookID:bookID chapterID:chapterID];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    //判断下载目录存不存在
    if ([fm fileExistsAtPath:file])
    {
        hasFile = YES;
    }
    
    return hasFile;
}

//判断当前网络连接是否为WIFI
+ (BOOL)isEnableWIFI
{
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi);
}
//判断当前网络连接是否为3G/2G网络
+ (BOOL)isEnableWWAN
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);
}
//判断是否有网络
+ (BOOL)hasNetworking
{
    BOOL networking;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus])
    {
        case NotReachable:        // 没有网络连接
            networking = NO;
            break;
        case ReachableViaWWAN:        // 使用3G网络
            networking = YES;
            break;
        case ReachableViaWiFi:        // 使用WiFi网络
            networking = YES;
            break;
    }
    return networking;
}

+ (UIImage *)getImageFromCacheWithURL:(NSURL *)url
{
    if (!url || url.absoluteString.length==0) {
        return [UIImage imageNamed:@"loading"];
    }
    if (!imageCache) {
        imageCache = [[NSMutableDictionary alloc]init];
    }
    NSString *key = [TXAppUtils md5:url.path];
    UIImage *image;
    //从内存中搜索图片
    image = [imageCache objectForKey:key];
    if (image)
    {
        return image;
    }
    
    //从硬盘中搜索图片
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cachePath = [TXAppUtils getImageCacheFolderPath];
    if (![fm fileExistsAtPath:cachePath]) {
        [fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *path = [cachePath stringByAppendingPathComponent:key];
    if ([fm fileExistsAtPath:path])
    {
        image = [UIImage imageWithData:[fm contentsAtPath:path]];
        image = [TXAppUtils createRoundedRectImage:image];
        return image;
    }
    
    //从网络下载图片
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data && data.length>0) {
        image = [UIImage imageWithData:data];
        image = [TXAppUtils createRoundedRectImage:image];
        [imageCache setObject:image forKey:key];
        BOOL isSuccess = [fm createFileAtPath:path contents:data attributes:nil];
        NSLog(@"缓存图片 %@",isSuccess?@"成功":@"失败");
    }
    
    return image;
    
}

//通过线程加载一个图片
+ (void)loadImageByThreadWithView:(UIImageView *)view url:(NSString *)url
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = [self getImageFromCacheWithURL:[NSURL URLWithString:url]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //这里写视图更新相关得方法 视图只能在主线程更新
            view.image = image;
        });
        
    });
    
    
}

//显示提示框
+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message
{
    if (hasAlert) {
        return;
    }
    hasAlert = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                         target:self
                                       selector:@selector(timerFireMethod:)
                                       userInfo:alert
                                        repeats:NO];
        [alert show];
    });
    
}

+ (void)syncBookShelf
{
    //同步本地书架
    TXUserConfig *userConfig = [TXUserConfig instance];
    if (userConfig.userData && userConfig.operateList && userConfig.operateList.count>0)
    {
        [TXSourceManager syncShelfOperate:userConfig.operateList completionHandler:^(BOOL isSuccess, NSError *error) {
            if (isSuccess) {
                [userConfig.operateList removeAllObjects];
                [TXAppUtils instance].needUpdateBookShelf = YES;
            }
        }];
    }
}

//获取App在itunes中的信息
+ (void)getAppInfoCompletionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler
{
    NSString *query = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", AppID];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] : nil;
    if (results)
    {
        completionHandler(results,nil);
    }else
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"无法获取更新信息",NSLocalizedDescriptionKey,nil,NSLocalizedFailureReasonErrorKey,nil];
        NSError *cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorNotNetWorking userInfo:userInfo];
        completionHandler(nil,cError);
    }
    
}

//跳转到商城
+ (void)gotoAppStore
{
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",AppID];
//    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%i",391945719];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
#pragma mark -清理方法
//清空下载目录
+ (void)clearDownLoadFolder
{
    NSString *downLoadDirectory = @"DownLoad";
    //获取文档目录
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    //获取图书下载目录
    NSString *downLoadPath = [documentPath stringByAppendingPathComponent:downLoadDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:downLoadPath error:NULL];
    NSLog(@"清理前DownLoad文件夹下内容%@",contents);
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        BOOL isSuccess = [fileManager removeItemAtPath:[downLoadPath stringByAppendingPathComponent:filename] error:NULL];
        NSLog(@"删除文件 %@ %@",filename,isSuccess?@"成功":@"失败");
    }
    contents = [fileManager contentsOfDirectoryAtPath:downLoadPath error:NULL];
    NSLog(@"清理后DownLoad文件夹下内容%@",contents);
}

//删除用户配置文件
+ (void)clearUserConfigFile
{
    NSString *path = [self getUserConfigFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //判断下载目录存不存在
    if ([fileManager fileExistsAtPath:path])
    {
        BOOL success = [fileManager removeItemAtPath:path error:NULL];
        NSLog(@"删除用户配置文件%@",success?@"成功":@"失败");
    }
    
}

//清理图片缓存
+ (void)clearImageCache
{
    imageCache = [[NSMutableDictionary alloc]init];
    NSString*cachePath = [TXAppUtils getImageCacheFolderPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
    NSLog(@"清理前Cache/image文件夹下内容%@",contents);
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject]))
    {
        [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:filename] error:NULL];
    }
    contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
    NSLog(@"清理后Cache/image文件夹下内容%@",contents);
}

+ (void)clearCaches
{
    [self clearDownLoadFolder];
    [self clearImageCache];
    [[TXUserConfig instance] clearCache];

}


#pragma mark - 路径获取
//获取图书目录
+ (NSString *)getBookFolderPathWithBookID:(NSInteger)bookID
{
    NSString *downLoadDirectory = @"DownLoad";
    //获取文档目录
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    //获取图书下载目录
    NSString *downLoadPath = [documentPath stringByAppendingPathComponent:downLoadDirectory];
    //获取图书目录
    NSString *bookPath = [downLoadPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%li",(long)bookID]];

    return bookPath;
}



//根据书名和章节id 找到书籍文件
+ (NSString *)getBookPathWithBookID:(NSInteger)bookName chapterID:(NSInteger)chapterID
{
    NSString *bookPath = [TXAppUtils getBookFolderPathWithBookID:bookName];
    NSString *filePath = [bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)chapterID]];
    return filePath;
}

//获取用户配置文件路径
+ (NSString *)getUserConfigFilePath
{
    NSString *userConfigFileName = @"userConfig";
    //获取文档目录
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    //获取图书下载目录
    NSString *userConfigPath = [documentPath stringByAppendingPathComponent:userConfigFileName];
    
    return userConfigPath;
}

//获取图片缓存路径
+ (NSString *)getImageCacheFolderPath
{
    NSString *folderName = @"image";
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [[cacPath objectAtIndex:0] stringByAppendingPathComponent:folderName];
    return cachePath;
}


#pragma mark - 系统工具


+ (void)timerFireMethod:(NSTimer*)theTimer
{
    UIAlertView *alert = (UIAlertView*)[theTimer userInfo];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    hasAlert = NO;
}

//获取存储分页数据的字典key
+ (NSString *)getOffsetKeyWithAttributr:(NSDictionary *)attribute
{
    UIFont *font = [attribute objectForKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraph = [attribute objectForKey:NSParagraphStyleAttributeName];
    NSString *key = [NSString stringWithFormat:@"%@_%f_%f",font.fontName,font.pointSize,paragraph.lineHeightMultiple];
    return key;
}

//对字符串进行MD5加密
+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

//获取指定时间戳距离当前时间的描述
+ (NSString *)getTimeIntervalFromTimestamp:(NSTimeInterval)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    timeInterval = -timeInterval;
    
    NSInteger temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%li分前",(long)temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%li小前",(long)temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%li天前",(long)temp];
    }else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        result = [dateFormatter stringFromDate:date];
    }
    
    return result;
    
}
//使用 layer.cornerRadius 对图片设圆熟料多的话角会使view滚动变卡 用这个方法直接把图片处理成圆角的木用每帧都计算
+ (id) createRoundedRectImage:(UIImage*)image
{
    // the size of CGContextRef
    int w = image.size.width;
    int h = image.size.height;
    
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, 10, 10);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
}
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

//判断邮箱格式
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//判断密码格式
+ (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

//获取毫秒时间戳
+ (unsigned long long) getMillisecondTimestampWithDate:(NSDate *)date
{
    return date.timeIntervalSince1970 * 1000;
}
@end
