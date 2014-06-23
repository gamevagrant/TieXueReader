//
//  TXBookRecommendTableViewCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookRecommendTableViewCell.h"
#import "TXSourceManager.h"
#import "TXAppUtils.h"
#import "TXDefine.h"
@implementation TXBookRecommendTableViewCell
{
    NSInteger width ;
    NSInteger height ;
    NSInteger itemWidth ;
    NSArray *itemDataArray;
}

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
    width = 65;
    height = 97;
    itemWidth = width + 30;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)addSubviews
{
    itemDataArray = self.bookInfo[@"recommend_list"];
    
    
    self.bookScrollView.frame = CGRectMake(self.bookScrollView.frame.origin.x, self.bookScrollView.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.bookScrollView.contentSize = CGSizeMake(itemWidth * itemDataArray.count, 50 );
    self.bookScrollView.showsHorizontalScrollIndicator = NO;
    self.bookScrollView.showsVerticalScrollIndicator = NO;
    for (NSInteger i=0;i<itemDataArray.count ;i++)
    {
        NSDictionary *item = itemDataArray[i];
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(20 + i * itemWidth, 4, width, height)];
        //        image.image = [TXSourceManager getImageFromCacheWithURL:[NSURL URLWithString:item[@"coverurl"]]];
        [TXAppUtils loadImageByThreadWithView:image url:item[@"coverurl"]];
//        image.layer.shadowOffset = CGSizeMake(1, 2);// 阴影的范围
//        image.layer.shadowRadius = 2;// 阴影扩散的范围控制
//        image.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
//        image.layer.shadowOpacity = 0.5;// 阴影透明度
//        image.layer.shadowPath = [UIBezierPath bezierPathWithRect:image.bounds].CGPath;//不设置这个 阴影会让滑动卡顿
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5 + i * itemWidth, height + 4, itemWidth, 25)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = item[@"bookname"];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [TXAppUtils instance].titleFontTint;
        [self.bookScrollView addSubview:image];
        [self.bookScrollView addSubview:label];
        
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.bookScrollView addGestureRecognizer:tap];
    
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    //通过点击的点来确认点到哪个数据
    CGPoint point = [gesture locationInView:self.bookScrollView];
    NSInteger index = (point.x - 20)/itemWidth;

    NSInteger bookID = [itemDataArray[index][@"bookid"] integerValue];
//    NSNumber *value = [NSNumber numberWithInteger:bookID];
//    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: value,@"value", nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_BOOKINFO_PAGE object:nil userInfo:info];
    
    [self.delegate nextPageWithBookID:bookID];
}

- (void)setBookInfo:(NSDictionary *)bookInfo
{
    _bookInfo = bookInfo;
    [self addSubviews];
}
@end
