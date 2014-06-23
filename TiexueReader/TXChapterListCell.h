//
//  TXChapterListCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-19.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXChapterData.h"

@interface TXChapterListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *chapterNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *isDownLoadLabel;

- (void)setDataWithChapterData:(TXChapterData *)chapterData;
@end
