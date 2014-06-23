//
//  TXNetController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXNetProtocol.h"
@class TXUserConfig;
@class TXUserData;
@class TXBookData;

#define CUSTOM_ERROR_DOMAIN @"com.tiexue.reader"

typedef enum : NSUInteger {
    TXNetErrorNotNetWorking = -1000,//没有网络
    TXNetErrorNetworkFailure,//网络故障
    TXNetErrorEmptyData,//空数据
    TXNetErrorDataAnomalies,//数据异常
    TXNetErrorOperationFailed//操作失败
} TXNetErrorType;

@interface TXSourceManager : NSObject
//获取书籍内容
+ (void)downloadWholeBookWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList completionHandler:(void(^)(NSDictionary *list, NSError *error))completionHandler;
//获取书籍章节列表
+ (void)getChapterListWithBookID:(NSInteger)bookID completionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler;
//获取书架列表
+ (void)getBookShelfListWithCompletionHandler:(void(^)(NSMutableDictionary *data, NSError *error))completionHandler;
//获取匿名书架列表
+ (void)getTempBookshelfListWithBookIDList:(NSArray *)bookIDList completionHandler:(void(^)(NSMutableDictionary *data, NSError *error))completionHandler;
//添加书籍到书架
+ (void)addBookToShelfWithBookData:(TXBookData *)bookData completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler;
//从书架移除书籍
+ (void)removeBookFromShelfWithBookData:(TXBookData *)bookData completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler;
//同步书架离线操作
+ (void)syncShelfOperate:(NSArray *)operateList completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler;


//获取商城推荐列表
+ (void)getMallListWithCompletionHandler:(void(^)(NSMutableDictionary *data, NSError *error))completionHandler;
//获取图书列表
+ (void)getMallListWithType:(TXBookListType)type pageSize:(NSInteger)size pageIndex:(NSInteger)index completionHandler:(void(^)(NSMutableArray *data, NSError *error))completionHandler;
//获取排行列表
+ (void)getMallRankListWithCompletionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler;
//获取书籍详情
+ (void)getBookInfoWithBookID:(NSInteger)bookID completionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler;

+ (NSArray *)getMallKindList;
//获取热门搜索列表
+ (void)getHotSearchDataWithCompletionHandler:(void(^)(NSArray *data, NSError *error))completionHandler;
//搜索书籍
+ (void)searchBookWithContent:(NSString *)content pageSize:(NSInteger)pageSize pageIndex:(NSInteger)pageIndex completionHandler:(void(^)(NSArray *list, NSError *error))completionHandler;


//获取章节状态
+ (void)getChapterStatusWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList completionHandler:(void(^)(NSArray *list, NSError *error))completionHandler;
//获取订单信息
+ (void)getChapterOrderWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID completionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler;
//订阅章节
+ (void)subscriptionWithBookID:(NSInteger)bookID type:(SubscriptionType)type chapterIDList:(NSArray *)chapterIDList completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler;


//注册
+ (void)registrationWithAccount:(NSString *)account password:(NSString *)password completionHandler:(void(^)(TXUserData *data, NSError *error))completionHandler;
//登陆
+ (void)loginWithAccount:(NSString *)account passWord:(NSString *)password completionHandler:(void(^)(TXUserData *data, NSError *error))completionHandler;
//获取用户信息
+ (void)getUserInfoWithToken:(NSString *)token completionHandler:(void(^)(TXUserData *data, NSError *error))completionHandler;
//反馈
+ (void)feedbackWithContent:(NSString *)content completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler;



@end
