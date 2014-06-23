//
//  TXBookShelfCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-17.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallBookListCell.h"
#import "TXSourceManager.h"
#import "TXEnumeUtils.h"
#import "TXAppUtils.h"

@implementation TXMallBookListCell
{
    BOOL isFirstLayout;
}

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

- (void)setData:(TXBookData *)data
{
    _data = data;
    self.bookNameLabel.text = self.data.bookName;
    self.authorNameLabel.text = self.data.author;
    self.summaryLabel.text = self.data.summaryl;
    self.statusLabel.text = self.data.bookStateName;
    [TXAppUtils loadImageByThreadWithView:self.image url:self.data.frontCoverUrl];
}

//在循环利用这个cell的时候系统会调用此方法来使控件回到初始状态
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.bookNameLabel.text = nil;
    self.authorNameLabel.text = nil;
    self.summaryLabel.text = nil;
    self.statusLabel.text = nil;
    self.image.image = [UIImage imageNamed:@"loading"];
}

@end
