//
//  TXUserData.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-29.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXUserData : NSObject<NSCoding>

@property (nonatomic) NSInteger userID;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *token;
@property (nonatomic) NSInteger gold;
@property (nonatomic) NSInteger sex;
@property (nonatomic,strong) NSString *headImageUrl;
@end
