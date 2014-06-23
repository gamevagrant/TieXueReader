//
//  TXPageSegmentationController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PageSegmentationDelegate <NSObject>

- (void)updateProgressWithOffsetList:(NSArray *)offsetList contentSize:(unsigned long long)contentSize progress:(CGFloat)progress;


@end

@interface TXPageSegmentationController : NSObject

@property (nonatomic,strong) id<PageSegmentationDelegate> delegate;
@property (nonatomic) BOOL isRuning;//运行状态
@property (nonatomic) NSInteger totalPage;//总共分了多少页
@property (nonatomic) CGFloat progress;//处理进度

- (void)setFileWithPath:(NSString *)path attribute:(NSDictionary *)attribute pageSize:(CGSize)pageSize;
- (void)setFileWithPath:(NSString *)path attribute:(NSDictionary *)attribute pageSize:(CGSize)pageSize offsetList:(NSMutableArray *)offsetList;

- (NSString *)getContentWithPage:(NSUInteger)pageNum;
- (NSUInteger)getPageWithOffset:(unsigned long long)offset;
- (unsigned long long)getOffsetWithPage:(NSUInteger)page;
@end



