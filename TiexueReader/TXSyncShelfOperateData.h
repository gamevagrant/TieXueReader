//
//  TXSyncShelfOperateData.h
//  TiexueReader
//
//  Created by 齐宇 on 14-5-21.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TX_ENUM_SYNC_OPERATE_SHELF_ADD = 1,
    TX_ENUM_SYNC_OPERATE_SHELF_DELETE

}TXEnumSyncShelfOperate;

@interface TXSyncShelfOperateData : NSObject<NSCoding>
@property (nonatomic, strong) NSDate *date;//时间
@property (nonatomic) TXEnumSyncShelfOperate operate;//操作
@property (nonatomic) NSInteger parameter;//参数
@end
