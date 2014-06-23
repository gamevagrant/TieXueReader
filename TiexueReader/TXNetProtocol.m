//
//  TXNetController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-3.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXNetProtocol.h"
#import "TXAppUtils.h"
#import "TXDefine.h"
#import "TXSyncShelfOperateData.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"
#import "TXUserData.h"


@implementation TXNetProtocol

+ (NSURL *)createURLWith:(NSString *)api property:(NSString *)property
{

    TXUserData *userData = [TXUserConfig instance].userData;
    NSString *token;
    if (userData) {
        token = [NSString stringWithFormat:@"token=%@&",userData.token] ;
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?%@from=2&ver=%@&%@",API_ROOT,api,token?token:@"",VERSION,property?property:@""];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//将url中的特殊字符进行转义
    NSURL *url = [NSURL URLWithString:urlStr];

    return url;
}

//--------------------------------------------------------------------------------

#pragma mark - 书架
//获取一本书的一个章节内容
+ (NSURL *)getBookDataWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList
{
//    ReadContent.aspx?bookid=11&chapterids=123|333|666
    NSMutableString *chapterProperty = [NSMutableString stringWithFormat:@"bookid=%li&chapterids=",(long)bookID];
    for (NSNumber *chapterID in chapterIDList) {
        [chapterProperty appendString:[NSString stringWithFormat:@"%li|",(long)chapterID.integerValue]];
    }
    NSURL *url = [self createURLWith:@"book/ReadContent.aspx" property:chapterProperty];
    return url;
    
}

//获取章节列表
+ (NSURL *)getChapterListWithBookID:(NSInteger)bookID
{
//    readCatalog.aspx?bookid=1
    NSURL *url = [self createURLWith:@"book/readCatalog.aspx" property:[NSString stringWithFormat:@"bookid=%li",(long)bookID]];
    return url;
    
}

//拉取本地书架内容
+ (NSURL *)getBookshelfList
{
    NSURL *url = [self createURLWith:@"book/readbookshelf.aspx" property:nil];
    return url;
}

//请求匿名书架内容
+ (NSURL *)getTempBookshelfListWithBookIDList:(NSArray *)bookIDList
{
    NSMutableString *property = [NSMutableString stringWithString:@"bookids="] ;
    for (NSNumber *bookID in bookIDList) {
        [property appendString:[NSString stringWithFormat:@"%li|",(long)bookID.integerValue]];
    }
    NSURL *url = [self createURLWith:@"book/getTempBookShelf.aspx" property:property];
    return url;
}

//同步书架操作
+ (NSURL *)syncShelfOperate:(NSArray *)list
{
    NSMutableString *log = [[NSMutableString alloc]init];
    for (TXSyncShelfOperateData *data in list)
    {
        [log appendFormat:@"%llu|%lu|%li||",(unsigned long long)(data.date.timeIntervalSince1970 * 1000),(unsigned long)data.operate,(long)data.parameter];
    }
    NSURL *url = [self createURLWith:@"book/syncShelfOperate.aspx" property:[NSString stringWithFormat:@"log=%@",log]];
    return url;
}

//将书籍加入书架
+ (NSURL *)addBookToShelfWithBookID:(NSInteger)bookID
{
    NSURL *url = [self createURLWith:@"book/addtoshelf.aspx" property:[NSString stringWithFormat:@"bookid=%li",(long)bookID]];
    return url;
}
//将书籍从书架移除
+ (NSURL *)removeBookFromShelfWithBookID:(NSInteger)bookID
{
    NSURL *url = [self createURLWith:@"book/delofshelf.aspx" property:[NSString stringWithFormat:@"bookid=%li",(long)bookID]];
    return url;
}

#pragma mark - 商城
//获取商城推荐列表
+ (NSURL *)getBookRecommendList
{
    NSURL *url = [self createURLWith:@"book/default.aspx" property:nil];
    return url;
    
}

//获取图书列表
+ (NSURL *)getMallListWithType:(NSInteger)type pageSize:(NSInteger)size pageIndex:(NSInteger)index
{
    NSURL *url = [self createURLWith:@"book/readlist.aspx" property:[NSString stringWithFormat:@"type=%li&pagesize=%li&pageindex=%li",(long)type,(long)size,(long)index]];
    return url;
    
}

//获取图书详细信息
+ (NSURL *)getBookInfoWithBookID:(NSInteger)bookID
{
    NSURL *url = [self createURLWith:@"book/ReadBookDetail.aspx" property:[NSString stringWithFormat:@"bookid=%li",(long)bookID]];
    return url;
    
}

//获取排行列表
+ (NSData *)getMallRankList
{
    NSData *data = [[NSData alloc]init];
    return data;
}
//获取类型列表
+ (NSData *)getMallKindList
{
    NSData *data = [[NSData alloc]init];
    return data;
}
//请求搜索热词
+ (NSURL *)getHotSearchData
{
    NSURL *url = [self createURLWith:@"book/hotwords.aspx" property:nil];
    return url;
}
//搜索图书
+ (NSURL *)searchBookWithContent:(NSString *)content pageSize:(NSInteger)pageSize pageIndex:(NSInteger)pageIndex
{
    NSURL *url = [self createURLWith:@"book/readsearch.aspx" property:[NSString stringWithFormat:@"keyword=%@&pagesize=%li&pageindex=%li",content,(long)pageSize,(long)pageIndex]];
    return url;
}

#pragma mark - 订阅
//获取章节订阅状态
+ (NSURL *)getChapterStatusWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList;
{
    NSMutableString *property = [NSMutableString stringWithFormat:@"bookid=%li&chapterids=",(long)bookID] ;
    for (NSNumber *chapterID in chapterIDList) {
        [property appendString:[NSString stringWithFormat:@"%li|",(long)chapterID.integerValue]];
    }
    NSURL *url = [self createURLWith:@"book/getSubStatus.aspx" property:property];
    return url;
}
//获取章节订单
+ (NSURL *)getChapterOrderWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID
{
    NSURL *url = [self createURLWith:@"book/getSubOrder.aspx" property:[NSString stringWithFormat:@"bookid=%li&chapterid=%li",(long)bookID,(long)chapterID]];
    return url;
}
//订阅章节
+ (NSURL *)subscriptionWithBookID:(NSInteger)bookID type:(SubscriptionType)type chapterIDList:(NSArray *)chapterIDList;
{
    NSMutableString *property = [NSMutableString stringWithFormat:@"type=%lu&bookid=%li&chapterids=",(unsigned long)type,(long)bookID];
    for (NSNumber *chapterID in chapterIDList) {
        [property appendString:[NSString stringWithFormat:@"%li|",(long)chapterID.integerValue]];
    }
    NSURL *url = [self createURLWith:@"book/SubscribeVip.aspx" property:property];
    return url;
}
#pragma mark - 用户协议
//注册
+ (NSURL *)registrationWithAccount:(NSString *)account password:(NSString *)password
{
    //user/readregister/?username=xxxxx&pwd=xxxxx&validcode=ssd1
    NSURL *url = [self createURLWith:@"user/readregister.aspx" property:[NSString stringWithFormat:@"username=%@&pwd=%@",account,password]];
    return url;
}
//登陆
+ (NSURL *)loginWithAccount:(NSString *)account passWord:(NSString *)password
{
    NSURL *url = [self createURLWith:@"user/readLogin.aspx" property:[NSString stringWithFormat:@"username=%@&pwd=%@",account,password]];
    return url;
}
//获取用户数据 刷新用
+ (NSURL *)getUserInfoWithToken:(NSString *)token
{
    NSURL *url = [self createURLWith:@"user/ReadGetUserInfo.aspx" property:[NSString stringWithFormat:@"token=%@",token]];
    return url;
}
//意见反馈接口
+ (NSURL *)feedbackWithContent:(NSString *)content
{
    NSURL *url = [self createURLWith:@"user/feedback.aspx" property:[NSString stringWithFormat:@"content=%@",content]];
    return url;
}
@end
