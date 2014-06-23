//
//  TXChapterData.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXChapterData : NSObject<NSCoding>
@property (nonatomic,strong) NSString *bookName;        //书名
@property (nonatomic) NSInteger bookID;       //书籍ID
@property (nonatomic,strong) NSString *chapterName;     //章节名
@property (nonatomic) NSInteger chapterID;       //章节id
@property (nonatomic) float chapterPrice;    //章节价格
@property (nonatomic) BOOL isVIP;           //是否是vip章节
@property (nonatomic) BOOL isBuy;           //是否已购买
@property (nonatomic) NSInteger preChapterID;    //前一章id
@property (nonatomic) NSInteger nextChapterID;   //下一章id
@property (nonatomic) unsigned long long lastUpdateTime; //最后更新时间

@property (nonatomic,strong) NSMutableDictionary *offsetList;//分页列表的集合 以 字体_字号_行间距为key，offset的列表为值
@property (nonatomic) unsigned long long fileSize;//文件的大小 用来判断此分页数据是否过期

@end
