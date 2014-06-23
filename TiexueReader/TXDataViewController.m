//
//  TXDataViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXDataViewController.h"
#import "TXAppUtils.h"
#import "TXDefine.h"
@interface TXDataViewController ()

@end

@implementation TXDataViewController
{


}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.contentLabel.numberOfLines = 0;
    [self updateTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:CHANGE_THEME object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_THEME object:nil];

}

- (void)changeTheme:(NSNotification *)notification
{
    [self updateTheme];
}

- (void)updateTheme
{
    self.view.backgroundColor = [TXAppUtils instance].pageBackGroundColor;
    NSArray *subviews = self.view.subviews;
    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            subView.tintColor = [TXAppUtils instance].interactionTint;
        }
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            
            label.textColor = [TXAppUtils instance].titleFontTint;
        }
    }

}
- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    NSInteger i = progress*100;
    if (self.progress == 1)
    {
        self.pageNumLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)self.currentPage,(unsigned long)self.totalPage];
    }else
    {
        self.pageNumLabel.text = [NSString stringWithFormat:@"处理进度%ld%%",(long)i];
    }
}

- (void)setData:(NSAttributedString *)data
{
    _data = data;
    if (self.contentLabel)
    {
        [self.contentLabel removeFromSuperview];
    }
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 200)];
    label.textColor = [TXAppUtils instance].titleFontTint;
    label.numberOfLines = 0;
    label.attributedText = self.data;
    [label sizeToFit];
    [self.view addSubview:label];
    self.contentLabel = label;
    
    self.pageNumLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)self.currentPage,(unsigned long)self.totalPage];
    self.bookInfoLabel.text = self.bookInfo;
}


@end
