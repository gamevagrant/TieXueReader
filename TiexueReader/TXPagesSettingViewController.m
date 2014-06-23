//
//  TXPagesSettingViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-5-28.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXPagesSettingViewController.h"
#import "TXDefine.h"
#import "TXAppUtils.h"

@interface TXPagesSettingViewController ()
@property (strong, nonatomic) IBOutlet UIView *panel;
@property (strong, nonatomic) IBOutlet UILabel *pageLabel;
@property (strong, nonatomic) IBOutlet UISlider *pageSlider;

@end
@implementation TXPagesSettingViewController
{
    NSInteger _currentPage;
    NSInteger _totlePage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.panel.layer.cornerRadius = 8;    //设置弹出框为圆角视图
    
    self.panel.layer.masksToBounds = NO;//不设置成no阴影不出来
    self.panel.layer.shadowOffset = CGSizeMake(2, 4);// 阴影的范围
    self.panel.layer.shadowRadius = 2;// 阴影扩散的范围控制
    self.panel.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
    self.panel.layer.shadowOpacity = 0.5;// 阴影透明度

    _pageSlider.minimumValue = 1;
    [self updateDisplay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateTheme];
}

- (void)setCurrentPage:(NSInteger)currentPage totlePage:(NSInteger)totlePage
{
    _currentPage = currentPage;
    _totlePage = totlePage;
    [self updateDisplay];
}

- (void)updateDisplay
{
    _pageLabel.text = [NSString stringWithFormat:@"%li/%li",(long)_currentPage,(long)_totlePage];
    _pageSlider.maximumValue = _totlePage;
    _pageSlider.value = _currentPage;
}

- (void)updateTheme
{
    self.panel.backgroundColor = [TXAppUtils instance].toolBarBackGroundColor;
    
    NSArray *subviews = self.panel.subviews;
    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            label.textColor = [TXAppUtils instance].fontTint;
        }else
        {
            subView.tintColor = [TXAppUtils instance].interactionTint;
        }
    }
    
}

- (IBAction)sliderChangeValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    _currentPage = slider.value;
    [self updateDisplay];
    
    NSNumber *value = [NSNumber numberWithFloat:_currentPage];
    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: value,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_CURRENT_PAGE object:nil userInfo:info];
}
@end
