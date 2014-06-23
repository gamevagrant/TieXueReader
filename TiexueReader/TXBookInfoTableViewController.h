//
//  TXBookInfoTableViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXBookData.h"
#import "TXBookRecommendTableViewCell.h"
@interface TXBookInfoTableViewController : UITableViewController <TXBookInfoScrollVIewDelegate,UITabBarDelegate,UITableViewDelegate>
@property (nonatomic,strong) TXBookData *bookData;
@end
