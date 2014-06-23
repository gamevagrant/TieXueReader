//
//  TXBookSummaryTableViewCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookSummaryTableViewCell.h"
#import "TXAppUtils.h"

@implementation TXBookSummaryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bookSummary.numberOfLines = 0;
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

- (void)setBookInfo:(NSDictionary *)bookInfo
{
    _bookInfo = bookInfo;
//    if (self.bookSummary) {
//        [self.bookSummary removeFromSuperview];
//    }
//    
//    UILabel *label = [[UILabel alloc]init];
//    label.text = self.bookInfo[@"summary"];
//    label.textColor = [TXAppUtils instance].fontTint;
//    label.numberOfLines = 0;
//    [label sizeToFit];
//    [self addSubview:label];
//    self.bookSummary = label;
    
    self.bookSummary.text = self.bookInfo[@"summary"];
    self.bookSummary.textColor = [TXAppUtils instance].fontTint;
    [self.bookSummary sizeToFit];

    [self addSubview: self.bookSummary];
}
@end
