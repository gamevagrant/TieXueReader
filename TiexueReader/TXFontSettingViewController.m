//
//  TXFontSettingViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-25.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXFontSettingViewController.h"
#import "TXDefine.h"
#import "TXAppUtils.h"

@interface TXFontSettingViewController ()
@property (strong, nonatomic) IBOutlet UIView *panelView;
@property (strong, nonatomic) IBOutlet UISwitch *nightModelSwitch;
@property (strong, nonatomic) IBOutlet UISlider *lightSlider;
@property (strong, nonatomic) IBOutlet UISegmentedControl *fontSizeSegmented;
@property (strong, nonatomic) IBOutlet UISegmentedControl *lineSpaceSegmented;
@end

@implementation TXFontSettingViewController

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
    self.panelView.layer.cornerRadius = 8;    //设置弹出框为圆角视图
    
    self.panelView.layer.masksToBounds = NO;//不设置成no阴影不出来
    self.panelView.layer.shadowOffset = CGSizeMake(2, 4);// 阴影的范围
    self.panelView.layer.shadowRadius = 2;// 阴影扩散的范围控制
    self.panelView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
    self.panelView.layer.shadowOpacity = 0.5;// 阴影透明度
    
    self.nightModelSwitch.on = self.nightModelIsOn;
    self.lightSlider.value = self.light;
    self.fontSizeSegmented.selectedSegmentIndex = self.fontSize;
    self.lineSpaceSegmented.selectedSegmentIndex = self.lineSpace;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTheme];
}


- (void)updateTheme
{
    self.panelView.backgroundColor = [TXAppUtils instance].toolBarBackGroundColor;
    
    NSArray *subviews = self.panelView.subviews;
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
- (IBAction)lightChange:(id)sender {
    
    UISlider *slider = (UISlider *)sender;
    NSNumber *value = [NSNumber numberWithFloat:slider.value];
    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: value,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_LIGHT object:nil userInfo:info];

}
- (IBAction)fontSizeChange:(id)sender {
    UISegmentedControl *sc = sender;
    NSNumber *size = [NSNumber numberWithInteger:sc.selectedSegmentIndex] ;
    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: size,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_FONTSIZE object:nil userInfo:info];
}
- (IBAction)lineSpaceChange:(id)sender {
    UISegmentedControl *sc = sender;
    NSNumber *size = [NSNumber numberWithFloat:sc.selectedSegmentIndex] ;
    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: size,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_LINE_SPACE object:nil userInfo:info];
}
- (IBAction)nightModleChange:(id)sender {
    UISwitch *sw = sender;
    NSNumber *value = [NSNumber numberWithBool:sw.isOn] ;
    NSDictionary *info = [[NSDictionary alloc]initWithObjectsAndKeys: value,@"value", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_NIGHT_MODEL object:nil userInfo:info];
    [self updateTheme];
}
@end
