//
//  TXDataViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-2-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXDataViewController : UIViewController<UIGestureRecognizerDelegate>
{
    UIView *fontSettingView;
    
}
@property (strong, nonatomic) IBOutlet UILabel *bookInfoLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UILabel *pageNumLabel;



@property (nonatomic) NSUInteger currentChapterID;//当前章节
@property (nonatomic) NSUInteger currentPage;//当前页
@property (nonatomic) NSUInteger totalPage;//总页数
@property (nonatomic) CGFloat progress;//处理进度

@property (strong,nonatomic) NSString *bookInfo;
@property (strong, nonatomic) NSAttributedString *data;//当前页的数据



//- (void)updateView;
@end
