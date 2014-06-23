//
//  TXBookShelfCollectionCell.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-24.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookShelfCollectionCell.h"
#import "TXSourceManager.h"
#import "TXAppUtils.h"

@implementation TXBookShelfCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setDataWithBookData:(TXBookData *)data
{
    self.data = data;
    self.bookNameLabel.text = data.bookName;
    self.authorLabel.text = data.author;
    self.flagNew.hidden = data.lastUpdateTime>data.chapterListlastUpdateTime?NO:YES;
    

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:data.frontCoverUrl];
        UIImage *image = [TXAppUtils getImageFromCacheWithURL:url];

        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //这里写视图更新相关得方法 视图只能在主线程更新
                self.image.image = image;
                UIView *view = self.image;
                
                view.layer.shadowOffset = CGSizeMake(1, 2);// 阴影的范围
                view.layer.shadowRadius = 2;// 阴影扩散的范围控制
                view.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
                view.layer.shadowOpacity = 0.5;// 阴影透明度
//                view.layer.shouldRasterize = YES;//不设置这个 阴影会让滑动卡顿
                view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;//不设置这个 阴影会让滑动卡顿
            });
        }
        
    });
    
    
    
}

//在循环利用这个cell的时候系统会调用此方法来使控件回到初始状态
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.data = nil;
    self.bookNameLabel.text = nil;
    self.authorLabel.text = nil;
    self.image.image = [UIImage imageNamed:@"loading"];
}
@end
