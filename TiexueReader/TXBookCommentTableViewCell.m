//
//  TXCommentTableViewCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-9.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookCommentTableViewCell.h"
#import "TXAppUtils.h"

@implementation TXBookCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setComment:(NSDictionary *)comment
{
    _comment = comment;
    self.content.text = self.comment[@"content"];
    self.content.textColor = [TXAppUtils instance].fontTint;
    self.playerName.text = self.comment[@"cname"];
    self.date.text = [TXAppUtils getTimeIntervalFromTimestamp:[self.comment[@"time"] doubleValue]];
    [self.content sizeToFit];
    [self addSubview:self.content];
}

@end
