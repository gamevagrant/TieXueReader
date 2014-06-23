//
//  TXBookShelfCollectionViewController.h
//  TiexueReader
//
//  Created by 齐宇 on 14-3-24.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXBookShelfCollectionViewController : UICollectionViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) NSMutableArray *bookList;
@end
