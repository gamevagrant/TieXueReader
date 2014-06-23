//
//  TXBookData.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-3.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookData.h"

static NSString * const kBookID = @"bookID";
static NSString * const kBookName = @"bookName";
static NSString * const kAuthor = @"author";
static NSString * const kFrontCoverUrl = @"frontCoverUrl";

static NSString * const kLastUpdateTime = @"kLastUpdateTime";//最后更新时间 毫秒
static NSString * const kLastChapterID = @"kLastChapterID";//最后一章 章节ID
static NSString * const kLastChapterName = @"kLastChapterName";//最后一章章节名称

static NSString * const kBookStateName = @"kBookStateName";//书籍状态
static NSString * const kBookKindName = @"kBookKindName";//书籍类型
static NSString * const kBookscore = @"kBookscore";//书籍评分
static NSString * const kViewcount = @"kViewcount";//书籍点击数
static NSString * const kCollectnum = @"kCollectnum";//书籍收藏数
static NSString * const kCommentnum = @"kCommentnum";//书籍评论数
static NSString * const kSummaryl = @"kSummaryl";//简介


static NSString * const kChapterList = @"chapterList";
static NSString * const kCurrentPage = @"currentPage";
static NSString * const kCurrentChapterID = @"currentChapterID";
static NSString * const kChapterListLastUpdateTime = @"kChapterListLastUpdateTime";

//static NSString * const kBookState = @"kBookState";//书籍状态
//static NSString * const kBookKind = @"kBookKind";//书籍类型
//static NSString * const kCurrentOffsetKey = @"currentOffsetKey";
//static NSString * const kTotalChapter = @"totalChapter";
//static NSString * const kSchedule = @"schedule";

@implementation TXBookData
- (id)init
{
    self =[super init];
    if (self) {
        self.currentPage = 1;

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.bookID forKey:kBookID];
    [aCoder encodeObject:self.bookName forKey:kBookName];
    [aCoder encodeObject:self.author forKey:kAuthor];
    [aCoder encodeObject:self.frontCoverUrl forKey:kFrontCoverUrl];
    
    [aCoder encodeInt64:self.lastUpdateTime forKey:kLastUpdateTime];
    [aCoder encodeInteger:self.lastChapterID forKey:kLastChapterID];
    [aCoder encodeObject:self.lastChapterName forKey:kLastChapterName];

    [aCoder encodeObject:self.bookStateName forKey:kBookStateName];
    [aCoder encodeObject:self.bookKindName forKey:kBookKindName];
    [aCoder encodeInteger:self.bookscore forKey:kBookscore];
    [aCoder encodeInteger:self.viewcount forKey:kViewcount];
    [aCoder encodeInteger:self.collectnum forKey:kCollectnum];
    [aCoder encodeInteger:self.commentnum forKey:kCommentnum];
    [aCoder encodeObject:self.summaryl forKey:kSummaryl];
    
    
    [aCoder encodeInteger:self.currentChapterID forKey:kCurrentChapterID];
    [aCoder encodeObject:self.chapterList forKey:kChapterList];
    [aCoder encodeInteger:self.currentPage forKey:kCurrentPage];
    [aCoder encodeInt64:self.chapterListlastUpdateTime forKey:kChapterListLastUpdateTime];
    
//    [aCoder encodeInteger:self.bookStatus forKey:kBookState];
//    [aCoder encodeInteger:self.bookKind forKey:kBookKind];
//    [aCoder encodeInteger:self.totalChapter forKey:kTotalChapter];
//    [aCoder encodeObject:self.schedule forKey:kSchedule];
//    [aCoder encodeObject:self.currentOffsetKey forKey:kCurrentOffsetKey];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.bookID = [aDecoder decodeIntegerForKey:kBookID];
        self.bookName = [aDecoder decodeObjectForKey:kBookName];
        self.author = [aDecoder decodeObjectForKey:kAuthor];
        self.frontCoverUrl = [aDecoder decodeObjectForKey:kFrontCoverUrl];
        
        self.lastUpdateTime = [aDecoder decodeInt64ForKey:kLastUpdateTime];
        self.lastChapterID = [aDecoder decodeIntegerForKey:kLastChapterID];
        self.lastChapterName = [aDecoder decodeObjectForKey:kLastChapterName];

        self.bookStateName = [aDecoder decodeObjectForKey:kBookStateName];
        self.bookKindName = [aDecoder decodeObjectForKey:kBookKindName];
        self.bookscore = [aDecoder decodeIntegerForKey:kBookscore];
        self.viewcount = [aDecoder decodeIntegerForKey:kViewcount];
        self.collectnum = [aDecoder decodeIntegerForKey:kCollectnum];
        self.commentnum = [aDecoder decodeIntegerForKey:kCommentnum];
        self.summaryl = [aDecoder decodeObjectForKey:kSummaryl];
        
        
        self.chapterList = [aDecoder decodeObjectForKey:kChapterList];
        self.currentPage = [aDecoder decodeIntegerForKey:kCurrentPage];
        self.currentChapterID = [aDecoder decodeIntegerForKey:kCurrentChapterID];
        self.chapterListlastUpdateTime = [aDecoder decodeInt64ForKey:kChapterListLastUpdateTime];
        
//        self.bookStatus = [aDecoder decodeIntegerForKey:kBookState];
//        self.bookKind = [aDecoder decodeIntegerForKey:kBookKind];
//        self.currentOffsetKey = [aDecoder decodeObjectForKey:kCurrentOffsetKey];
//        self.totalChapter = [aDecoder decodeIntegerForKey:kTotalChapter];
//        self.schedule = [aDecoder decodeObjectForKey:kSchedule];
    }
    
    return self;
}

//合并旧数据
- (void)mergerOldData:(TXBookData *)oldBook
{
    self.chapterList = oldBook.chapterList;
    self.currentChapterID = oldBook.currentChapterID;
    self.currentPage = oldBook.currentPage;
    self.chapterListlastUpdateTime = oldBook.chapterListlastUpdateTime;
}
@end
