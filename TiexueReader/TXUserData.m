//
//  TXUserData.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-29.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXUserData.h"

static NSString * const kuserID = @"userID";
static NSString * const kuserName = @"userName";
static NSString * const ktoken = @"token";
static NSString * const kgold = @"gold";
static NSString * const ksex = @"sex";
static NSString * const kheadImageUrl = @"headImageUrl";

@implementation TXUserData


- (id)init
{
    self =[super init];
    if (self) {
        
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.userID forKey:kuserID];
    [aCoder encodeObject:self.userName forKey:kuserName];
    [aCoder encodeObject:self.token forKey:ktoken];
    [aCoder encodeInteger:self.gold forKey:kgold];
    [aCoder encodeInteger:self.sex forKey:ksex];
    [aCoder encodeObject:self.headImageUrl forKey:kheadImageUrl];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.userID = [aDecoder decodeIntegerForKey:kuserID];
        self.userName = [aDecoder decodeObjectForKey:kuserName];
        self.token = [aDecoder decodeObjectForKey:ktoken];
        self.gold = [aDecoder decodeIntegerForKey:kgold];
        self.sex = [aDecoder decodeIntegerForKey:ksex];
        self.headImageUrl = [aDecoder decodeObjectForKey:kheadImageUrl];
    }
    
    return self;
}

@end
