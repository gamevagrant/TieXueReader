//
//  TXBookShelfCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-2-17.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXBookData.h"

@interface TXMallBookListCell : UITableViewCell
@property (strong, nonatomic) TXBookData *data;

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *bookNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;


@end
