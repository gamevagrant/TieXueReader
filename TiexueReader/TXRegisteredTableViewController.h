//
//  TXRegisteredTableViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-30.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXRegisteredTableViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWordTextField;
@property (strong, nonatomic) IBOutlet UITextField *passWordAgainTextField;


- (IBAction)enterAccountEnd:(id)sender;
- (IBAction)enterPassWordEnd:(id)sender;
- (IBAction)enterPassWordAgainEnd:(id)sender;
- (IBAction)backGroundTap:(id)sender;
- (IBAction)pressRegisteredBtn:(id)sender;


@end
