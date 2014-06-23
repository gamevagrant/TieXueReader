//
//  TXChapterListCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-19.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXChapterListCell.h"
#import "TXAppUtils.h"

@implementation TXChapterListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDataWithChapterData:(TXChapterData *)chapterData
{
    self.chapterNameLabel.text = chapterData.chapterName;
    
    BOOL isDownLoad = [TXAppUtils hasBookFileWithBookID:chapterData.bookID chapterID:chapterData.chapterID];
    self.isDownLoadLabel.text = isDownLoad?@"":@"未下载";
}
@end
