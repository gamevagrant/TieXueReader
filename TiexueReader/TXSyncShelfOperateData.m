//
//  TXSyncShelfOperateData.m
//  TiexueReader
//
//  Created by 齐宇 on 14-5-21.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXSyncShelfOperateData.h"

static NSString * const kdate = @"kdate";
static NSString * const koperate = @"koperate";
static NSString * const kparameter = @"kparameter";


@implementation TXSyncShelfOperateData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.date forKey:kdate];
    [aCoder encodeInteger:self.operate forKey:koperate];
    [aCoder encodeInteger:self.parameter forKey:kparameter];

    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.date = [aDecoder decodeObjectForKey:kdate];
        self.operate = [aDecoder decodeIntegerForKey:koperate];
        self.parameter = [aDecoder decodeIntegerForKey:kparameter];
    }
    
    return self;
}
@end
