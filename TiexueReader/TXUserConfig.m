//
//  TXUserConfig.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-20.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXUserConfig.h"
#import "TXUserData.h"
#import "TXAppUtils.h"

static NSString * const kFontName = @"fontName";
static NSString * const kFontSize = @"fontSize";
static NSString * const kLineHeightMultiple = @"lineHeightMultiple";
static NSString * const kBackGroundColor = @"backGroundColor";
static NSString * const kIsNightMode = @"isNightMode";
static NSString * const kBookDataList = @"bookDataList";
static NSString * const kUserData = @"userData";
static NSString * const kHistorySearchData = @"historySearchData";
static NSString * const kHistoryReadData = @"historyReadData";
static NSString * const kOperateList = @"operateList";

static TXUserConfig *_instance;
@implementation TXUserConfig

+ (TXUserConfig *)instance
{
    if (!_instance) {
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *filePath = [TXAppUtils getUserConfigFilePath];
        //判断文件是否存在
        if ([fm fileExistsAtPath:filePath])
        {
            _instance = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            
            NSLog(@"解析本地用户数据: %@",_instance?@"成功":@"失败");
        }else
        {
            _instance = [[TXUserConfig alloc]init];
        }
        
    }
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.fontName = @"Heiti SC";
        self.fontSize = 20;
        self.lineHeightMultiple = 1.5;
        self.bookDataList = [[NSMutableDictionary alloc]init];
        self.historySearchData = [[NSMutableArray alloc]init];
        self.historyReadData = [[NSMutableArray alloc]init];
        self.operateList = [[NSMutableArray alloc]init];
        
        self.isNightMode = NO;

    }
    return self;
    
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.fontName forKey:kFontName];
    [aCoder encodeInteger:self.fontSize forKey:kFontSize];
    [aCoder encodeFloat:self.lineHeightMultiple forKey:kLineHeightMultiple];
    [aCoder encodeBool:self.isNightMode forKey:kIsNightMode];
    [aCoder encodeObject:self.bookDataList forKey:kBookDataList];
    [aCoder encodeObject:self.userData forKey:kUserData];
    [aCoder encodeObject:self.historySearchData forKey:kHistorySearchData];
    [aCoder encodeObject:self.historyReadData forKey:kHistoryReadData];
    [aCoder encodeObject:self.operateList forKey:kOperateList];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.fontName = [aDecoder decodeObjectForKey:kFontName];
        self.fontSize = [aDecoder decodeIntegerForKey:kFontSize];
        self.lineHeightMultiple = [aDecoder decodeFloatForKey:kLineHeightMultiple];
        self.isNightMode = [aDecoder decodeBoolForKey:kIsNightMode];
        self.bookDataList = [aDecoder decodeObjectForKey:kBookDataList];
        self.userData = [aDecoder decodeObjectForKey:kUserData];
        self.historySearchData = [aDecoder decodeObjectForKey:kHistorySearchData];
        self.historyReadData = [aDecoder decodeObjectForKey:kHistoryReadData];
        self.operateList = [aDecoder decodeObjectForKey:kOperateList];

    }
    
    return self;
}

//归档数据
- (void)archiveData
{
    //归档用户数据
    BOOL isSuccess = [NSKeyedArchiver archiveRootObject:self toFile:[TXAppUtils getUserConfigFilePath]];
    
    NSLog(@"归档用户数据: %@",isSuccess?@"成功":@"失败");
    
}

- (void)clearCache
{
    self.bookDataList = [[NSMutableDictionary alloc]init];
    self.historySearchData = [[NSMutableArray alloc]init];
    self.historyReadData = [[NSMutableArray alloc]init];
    self.operateList = [[NSMutableArray alloc]init];
}
@end
