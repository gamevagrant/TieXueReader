//
//  TXReaderRootViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-2-21.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"
#import "TXBookData.h"
#import "TXDataViewController.h"
#import "TXPageModelController.h"

@interface TXReaderRootViewController : UIViewController<IIViewDeckControllerDelegate,UIGestureRecognizerDelegate,UIPageViewControllerDelegate,UITableViewDataSource,UITableViewDelegate , TXpageModelDelegate,UIAlertViewDelegate>

@property (strong, nonatomic)IIViewDeckController *deckController;
@property (strong, nonatomic)UIPageViewController *pageViewController;
@property (strong,nonatomic)TXBookData *bookData;
@property (nonatomic) BOOL fontSettingHidden;//是否隐藏字体设置界面
@property (nonatomic) BOOL pagesSettingHidden;//是否隐藏进度设置界面
@end
