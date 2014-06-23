//
//  TXActivityIndicatorView.m
//  TiexueReader
//
//  Created by 齐宇 on 14-5-20.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXActivityIndicatorView.h"

@implementation TXActivityIndicatorView
{
    UIActivityIndicatorView *_indicator;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createIndicator];
        self.hidden = YES;
    }
    return self;
}

- (void)startAnimating
{

    dispatch_async(dispatch_get_main_queue(), ^{

        [_indicator startAnimating];
        self.hidden = NO;
//    self.superview.userInteractionEnabled = NO;

    });
    
}
- (void)stopAnimating 
{

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_indicator stopAnimating];
        self.hidden = YES;
//    self.superview.userInteractionEnabled = YES;

    });
    
}

- (void)createIndicator
{
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.backgroundColor = [UIColor blackColor];
    self.layer.cornerRadius = 15;
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [UIColor whiteColor].CGColor;

    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(width/2, height*0.4, 0, 0)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.hidesWhenStopped = YES;
    [self addSubview:indicator];
    _indicator = indicator;
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, height-50, width , 30)];
    label.text = @"加载中，请稍后";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}
@end
