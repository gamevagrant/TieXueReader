//
//  TXMallBookRankTableViewCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-15.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallBookRankTableViewCell.h"
#import "TXSourceManager.h"
#import "TXEnumeUtils.h"
#import "TXAppUtils.h"

@implementation TXMallBookRankTableViewCell

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

- (void)setBookData:(TXBookData *)bookData
{
    _bookData = bookData;
    [TXAppUtils loadImageByThreadWithView:self.bookCover url:self.bookData.frontCoverUrl];
    self.nameLabel.text = self.bookData.bookName;
    self.scoreLabel.text = [NSString stringWithFormat:@"评分:%li",(long)self.bookData.bookscore] ;
    self.clickNumLabel.text = [NSString stringWithFormat:@"点击:%li",(long)self.bookData.viewcount];
    self.summaryLabel.text = self.bookData.summaryl;
    self.authorLabel.text = self.bookData.author;
    self.statusLabel.text = self.bookData.bookStateName;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.nameLabel.text = nil;
    self.scoreLabel.text = nil;
    self.clickNumLabel.text = nil;
    self.summaryLabel.text = nil;
    self.authorLabel.text = nil;
    self.statusLabel.text = nil;
    self.bookCover.image = [UIImage imageNamed:@"loading"];

}
@end
