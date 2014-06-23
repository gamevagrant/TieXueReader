//
//  TXBookData.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-3.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXBookData : NSObject <NSCoding>

@property (nonatomic) NSInteger bookID;//图书id
@property (nonatomic,strong) NSString *bookName;//书名
@property (nonatomic,strong) NSString *author;//作者
@property (nonatomic,strong) NSString *frontCoverUrl;//封面图片地址

@property (nonatomic) unsigned long long lastUpdateTime;//最后更新时间 毫秒
@property (nonatomic) NSInteger lastChapterID;//最后一章 章节ID
@property (nonatomic ,strong) NSString *lastChapterName;//最后一章章节名称

@property (nonatomic,strong) NSString *bookStateName;//书籍状态名称
@property (nonatomic,strong) NSString *bookKindName;//书籍类型名称
@property (nonatomic) NSInteger bookscore;//书籍评分
@property (nonatomic) NSInteger viewcount;//书籍点击数
@property (nonatomic) NSInteger collectnum;//书籍收藏数
@property (nonatomic) NSInteger commentnum;//书籍评论数
@property (nonatomic,strong) NSString *summaryl;//简介


@property (nonatomic) NSInteger currentChapterID;//当前章节
@property (nonatomic) NSInteger currentPage;//当前页数
@property (nonatomic,strong) NSDictionary *chapterList;//章节列表
@property (nonatomic) unsigned long long chapterListlastUpdateTime;//章节列表最后更新时间 毫秒

//@property (nonatomic) NSInteger bookStatus;//书籍状态
//@property (nonatomic) NSInteger bookKind;//书籍类型
//@property (nonatomic,strong) NSString *currentOffsetKey;//当前分页使用的key 字体_字号_行间距
//@property (nonatomic) NSInteger totalChapter;//总章节
//@property (nonatomic,strong) NSString *schedule;//进度

//合并旧数据
- (void)mergerOldData:(TXBookData *)oldBook;
@end

