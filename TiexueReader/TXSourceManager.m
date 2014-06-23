//
//  TXNetController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//


#import "TXSourceManager.h"
#import "TXNetProtocol.h"
#import "TXAppUtils.h"
#import "TXChapterData.h"
#import "TXBookData.h"
#import "TXUserConfig.h"
#import "TXUserData.h"
#import "TXSyncShelfOperateData.h"





static NSURLSessionConfiguration *sessionConfiguration;
static NSURLSession *session;

@implementation TXSourceManager

//解析json数据
+ (NSDictionary *)jsonDictionWithData:(NSData *)data
{
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    

    return json;
}


//启动一个异步的网络加载任务
+ (void)resumeSessionDataTaskWithURL:(NSURL *)url completionHandler:(void(^)(NSDictionary *json, NSURLResponse *response, NSError *error))completionHandler
{
    __block NSDictionary *userInfo;
    __block NSError *cError;
    
    if (![TXAppUtils hasNetworking])
    {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"无网络连接",NSLocalizedDescriptionKey,@"无法连接网络",NSLocalizedFailureReasonErrorKey,nil];
        cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorNotNetWorking userInfo:userInfo];
    
        completionHandler(nil,nil,cError);
        return;
    }
    
    if (!sessionConfiguration) {
        sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForResource = 10;
    }
    if (!session) {
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:error.localizedDescription,NSLocalizedDescriptionKey,@"调用SessionTask请求出错",NSLocalizedFailureReasonErrorKey,nil];
            cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorNetworkFailure userInfo:userInfo];
            
            completionHandler(nil,nil,cError);
            return;
        }
        
        if (!data)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"空数据",NSLocalizedDescriptionKey,@"请求回来的数据为nil",NSLocalizedFailureReasonErrorKey,nil];
            cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorEmptyData userInfo:userInfo];
            
            completionHandler(nil,nil,cError);
            return;
        }
        
        NSDictionary *json = [self jsonDictionWithData:data];
        if (!json)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"数据解析失败",NSLocalizedDescriptionKey,@"解析json数据失败，可能返回的数据不是json或json格式不正确",NSLocalizedFailureReasonErrorKey,nil];
            cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorDataAnomalies userInfo:userInfo];
            
            completionHandler(nil,nil,cError);
            return;

        }
        
        NSNumber *ret = json[@"ret"];
        NSString *msg = json[@"msg"];
        if (ret.integerValue!=0)
        {
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg,NSLocalizedDescriptionKey,[NSString stringWithFormat:@"操作失败 code:%@",ret],NSLocalizedFailureReasonErrorKey,nil];
            cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorOperationFailed userInfo:userInfo];
            
            completionHandler(nil,nil,cError);
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionHandler(json,response,nil);
            
        });
        
        
    }];
    [task resume];

}


#pragma mark - 书架相关
//下载书 先查询本地有没有，没有则下载，然后保存在本地 返回 path
+ (void)downloadWholeBookWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList completionHandler:(void(^)(NSDictionary *list, NSError *error))completionHandler
{
    //检索出本地没有的章节文件
    NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
    NSMutableArray *needChapterList = [[NSMutableArray alloc]init];
    for (NSNumber *chapterID in chapterIDList)
    {
        if (![TXAppUtils hasBookFileWithBookID:bookID chapterID:chapterID.integerValue])
        {
            [needChapterList addObject:chapterID];
        }else
        {
            NSString *filePath = [TXAppUtils getBookPathWithBookID:bookID chapterID:chapterID.integerValue];
            [result setObject:filePath forKey:chapterID];
        }
    }
    
    //如果全部章节本地都有直接返回数据
    if (needChapterList.count==0) {
        completionHandler(result,nil);
        return;
    }
    //下载列表上的书籍
    NSMutableArray *needDownLoadList = [NSMutableArray arrayWithArray:needChapterList];
    NSMutableArray *didDownLoadList = [[NSMutableArray alloc]init];
    [self downLoadBookWithBookID:bookID needDownLoadList:needDownLoadList didDownLoadList:didDownLoadList completionHandler:^(NSInteger bookID, NSArray *didDownLoadList,NSError *error) {
        for (NSNumber *chapterID in didDownLoadList) {
            NSString *filePath = [TXAppUtils getBookPathWithBookID:bookID chapterID:chapterID.integerValue];
            [result setObject:filePath forKey:chapterID];
        }
        if (error) {
            completionHandler(result,error);
        }else
        {
            completionHandler(result,nil);
        }
        
    }];

}

+ (void)downLoadBookWithBookID:(NSInteger)bookID needDownLoadList:(NSMutableArray *)needDownLoadList didDownLoadList:(NSMutableArray *)didDownLoadList completionHandler:(void (^)(NSInteger bookID,NSArray *didDownLoadList,NSError *error)) completionHandler
{
    if (needDownLoadList.count==0)
    {
        completionHandler(bookID,didDownLoadList,nil);
        return;
    }
    NSNumber *chapterID = [needDownLoadList objectAtIndex:0] ;
    [needDownLoadList removeObjectAtIndex:0];
    //从网上下载 待下载列表中的章节数据
    NSArray *needDownLoadID = [NSArray arrayWithObjects:chapterID, nil];
    NSURL *url = [TXNetProtocol getBookDataWithBookID:bookID chapterIDList:needDownLoadID];
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            NSLog(@"downLoad:%@",chapterID);
            NSArray *list = json[@"content_list"];
            
            for (NSDictionary *dic in list)
            {
                //将数据保存在本地
                NSNumber *chapterID = dic[@"chapterid"];
                NSString *chapterContent = dic[@"content"];
                NSData *contentData = [chapterContent dataUsingEncoding:NSUTF8StringEncoding];
                if (![TXAppUtils saveBookWithBookID:bookID chapterID:chapterID.integerValue data:contentData])
                {
                    NSLog(@"将书籍内容保存本地失败");
                }
                
            }
            //有失败的就停止了 后面就不继续了
            [didDownLoadList addObject:chapterID];
            [self downLoadBookWithBookID:bookID needDownLoadList:needDownLoadList didDownLoadList:didDownLoadList completionHandler:completionHandler];
        }else
        {
            completionHandler(bookID,didDownLoadList,error);
        }
        
        
    }];

    
}
//获取章节列表
+ (void)getChapterListWithBookID:(NSInteger)bookID completionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getChapterListWithBookID:bookID];
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            TXUserConfig *userConfig = [TXUserConfig instance];
            TXBookData *book = [userConfig.bookDataList objectForKey:[NSNumber numberWithInteger:bookID]];
            
            NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
            
            NSArray *volumeList = json[@"volumes"];
            for (NSDictionary *volume in volumeList)
            {
                NSArray *chapterList = volume[@"chapterList"];
                
                
                for (NSDictionary *dic in chapterList)
                {
                    TXChapterData *data = [TXSourceManager getChapterDataWithDictionary:dic];
                    data.bookID = bookID;
                    //将以前老数据上的分页数据替换到新的章节数据上（分页数据是自己酸的 新数据上没有）
                    if (book)
                    {
                        NSNumber *key = [NSNumber numberWithInteger:data.chapterID];
                        TXChapterData *oldChapter = [book.chapterList objectForKey:key];
                        if (oldChapter)
                        {
                            data.offsetList = oldChapter.offsetList;
                            data.fileSize = oldChapter.fileSize;
                        }
                        
                    }
                    [result setObject:data forKey:[NSNumber numberWithInteger:data.chapterID]];
                    
                }
                
            }
            
            completionHandler(result,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
    }];


}

//获取书架列表
+ (void)getBookShelfListWithCompletionHandler:(void(^)(NSMutableDictionary *data, NSError *error))completionHandler
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    TXUserData *userData = userConfig.userData;
    if (!userData || ![TXAppUtils hasNetworking])
    {
        //取本地书架数据
        completionHandler(userConfig.bookDataList,nil);
    }else
    {

        NSURL *url = [TXNetProtocol getBookshelfList];
        [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
            if (json)
            {
                NSArray *list = json[@"bookinfos"];
                
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                for (NSDictionary *dic in list)
                {
                    //将以前老数据中的章节数据替换到新数据上
                    TXBookData *book = [TXSourceManager getBookDataWithDictionaryByShelf:dic];
                    NSNumber *key = [NSNumber numberWithInteger:book.bookID];
                    TXBookData *oldBook = [userConfig.bookDataList objectForKey:key];
                    if (oldBook)
                    {
                        [book mergerOldData:oldBook];
                    }
                    
                    [result setObject:book forKey:key];
                }
                userConfig.bookDataList = result;
                completionHandler(result,nil);

            }else
            {
                completionHandler(nil,error);
            }
            
        }];

    }
    
}
//获取匿名书架列表
+ (void)getTempBookshelfListWithBookIDList:(NSArray *)bookIDList completionHandler:(void(^)(NSMutableDictionary *data, NSError *error))completionHandler
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    TXUserData *userData = userConfig.userData;
    if (!userData || ![TXAppUtils hasNetworking])
    {
        //取本地书架数据
        completionHandler(userConfig.bookDataList,nil);
    }else
    {
        
        NSURL *url = [TXNetProtocol getBookshelfList];
        [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
            if (json)
            {
                NSArray *list = json[@"bookinfos"];
                
                NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
                for (NSDictionary *dic in list)
                {
                    //将以前老数据中的章节数据替换到新数据上
                    TXBookData *book = [TXSourceManager getBookDataWithDictionaryByShelf:dic];
                    NSNumber *key = [NSNumber numberWithInteger:book.bookID];
                    TXBookData *oldBook = [userConfig.bookDataList objectForKey:key];
                    if (oldBook)
                    {
                        [book mergerOldData:oldBook];
                    }
                    
                    [result setObject:book forKey:key];
                }
                userConfig.bookDataList = result;
                completionHandler(result,nil);
                
            }else
            {
                completionHandler(nil,error);
            }
            
        }];
        
    }

}
//添加书籍到书架
+ (void)addBookToShelfWithBookData:(TXBookData *)bookData completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    TXUserData *userData = userConfig.userData;
    
    if (!userData || ![TXAppUtils hasNetworking])
    {
        [userConfig.bookDataList setObject:bookData forKey:[NSNumber numberWithInteger:bookData.bookID]];
        
        TXSyncShelfOperateData *operateData = [[TXSyncShelfOperateData alloc]init];
        operateData.date = [NSDate date];
        operateData.operate = TX_ENUM_SYNC_OPERATE_SHELF_ADD;
        operateData.parameter = bookData.bookID;
        [userConfig.operateList addObject:operateData];
        completionHandler(YES,nil);

    }else
    {
        NSURL *url = [TXNetProtocol addBookToShelfWithBookID:bookData.bookID];
        
        [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
            if (json)
            {
                [userConfig.bookDataList setObject:bookData forKey:[NSNumber numberWithInteger:bookData.bookID]];
                completionHandler(YES,nil);
            }
            completionHandler(NO,error);

        }];
        
    }
    [TXAppUtils instance].needUpdateBookShelf = YES;
}

//从书架移除书籍
+ (void)removeBookFromShelfWithBookData:(TXBookData *)bookData completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    TXUserData *userData = userConfig.userData;
    if (!userData || ![TXAppUtils hasNetworking])
    {
        [userConfig.bookDataList removeObjectForKey:[NSNumber numberWithInteger:bookData.bookID]];
        
        TXSyncShelfOperateData *operateData = [[TXSyncShelfOperateData alloc]init];
        operateData.date = [NSDate date];
        operateData.operate = TX_ENUM_SYNC_OPERATE_SHELF_DELETE;
        operateData.parameter = bookData.bookID;
        [userConfig.operateList addObject:operateData];
        completionHandler(YES,nil);

    }else
    {
        
        NSURL *url = [TXNetProtocol removeBookFromShelfWithBookID:bookData.bookID];
        
        [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
            if (json)
            {
                [userConfig.bookDataList removeObjectForKey:[NSNumber numberWithInteger:bookData.bookID]];
                completionHandler(YES,nil);
            }else
            {
                completionHandler(NO,error);
            }

        }];
    }
    [TXAppUtils instance].needUpdateBookShelf = YES;
}

//同步书架离线操作
+ (void)syncShelfOperate:(NSArray *)operateList completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol syncShelfOperate:operateList];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            completionHandler(YES,nil);
        }else
        {
            completionHandler(NO,error);
        }
        
        
    }];
}

#pragma mark - 商城相关
//获取商城推荐列表 字典的key为所在组的类型 值为bookData的列表
+ (void)getMallListWithCompletionHandler:(void(^)(NSMutableDictionary *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getBookRecommendList];
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
            for (NSDictionary *item in [json objectForKey:@"homeparts"])
            {
                NSNumber *type = [NSNumber numberWithInt:[[item objectForKey:@"type"]intValue]];
                NSMutableArray *bookList = [[NSMutableArray alloc]init];
                [result setObject:bookList forKey:type];
                for (NSDictionary *bookJson in [item objectForKey:@"book_infos"])
                {
                    TXBookData *book = [TXSourceManager getBookDataWithDictionary:bookJson];
                    [bookList addObject:book];
                }
            }
            
            completionHandler(result,nil);

        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];
    
}

//获取图书列表
+ (void)getMallListWithType:(TXBookListType)type pageSize:(NSInteger)size pageIndex:(NSInteger)index completionHandler:(void(^)(NSMutableArray *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getMallListWithType:(NSInteger)type pageSize:size pageIndex:index];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            NSArray *list = json[@"bookinfos"];
            NSMutableArray *result = [[NSMutableArray alloc]init];
            for (int i =0 ; i<list.count; i++)
            {
                NSDictionary *item = list[i];
                TXBookData *book = [TXSourceManager getBookDataWithDictionary:item];
                [result addObject:book];
            }
            
            completionHandler(result,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
    }];
    
}

//获取排行列表
+ (void)getMallRankListWithCompletionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler
{
    __block NSDictionary *userInfo;
    __block NSError *cError;
    if (![TXAppUtils hasNetworking])
    {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"无网络连接,请打开无线网络",NSLocalizedDescriptionKey,@"无法连接网络",NSLocalizedFailureReasonErrorKey,nil];
        cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorNotNetWorking userInfo:userInfo];
        completionHandler(nil,cError);
    }
    NSArray *typeList = [NSArray arrayWithObjects:[NSNumber numberWithInteger:TX_ENUME_MALL_BOOKLIST_TYPE_RANK_DIAN_JI] ,[NSNumber numberWithInteger:TX_ENUME_MALL_BOOKLIST_TYPE_RANK_RE_XIAO],[NSNumber numberWithInteger:TX_ENUME_MALL_BOOKLIST_TYPE_RANK_GENG_XIN], [NSNumber numberWithInteger:TX_ENUME_MALL_BOOKLIST_TYPE_RANK_SHOU_CANG],[NSNumber numberWithInteger:TX_ENUME_MALL_BOOKLIST_TYPE_RANK_JUN_SHI],[NSNumber numberWithInteger:TX_ENUME_MALL_BOOKLIST_TYPE_RANK_LI_SHI],nil];
    
    //异步获取多个图书列表合成一个排行列表 如果服务器提供一个直接的接口这里可需要修改成使用nsSession加载资源
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    // 异步下载图片
    dispatch_async(queue, ^{
        // 创建一个组
        dispatch_group_t group = dispatch_group_create();
        
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        
        for (NSNumber *type in typeList)
        {
            // 关联一个任务到group
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                NSURL *url = [TXNetProtocol getMallListWithType:type.integerValue pageSize:5 pageIndex:1];
                NSData *data = [NSData dataWithContentsOfURL:url];
                if (data)
                {
                    NSDictionary *json = [self jsonDictionWithData:data];
                    if (json)
                    {
                        NSArray *list = json[@"bookinfos"];
                        NSMutableArray *rankList = [[NSMutableArray alloc]init];
                        for (int i =0 ; i<list.count; i++)
                        {
                            NSDictionary *item = list[i];
                            TXBookData *book = [TXSourceManager getBookDataWithDictionary:item];
                            [rankList addObject:book];
                        }
                        
                        [dic setObject:rankList forKey:type];
                    }
                }
                
            });
        }
        
        // 等待组中的任务执行完毕,回到主线程执行block回调
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (dic.count>0)
            {
                completionHandler(dic,nil);
            }else
            {
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"空数据",NSLocalizedDescriptionKey,@"请求回来的数据为nil",NSLocalizedFailureReasonErrorKey,nil];
                cError = [NSError errorWithDomain:CUSTOM_ERROR_DOMAIN code:TXNetErrorEmptyData userInfo:userInfo];
                completionHandler(nil,cError);
            }
            
        });

    });

}


//获取书籍详细信息 取得的是直接从json转化成的dic
+ (void)getBookInfoWithBookID:(NSInteger)bookID completionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getBookInfoWithBookID:bookID];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            completionHandler(json,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];

}




+ (NSArray *)getMallKindList
{
    NSArray *list = [NSArray arrayWithObjects:@40,@41,@42,@43,@44,@45,@46,@47,@48,@49, nil];
    return list;
}




//获取热门搜索列表
+ (void)getHotSearchDataWithCompletionHandler:(void(^)(NSArray *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getHotSearchData];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            NSArray *list = json[@"words"];
            completionHandler(list,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];
}
//获取搜索结果列表
+ (void)searchBookWithContent:(NSString *)content pageSize:(NSInteger)pageSize pageIndex:(NSInteger)pageIndex completionHandler:(void(^)(NSArray *list, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol searchBookWithContent:content pageSize:pageSize pageIndex:pageIndex];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            NSArray *list = json[@"bookinfos"];
            NSMutableArray *resultList = [[NSMutableArray alloc]init];
            for (int i =0 ; i<list.count; i++)
            {
                NSDictionary *item = list[i];
                TXBookData *book = [TXSourceManager getBookDataWithDictionary:item];
                [resultList addObject:book];
            }

            completionHandler(resultList,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];
}

#pragma mark - 订阅相关
//获取章节状态
+ (void)getChapterStatusWithBookID:(NSInteger)bookID chapterIDList:(NSArray *)chapterIDList completionHandler:(void(^)(NSArray *list, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getChapterStatusWithBookID:bookID chapterIDList:chapterIDList];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            NSArray *list = json[@"chapterStatusList"];
            
            completionHandler(list,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
    }];
}
//获取订单信息
+ (void)getChapterOrderWithBookID:(NSInteger)bookID chapterID:(NSInteger)chapterID completionHandler:(void(^)(NSDictionary *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getChapterOrderWithBookID:bookID chapterID:chapterID];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            completionHandler(json,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
    }];
}
//订阅章节
+ (void)subscriptionWithBookID:(NSInteger)bookID type:(SubscriptionType)type chapterIDList:(NSArray *)chapterIDList completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol subscriptionWithBookID:bookID type:type chapterIDList:chapterIDList];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            completionHandler(YES,nil);
        }else
        {
            completionHandler(NO,error);
        }
        
    }];
}


#pragma mark - 用户相关
//注册
+ (void)registrationWithAccount:(NSString *)account password:(NSString *)password completionHandler:(void(^)(TXUserData *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol registrationWithAccount:account password:password];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            TXUserData *userData = [self getUserDataWithDictionary:json];
            completionHandler(userData,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];
}
//登陆
+ (void)loginWithAccount:(NSString *)account passWord:(NSString *)password completionHandler:(void(^)(TXUserData *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol loginWithAccount:account passWord:password];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            TXUserData *userData = [self getUserDataWithDictionary:json];
            completionHandler(userData,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];
}
//获取用户信息
+ (void)getUserInfoWithToken:(NSString *)token completionHandler:(void(^)(TXUserData *data, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol getUserInfoWithToken:token];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            TXUserData *userData = [self getUserDataWithDictionary:json];
            completionHandler(userData,nil);
        }else
        {
            completionHandler(nil,error);
        }
        
        
    }];
}
//反馈
+ (void)feedbackWithContent:(NSString *)content completionHandler:(void(^)(BOOL isSuccess, NSError *error))completionHandler
{
    NSURL *url = [TXNetProtocol feedbackWithContent:content];
    
    [self resumeSessionDataTaskWithURL:url completionHandler:^(NSDictionary *json, NSURLResponse *response, NSError *error){
        if (json)
        {
            completionHandler(YES,nil);
        }else
        {
            completionHandler(NO,error);
        }
        
        
    }];
}

#pragma mark private

//将从服务器得到的Dictionary转换成txBookData数据
+ (TXBookData *)getBookDataWithDictionary:(NSDictionary *)data
{
    TXBookData *book = [[TXBookData alloc] init];
    book.bookName = data[@"bookname"];
    book.bookID = [data[@"bookid"] integerValue];
    book.author = data[@"penname"];
    book.frontCoverUrl = data[@"coverurl"];
    
    book.lastUpdateTime = [data[@"lastUpdateTime"] unsignedLongLongValue];
    book.lastChapterID = [data[@"lastChapterId"] integerValue];
    book.lastChapterName = data[@"lastChapterName"];
    
    book.bookscore = [data[@"bookscore"] integerValue];
    book.viewcount = [data[@"viewcount"] integerValue];
    book.collectnum = [data[@"collectnum"] integerValue];
    book.commentnum = [data[@"commentnum"] integerValue];
    book.summaryl = data[@"summary"];
    
    book.bookStateName = data[@"bookstatename"];
    book.bookKindName = data[@"bookkindname"];

    return book;
}

+ (TXBookData *)getBookDataWithDictionaryByShelf:(NSDictionary *)data
{
    TXBookData *book = [[TXBookData alloc] init];
    book.bookName = data[@"bookName"];
    book.bookID = [data[@"bookId"] integerValue];
    book.author = data[@"authorName"];
    book.frontCoverUrl = data[@"coverUrl"];
    
    book.lastUpdateTime = [data[@"lastUpdateTime"] unsignedLongLongValue];
    book.lastChapterID = [data[@"lastChapterId"] integerValue];
    book.lastChapterName = data[@"lastChapterName"];
    
    book.bookStateName = data[@"bookStateName"];
    book.bookKindName = data[@"bookkindname"];
    
    return book;
}

+ (TXChapterData *)getChapterDataWithDictionary:(NSDictionary *)data
{
    TXChapterData *chapterData = [[TXChapterData alloc]init];
    chapterData.bookName = data[@"bookName"];
    chapterData.chapterID = [data[@"id"] integerValue];
    chapterData.chapterName = data[@"chapterName"];
    chapterData.chapterPrice = [data[@"price"] floatValue];
    chapterData.isVIP = [data[@"isVIP"] boolValue];
    chapterData.isBuy = [data[@"isBuy"] boolValue];
    chapterData.preChapterID = [data[@"preChapterId"] integerValue];
    chapterData.nextChapterID = [data[@"nextChapterID"] integerValue];
    chapterData.lastUpdateTime = [data[@"lastUpdateTime"] integerValue];
    return chapterData;
}

//转换用户数据
+ (TXUserData *)getUserDataWithDictionary:(NSDictionary *)data
{
    TXUserData *userData = [[TXUserData alloc]init];
    userData.userID = [data[@"userid"]integerValue];
    userData.userName = data[@"username"];
    userData.token = data[@"token"];
    userData.gold = [data[@"gold"]integerValue];
    userData.sex = [data[@"sex"]integerValue];
    userData.headImageUrl = data[@"headimgurl"];
    return userData;
}


@end
