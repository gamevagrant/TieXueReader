//
//  TXBookInfoTableViewCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookInfoTableViewCell.h"
#import "TXSourceManager.h"
#import "TXBookData.h"
#import "TXAppUtils.h"

TXBookData *bookData;
@implementation TXBookInfoTableViewCell

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


- (void)setBookInfo:(NSDictionary *)bookInfo
{
    _bookInfo = bookInfo;
    
    NSDictionary *data = _bookInfo;
    bookData = [[TXBookData alloc]init];
    bookData.bookName = data[@"bookname"];
    bookData.bookID = [data[@"bookid"] integerValue];
    bookData.author = data[@"penname"];
    bookData.frontCoverUrl = data[@"coverurl"];
    
    bookData.lastUpdateTime = [data[@"lastUpdateTime"] unsignedLongLongValue];
    bookData.lastChapterID = [data[@"lastChapterId"] integerValue];
    bookData.lastChapterName = data[@"lastChapterName"];
    
    bookData.bookscore = [data[@"bookscore"] integerValue];
    bookData.viewcount = [data[@"viewcount"] integerValue];
    bookData.collectnum = [data[@"collectnum"] integerValue];
    bookData.commentnum = [data[@"commentnum"] integerValue];
    bookData.summaryl = data[@"summary"];
    
    bookData.bookStateName = data[@"bookstatename"];
    bookData.bookKindName = data[@"bookkindname"];
    
    self.bookName.text = bookData.bookName;
    self.bookAuthor.text = bookData.author;
    self.bookKind.text = bookData.bookKindName;
    self.bookScore.text = [NSString stringWithFormat:@"%li",(long)bookData.bookscore] ;
    self.bookStatus.text = bookData.bookStateName;
    
//    self.bookName.textColor = [TXAppUtils instance].titleFontTint;
//    self.bookAuthor.textColor = [TXAppUtils instance].fontTint;
//    self.bookKind.textColor = [TXAppUtils instance].fontTint;
//    self.bookScore.textColor = [TXAppUtils instance].fontTint;
//    self.bookStatus.textColor = [TXAppUtils instance].fontTint;
    //    self.bookCover.image = [TXSourceManager getImageFromCacheWithURL:[NSURL URLWithString:self.bookInfo[@"coverurl"]]];
    [TXAppUtils loadImageByThreadWithView:self.bookCover url:self.bookInfo[@"coverurl"]];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addBookShelfBtnHandle:(id)sender
{
    

    [TXSourceManager addBookToShelfWithBookData:bookData completionHandler:^(BOOL isSuccess,NSError *error) {
        if (isSuccess)
        {
            [TXAppUtils showAlertWithTitle:nil Message:@"添加成功"];
        }else
        {
            [TXAppUtils showAlertWithTitle:@"请求失败" Message:error.localizedDescription];
        }
    }];
    
}

@end
