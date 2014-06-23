//
//  SVTabBarScrollView.m
//  SlideView
//
//  Created by 齐宇 on 14-4-2.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import "TXTabBarButtonsView.h"

@implementation TXTabBarButtonsView
{
    
    UIImageView *shadowImageView;   //选中阴影
    UIButton *selectedButton;//当前选中的按钮
    NSMutableArray *buttonsArray;//按钮集合
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.pagingEnabled = YES;
        self.userInteractionEnabled = YES;
        self.bounces = YES;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!buttonsArray)
    {
        [self createButtons];
    }
    
}

//生成按钮
- (void)createButtons
{
    float xPos = 0;
    NSInteger buttonCount = [self.nameArray count];
    NSInteger totalWidth = self.frame.size.width;
    NSInteger buttonWidth = floor(totalWidth/buttonCount) - BUTTONGAP;
    NSInteger buttonHeight = self.frame.size.height - STATUS_BAR_HEGHT;
    buttonsArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < buttonCount; i++)
    {
        NSString *title = [self.nameArray objectAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonsArray addObject:button];
        if (i == 0)
        {
            button.selected = YES;
            selectedButton = button;
        }
        button.frame = CGRectMake(xPos, STATUS_BAR_HEGHT, buttonWidth+BUTTONGAP, buttonHeight);
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:self.titleColorNormal?self.titleColorNormal:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:self.titleColorSelected?self.titleColorSelected:[UIColor redColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        xPos+=button.frame.size.width;
        [self addSubview:button];
    }

    self.contentSize = CGSizeMake(totalWidth, buttonHeight);
    
    shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(BUTTONGAP, STATUS_BAR_HEGHT, buttonWidth, buttonHeight)];
    [shadowImageView setImage:[UIImage imageNamed:@"red_line_and_shadow.png"]];
    [self addSubview:shadowImageView];

}

//设置选中的按钮
- (void)setSelectedButton:(NSInteger)index
{
    if (index<0 || index>=buttonsArray.count)
    {
        return;
    }
    UIButton *needSelectedBtn = [buttonsArray objectAtIndex:index];
    //如果更换按钮
    if (selectedButton == needSelectedBtn)
    {
        return;
    }
    
    //取之前的按钮
    UIButton *lastButton = selectedButton;
    lastButton.selected = NO;
    
    //按钮选中状态
    if (!needSelectedBtn.selected)
    {
        needSelectedBtn.selected = YES;
        selectedButton = needSelectedBtn;
        [UIView animateWithDuration:0.25 animations:^{
            
            [shadowImageView setFrame:CGRectMake(needSelectedBtn.frame.origin.x, needSelectedBtn.frame.origin.y, needSelectedBtn.frame.size.width, shadowImageView.frame.size.height)];
            [self.customDelegate changeSelectedWithIndex:index];
        } completion:^(BOOL finished) {
            if (finished)
            {
                
            }
        }];
        
    }
}
#pragma mark - ui事件
-(void)selectButton:(UIButton *)sender
{
    NSInteger index = [buttonsArray indexOfObject:sender];
    [self setSelectedButton:index];
    
}


- (void)setTitleColorNormal:(UIColor *)titleColorNormal
{
    _titleColorNormal = titleColorNormal;
    for (UIButton *btn in buttonsArray)
    {
        [btn setTitleColor:titleColorNormal forState:UIControlStateNormal];
        
    }
}

- (void)setTitleColorSelected:(UIColor *)titleColorSelected
{
    _titleColorSelected = titleColorSelected;
    for (UIButton *btn in buttonsArray)
    {
        [btn setTitleColor:titleColorSelected forState:UIControlStateSelected];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
