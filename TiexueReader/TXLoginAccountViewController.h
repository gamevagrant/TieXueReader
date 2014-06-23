//
//  TXLoginAccountViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-29.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXLoginAccountViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWordTextField;

- (IBAction)didEnterAccount:(id)sender;
- (IBAction)didEnterPassWord:(id)sender;
- (IBAction)backGroundTap:(id)sender;
- (IBAction)loginBtnPress:(id)sender;


@end
