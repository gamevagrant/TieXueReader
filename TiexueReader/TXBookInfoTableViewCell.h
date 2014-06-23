//
//  TXBookInfoTableViewCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXBookInfoTableViewCell : UITableViewCell
@property (strong, nonatomic) NSDictionary *bookInfo;

@property (strong, nonatomic) IBOutlet UIImageView *bookCover;
@property (strong, nonatomic) IBOutlet UILabel *bookName;
@property (strong, nonatomic) IBOutlet UILabel *bookAuthor;
@property (strong, nonatomic) IBOutlet UILabel *bookKind;
@property (strong, nonatomic) IBOutlet UILabel *bookStatus;
@property (strong, nonatomic) IBOutlet UILabel *bookScore;
@property (strong, nonatomic) IBOutlet UIButton *startReadButton;
@property (strong, nonatomic) IBOutlet UIButton *addBookShelfButton;

@end
