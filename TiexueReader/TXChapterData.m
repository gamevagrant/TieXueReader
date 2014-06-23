//
//  TXChapterData.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXChapterData.h"
static NSString * const kBookName = @"bookName";
static NSString * const kBookID = @"bookID";
static NSString * const kChapterName = @"chapterName";
static NSString * const kChapterID = @"chapterID";
static NSString * const kchapterPrice = @"chapterPrice";
static NSString * const kisVIP = @"isVip";
static NSString * const kisBuy = @"isBuy";
static NSString * const kPreChapterID = @"prcChapterID";
static NSString * const kNextChapterID = @"nextChapterID";
static NSString * const kOffsetList = @"offsetList";
static NSString * const kfileSize = @"fileSize";
static NSString * const klastUpdateTime = @"lastUpdateTime";

@implementation TXChapterData

- (id)init
{
    self =[super init];
    if (self) {
        self.offsetList = [[NSMutableDictionary alloc]init];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bookName forKey:kBookName];
    [aCoder encodeInteger:self.bookID forKey:kBookID];
    [aCoder encodeObject:self.chapterName forKey:kChapterName];
    [aCoder encodeInteger:self.chapterID forKey:kChapterID];
    [aCoder encodeFloat:self.chapterPrice forKey:kchapterPrice];
    [aCoder encodeBool:self.isVIP forKey:kisVIP];
    [aCoder encodeBool:self.isBuy forKey:kisBuy];
    [aCoder encodeInteger:self.preChapterID forKey:kPreChapterID];
    [aCoder encodeInteger:self.nextChapterID forKey:kNextChapterID];
    [aCoder encodeObject:self.offsetList forKey:kOffsetList];
    [aCoder encodeInt64:self.fileSize forKey:kfileSize];
    [aCoder encodeInt64:self.lastUpdateTime forKey:klastUpdateTime];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.bookName = [aDecoder decodeObjectForKey:kBookName];
        self.bookID = [aDecoder decodeIntegerForKey:kBookID];
        self.chapterName = [aDecoder decodeObjectForKey:kChapterName];
        self.chapterID = [aDecoder decodeIntegerForKey:kChapterID];
        self.chapterPrice = [aDecoder decodeFloatForKey:kchapterPrice];
        self.isVIP = [aDecoder decodeBoolForKey:kisVIP];
        self.isBuy = [aDecoder decodeBoolForKey:kisBuy];
        self.preChapterID = [aDecoder decodeIntegerForKey:kPreChapterID];
        self.nextChapterID = [aDecoder decodeIntegerForKey:kNextChapterID];
        self.offsetList = [aDecoder decodeObjectForKey:kOffsetList];
        self.fileSize = [aDecoder decodeInt64ForKey:kfileSize];
        self.lastUpdateTime = [aDecoder decodeInt64ForKey:klastUpdateTime];
    }
    
    return self;
}
@end
