//
//  TXNetController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-3.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEnumeUtils.h"

typedef enum : NSUInteger {
    SubscriptionNormal,//批量订阅
    SubscriptionWhole,//全本订阅

} SubscriptionType;
//网络协议 以后可以根据协议xml自动生成代码
@interface TXNetProtocol : NSObject

+ (NSURL *)getBookDataWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList;
+ (NSURL *)getBookshelfList;
+ (NSURL *)getTempBookshelfListWithBookIDList:(NSArray *)bookIDList;
+ (NSURL *)addBookToShelfWithBookID:(NSInteger)bookID;
+ (NSURL *)removeBookFromShelfWithBookID:(NSInteger)bookID;
+ (NSURL *)syncShelfOperate:(NSArray *)list;

+ (NSURL *)getChapterListWithBookID:(NSInteger)bookID ;
+ (NSURL *)getBookRecommendList;
+ (NSURL *)getMallListWithType:(NSInteger)type pageSize:(NSInteger)size pageIndex:(NSInteger)index;
+ (NSURL *)getBookInfoWithBookID:(NSInteger)bookID;
+ (NSData *)getMallRankList;
+ (NSData *)getMallKindList;
+ (NSURL *)getHotSearchData;
+ (NSURL *)searchBookWithContent:(NSString *)content pageSize:(NSInteger)pageSize pageIndex:(NSInteger)pageIndex;

+ (NSURL *)getChapterStatusWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList;
+ (NSURL *)getChapterOrderWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID;
+ (NSURL *)subscriptionWithBookID:(NSInteger)bookID type:(SubscriptionType)type chapterIDList:(NSArray *)chapterIDList;

+ (NSURL *)registrationWithAccount:(NSString *)account password:(NSString *)password;
+ (NSURL *)loginWithAccount:(NSString *)account passWord:(NSString *)password;
+ (NSURL *)getUserInfoWithToken:(NSString *)token;
+ (NSURL *)feedbackWithContent:(NSString *)content;

@end


