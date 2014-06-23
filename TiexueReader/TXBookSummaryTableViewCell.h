//
//  TXBookSummaryTableViewCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXBookSummaryTableViewCell : UITableViewCell
@property (strong, nonatomic) NSDictionary *bookInfo;

@property (strong, nonatomic) IBOutlet UILabel *bookSummary;

@end
