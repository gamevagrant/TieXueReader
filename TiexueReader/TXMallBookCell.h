//
//  TXMallBookCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-4.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TXBookData;


@interface TXMallBookCell : UICollectionViewCell
@property (strong, nonatomic) TXBookData *data;

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *bookNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;

- (void)setDataWithBookData:(TXBookData *)data;
@end
