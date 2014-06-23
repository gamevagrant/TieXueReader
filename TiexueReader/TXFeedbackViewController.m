//
//  TXFeedbackViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-5-28.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXFeedbackViewController.h"
#import "TXAppUtils.h"
#import "TXSourceManager.h"
@interface TXFeedbackViewController ()

@property (strong, nonatomic) IBOutlet UITextView *feedbackTextView;
@property (strong, nonatomic) IBOutlet UILabel *stringCountLabel;


@end

@implementation TXFeedbackViewController

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
    self.feedbackTextView.delegate = self;
    [self updateTheme];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger count = 500 - range.location + text.length;
    if (count<0) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger count = 500 - textView.text.length;
    self.stringCountLabel.text = [NSString stringWithFormat:@"剩余%li个字",(long)count];
}

- (IBAction)backgroundTapAction:(id)sender
{
    [self.feedbackTextView resignFirstResponder];
}
- (IBAction)submit:(id)sender
{
    NSString *content = self.feedbackTextView.text;
    if (content.length==0)
    {
        [TXAppUtils showAlertWithTitle:@"提交失败" Message:@"提交的内容不能为空"];
    }else
    {
        [TXSourceManager feedbackWithContent:content completionHandler:^(BOOL isSuccess, NSError *error) {
            if (isSuccess) {
                [TXAppUtils showAlertWithTitle:nil Message:@"提交成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                [TXAppUtils showAlertWithTitle:@"提交失败" Message:@"请稍后重试"];
            }
        }];
    }
}
@end
