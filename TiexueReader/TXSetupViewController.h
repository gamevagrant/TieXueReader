//
//  TXSetupViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-2-17.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class TXUserData;
@interface TXSetupViewController : UITableViewController<UITableViewDelegate , UIActionSheetDelegate,SKStoreProductViewControllerDelegate>



@property (strong, nonatomic) IBOutlet UITableViewCell *accountCell;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *goldLabel;
@property (strong, nonatomic) IBOutlet UISwitch *nightSwitch;




@end
