//
//  TXUserConfig.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-20.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TXUserData;

@interface TXUserConfig : NSObject <NSCoding>
@property (nonatomic,strong) NSString *fontName;//字体名称
@property (nonatomic) NSInteger fontSize;//字体大小
@property (nonatomic) float lineHeightMultiple;//行间距 行距的倍数
@property (nonatomic) BOOL isNightMode;//是否是夜间模式

@property (nonatomic,strong) NSMutableDictionary *bookDataList;//书籍数据列表 书籍id位key txBookData位值
@property (nonatomic,strong) TXUserData *userData;//用户数据

@property (nonatomic,strong) NSMutableArray *historySearchData;//历史搜索记录
@property (nonatomic,strong) NSMutableArray *historyReadData;//历史阅读记录
@property (nonatomic,strong) NSMutableArray *operateList;//离线操作记录

+ (TXUserConfig *)instance;

//归档数据
- (void)archiveData;
- (void)clearCache;
@end
