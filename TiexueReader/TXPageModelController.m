//
//  TXPageModelController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXPageModelController.h"
#import "TXDataViewController.h"
#import "TXBookData.h"
#import "TXAppUtils.h"
#import "TXPageSegmentationController.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define TIME_OUT_INTERVAL -3 //超时时间

@interface TXPageModelController()<PageSegmentationDelegate>

@property (nonatomic,strong) TXChapterData *chapterData;
@property (nonatomic,strong) NSDictionary *chapterList;
@property (nonatomic,strong) NSArray *chapterIDList;

@property (nonatomic,strong) TXDataViewController *pageView;//当前显示视图控制器
@property (nonatomic, strong) TXPageSegmentationController *pageSegmentation;//分页运算类

@property (nonatomic,strong) NSDictionary *stringAttribute;//文本数据的格式数据
@property (nonatomic,strong) NSString *filePath;//文件路径
@property (nonatomic) unsigned long long contentSize;//内容总容量
@property (nonatomic) CGSize pageSize;//页面尺寸



@end

@implementation TXPageModelController
{
    BOOL _isWaiting;//是否正在显示等待图标
}


- (id)init
{
    self = [super init];
    if (self) {
        _isWaiting = NO;
        self.pageSegmentation = [[TXPageSegmentationController alloc]init];
        self.pageSegmentation.delegate = self;
    
    }
    return self;
}

#pragma mark - public 对外接口

- (void)setBookData:(TXBookData *)bookData
{
    _bookData = bookData;
    self.chapterList = self.bookData.chapterList;
    self.chapterIDList = [self.bookData.chapterList.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (void)setFileWithChapterID:(NSInteger)chapterID pageIndex:(NSInteger)pageIndex attribute:(NSDictionary *)attribute
{
    if (pageIndex>0) {
        [self startWait];
    }
    

    if ([self.chapterIDList indexOfObject:[NSNumber numberWithInteger:chapterID]] == NSNotFound)
    {
        chapterID = [self.chapterIDList[0]integerValue];
    }

    self.stringAttribute = attribute;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.pageSize = CGSizeMake(screenSize.width - 20, screenSize.height - 30);
    
    [self downloadBookWithBookID:self.bookData.bookID chapterID:chapterID completionHandler:^(NSString *path, NSError *error) {
        if (path)
        {
            self.bookData.currentChapterID = chapterID;
            self.chapterData = [self.chapterList objectForKey:[NSNumber numberWithInteger:chapterID]];
            self.filePath = path;
            [self startPaging];
            
            if (pageIndex>0)
            {
                [self updateViewWithPage:pageIndex];
            }else
            {
                self.bookData.currentPage = 1;
            }
            
            
        }else
        {
            [TXAppUtils showAlertWithTitle:@"下载失败" Message:error.localizedDescription];
            [self updateViewWithPage:self.bookData.currentPage];
        }
        
    }];

}
//除了主运算线程外其他线程都没有做安全措施 等有时间好好研究重构一下 现在没时间
- (void)changeAttribute:(NSDictionary *)attribute
{
    [self startWait];
    self.stringAttribute = attribute;
    unsigned long long currentOffset = [self.pageSegmentation getOffsetWithPage:self.pageView.currentPage];

    [self setFileWithChapterID:self.chapterData.chapterID pageIndex:0 attribute:attribute];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSInteger currentPage=0;
        BOOL needGoOn = YES;
        NSDate *startDate;
        while (needGoOn)
        {
            currentPage = [self.pageSegmentation getPageWithOffset:currentOffset];//计算改变格式后当前看得内容在哪一页
            if (currentPage != 0) {
                needGoOn = NO;
            }else if(self.pageSegmentation.isRuning)
            {
                [NSThread sleepForTimeInterval:0.1];
            }else
            {
                if (!startDate)
                {
                    startDate = [NSDate date];
                }else if ([startDate timeIntervalSinceNow] > TIME_OUT_INTERVAL)
                {
                    needGoOn = NO;
                    currentPage = 1;
                }
                
            }

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self updateViewWithPage:currentPage];

        });
        
    });
}

//根据指定页数返回一个显示当前页的view
- (TXDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Create a new view controller and pass suitable data.
    TXDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"TXDataViewController"];
    self.pageView = dataViewController;
    if (index>0)
    {
        [self updateViewWithPage:index];
    }
    

    return dataViewController;
    
}

//更改当前页
- (void)changePage:(NSInteger)page
{
    [self updateViewWithPage:page];
}

//为了解决在翻页翻了一半退回来 当前页的引用丢失的问题 由uipageViewdelegat 传回当前页的引用
- (void)changeCurrentPageViewController:(TXDataViewController *)pageViewController
{
    self.pageView = pageViewController;
}
#pragma mark - private method
//下载章节内容 实现加载策略
- (void)downloadBookWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID completionHandler:(void(^)(NSString *path,NSError *error))completionHandler
{
    NSNumber *downLoadID = [NSNumber numberWithInteger:chapterID];
    NSArray *chapterIDList = self.chapterIDList;
    NSUInteger currentIndex = [chapterIDList indexOfObject:downLoadID];
    
    //下载3个章节内容
    NSMutableArray *downloadList = [[NSMutableArray alloc]init];
    NSInteger num = chapterIDList.count - currentIndex > 3 ? 3 : chapterIDList.count - currentIndex;
    for (NSInteger i = 0; i<num; i++)
    {
        [downloadList addObject:[chapterIDList objectAtIndex:currentIndex+i]];
    }
    
    //执行下载任务
    [TXSourceManager downloadWholeBookWithBookID:bookID chapterIDList:downloadList completionHandler:^(NSDictionary *list,NSError *error) {
        if (list)
        {
            NSString *path = [list objectForKey:downLoadID];
            if (path)
            {
                completionHandler(path,nil);
                
            }else
            {
                completionHandler(nil,error);
                
            }
        }
        
        BOOL isInShelf = [[TXUserConfig instance].bookDataList objectForKey:[NSNumber numberWithInteger:self.bookData.bookID]]?YES:NO;
        //如果是wifi网络下 全本下载
        if (isInShelf && [TXAppUtils isEnableWIFI])
        {
            
            //看后四章有没有下载 没有下载就全本下载
            BOOL isNeedDownLoad = NO;
            for (NSInteger i=0; i<5; i++)
            {
                if (currentIndex+i<chapterIDList.count) {
                    NSInteger testID = [[chapterIDList objectAtIndex:currentIndex+i] integerValue];
                    if (![TXAppUtils hasBookFileWithBookID:bookID chapterID:testID])
                    {
                        isNeedDownLoad = YES;
                        break;
                    }
                }
                
            }
            
            if (isNeedDownLoad)
            {
                [TXSourceManager downloadWholeBookWithBookID:bookID chapterIDList:chapterIDList completionHandler:^(NSDictionary *list,NSError *error) {
                    
                }];
            }
            
        }
        
    }];
    
    
    
}

- (void)startPaging
{
    if (!self.filePath) {
        return;
    }
    NSString *path = self.filePath;
    NSDictionary *attribute = self.stringAttribute;
    //判断是否已经有此分页数据
    NSString *key = [TXAppUtils getOffsetKeyWithAttributr:attribute];
    NSMutableArray *offsetList = [self.chapterData.offsetList objectForKey:key];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:nil];
    self.contentSize = [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
    if (offsetList && self.chapterData.fileSize == self.contentSize)
    {
        [self.pageSegmentation setFileWithPath:path attribute:attribute pageSize:self.pageSize offsetList:offsetList];
    }else
    {
        [self.pageSegmentation setFileWithPath:path attribute:attribute pageSize:self.pageSize];
    }
}
- (void)updateViewWithPage:(NSInteger)page
{
    if (!self.bookData || !self.pageView) {
        return;
    }
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *str = nil;
        BOOL needGoOn = YES;
        NSDate *startDate;
        while (needGoOn)
        {
            
            str = [self.pageSegmentation getContentWithPage:page];
            if (str) {
                self.bookData.currentPage = page;
                self.currentPage = page;
                needGoOn = NO;
            }else if(self.pageSegmentation.isRuning)
            {
                [NSThread sleepForTimeInterval:0.1];
            }else
            {
                if (!startDate)
                {
                    startDate = [NSDate date];
                }else if ([startDate timeIntervalSinceNow] > TIME_OUT_INTERVAL)//超时判断 避免死循环
                {
                    self.bookData.currentPage = 1;
                    self.currentPage = 1;
                    needGoOn = NO;
                    str = [self.pageSegmentation getContentWithPage:1];

                }
                
            }
            
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSAttributedString *content = [[NSAttributedString alloc] initWithString:str?str:@"" attributes:self.stringAttribute];
            TXDataViewController *dataViewController = self.pageView;
            dataViewController.currentPage = self.bookData.currentPage;
            dataViewController.currentChapterID = self.chapterData.chapterID;
            dataViewController.totalPage = self.pageSegmentation.totalPage;
            dataViewController.bookInfo = self.chapterData.chapterName;
            dataViewController.progress = self.pageSegmentation.progress;
            dataViewController.data = content;
            [self stopWait];
            
        });
        
    });

}
//根据当前的view取得当前页数
- (NSUInteger)indexOfViewController:(TXDataViewController *)viewController
{
    // Return the index of the given data view controller.
    // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return viewController.currentPage;
}

- (NSUInteger)chapterIDOfViewController:(TXDataViewController *)viewController
{
    return viewController.currentChapterID;
}

- (NSUInteger)totalPageOfViewController:(TXDataViewController *)viewController
{
    return viewController.totalPage;
}

- (void)startWait
{
    if (self.delegate && !_isWaiting) {
        _isWaiting = YES;
        [self.delegate startWait];
    }
}

- (void)stopWait
{
    if (self.delegate && _isWaiting) {
        _isWaiting = NO;
        [self.delegate stopWait];
    }
}


#pragma mark - pageSegmentationDelegate
- (void)updateProgressWithOffsetList:(NSArray *)offsetList contentSize:(unsigned long long)contentSize progress:(CGFloat)progress
{
    self.pageView.totalPage = offsetList.count;
    self.pageView.progress = progress;
    self.totlePage = offsetList.count;
    if (progress == 1) {
        //将算好的数据保存在章节信息里 以便以后归档用 只有计算完成才更新这些数据 否则重突退出程序，数据会错乱
        NSString *key = [TXAppUtils getOffsetKeyWithAttributr:self.stringAttribute];
        [self.chapterData.offsetList setObject:offsetList forKey:key];
        self.chapterData.fileSize = contentSize;

    }
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    UIViewController *pageView = [self viewControllerAtIndex:0 storyboard:viewController.storyboard];
    NSUInteger index = [self indexOfViewController:(TXDataViewController *)viewController];
    NSInteger chapterID = [self chapterIDOfViewController:(TXDataViewController *)viewController];
    
    //在翻阅章节的时候 如果翻页动画没有结束而再次反方向翻页 uipageView会调用此方法请求上一章节的数据 但其显示上并没有翻回到上一章节 而此类的章节数据已经变化 所以当他再次翻页时会造成章节数据的不一致 所以需要在此修正一次
    if (chapterID != self.chapterData.chapterID)
    {
        [self setFileWithChapterID:chapterID pageIndex:self.bookData.currentPage attribute:self.stringAttribute];
    }
    //对翻章的判断
    if ((index == 1) || (index == NSNotFound))
    {
        
        NSInteger chapterIndex = [self.chapterIDList indexOfObject:[NSNumber numberWithInteger:chapterID]];
        if (chapterIndex == NSNotFound) {
            return nil;
        }
        //如果有前一章
        if (chapterIndex>0)
        {
            NSInteger nextChapterID = [[self.chapterIDList objectAtIndex:chapterIndex - 1]integerValue];
//            self.bookData.currentPage = 0;//第0页是空白页 先显示空白页 异步取出数据后再改变
            [self setFileWithChapterID:nextChapterID pageIndex:0 attribute:self.stringAttribute];

            
            //异步取出前一章最后一页的页码 因为前一章的分页数据还在计算 所以不能马上得到需要全部运算完毕才能得到
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
                NSInteger finalPage=0;
                BOOL needGoOn = YES;
                NSDate *startDate ;
                while (needGoOn)
                {
                    finalPage = [self.pageSegmentation getPageWithOffset:self.contentSize];
                    if (finalPage != 0)
                    {
                        needGoOn = NO;
                    }else if(self.pageSegmentation.isRuning)
                    {
                        [NSThread sleepForTimeInterval:0.1];
                        
                    }else
                    {
                        if (!startDate)
                        {
                            startDate = [NSDate date];
                        }else if ([startDate timeIntervalSinceNow] > TIME_OUT_INTERVAL)
                        {
                            needGoOn = NO;
                            finalPage = 1;
                        }
                        
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self updateViewWithPage:finalPage];
                });
                
            });
            
            
        }else
        {
            return nil;
        }

    }else
    {
        index--;
        [self updateViewWithPage:index];
    }
    
    
    
    
    return pageView;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    UIViewController *pageView = [self viewControllerAtIndex:0 storyboard:viewController.storyboard];
    
    NSUInteger index = [self indexOfViewController:(TXDataViewController *)viewController];
    NSUInteger chapterID = [self chapterIDOfViewController:(TXDataViewController *)viewController];
    
    //在翻阅章节的时候 如果翻页动画没有结束而再次反方向翻页 uipageView会调用此方法请求上一章节的数据 但其显示上并没有翻回到上一章节 而此类的章节数据已经变化 所以当他再次翻页时会造成章节数据的不一致 所以需要在此修正一次
    if (chapterID != self.chapterData.chapterID)
    {
        [self setFileWithChapterID:chapterID pageIndex:self.bookData.currentPage attribute:self.stringAttribute];
    }
    NSUInteger totalPage = [self totalPageOfViewController:(TXDataViewController *)viewController];
    //判断是否需要翻章
    if (index >= totalPage || index == NSNotFound)
    {
        
        NSInteger chapterIndex = [self.chapterIDList indexOfObject:[NSNumber numberWithInteger:chapterID]];
        if (chapterIndex == NSNotFound) {
            return nil;
        }
        if (chapterIndex < self.chapterIDList.count - 1)
        {
            NSInteger nextChapterID = [[self.chapterIDList objectAtIndex:chapterIndex + 1]integerValue];
            [self setFileWithChapterID:nextChapterID pageIndex:1 attribute:self.stringAttribute];

            
        }else
        {
            return nil;
        }

    }else
    {
        index++;
        [self updateViewWithPage:index];
    }

    return pageView;
    
}

@end
