//
//  TXBookShelfCollectionCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-24.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXBookData.h"

@interface TXBookShelfCollectionCell : UICollectionViewCell
@property (strong, nonatomic) TXBookData *data;

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *bookNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *flagNew;

- (void)setDataWithBookData:(TXBookData *)data;
@end
