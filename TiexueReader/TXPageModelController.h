//
//  TXPageModelController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-2-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChapterData.h"
#import "TXBookData.h"

@class TXDataViewController;

@protocol TXpageModelDelegate <NSObject>

- (void)startWait;
- (void)stopWait;

@end

@interface TXPageModelController : NSObject <UIPageViewControllerDataSource>

@property (nonatomic,strong) id<TXpageModelDelegate> delegate;
@property (nonatomic,strong) TXBookData *bookData;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger totlePage;

- (TXDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (void)setFileWithChapterID:(NSInteger)chapterID pageIndex:(NSInteger)pageIndex attribute:(NSDictionary *)attribute;//改变读取的文件
- (void)changeAttribute:(NSDictionary *)attribute;
- (void)changePage:(NSInteger)page;
- (void)changeCurrentPageViewController:(TXDataViewController *)pageViewController;

@end
