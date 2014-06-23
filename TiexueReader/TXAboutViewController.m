//
//  TXAboutViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-5-28.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXAboutViewController.h"
#import "TXDefine.h"
#import "TXAppUtils.h"

@interface TXAboutViewController ()
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation TXAboutViewController

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
    self.versionLabel.text = [NSString stringWithFormat:@"版本：%@",VERSION];
    [self updateTheme];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTheme
{
    self.view.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
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
            label.textColor = [TXAppUtils instance].fontTint;
        }
    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
