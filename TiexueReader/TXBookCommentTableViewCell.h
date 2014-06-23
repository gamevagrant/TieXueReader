//
//  TXCommentTableViewCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-9.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXBookCommentTableViewCell : UITableViewCell
@property (strong, nonatomic) NSDictionary *comment;

@property (strong, nonatomic) IBOutlet UILabel *playerName;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *content;

@end
