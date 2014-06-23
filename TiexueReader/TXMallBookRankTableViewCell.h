//
//  TXMallBookRankTableViewCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-15.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXBookData.h"

@interface TXMallBookRankTableViewCell : UITableViewCell

@property (strong, nonatomic) TXBookData *bookData;

@property (strong, nonatomic) IBOutlet UIImageView *bookCover;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *clickNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
