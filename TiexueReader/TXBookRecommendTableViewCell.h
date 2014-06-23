//
//  TXBookRecommendTableViewCell.h
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TXBookInfoScrollVIewDelegate;

@interface TXBookRecommendTableViewCell : UITableViewCell

@property (strong, nonatomic) id<TXBookInfoScrollVIewDelegate> delegate;

@property (strong, nonatomic) NSDictionary *bookInfo;

@property (strong, nonatomic) IBOutlet UIScrollView *bookScrollView;

@end

@protocol TXBookInfoScrollVIewDelegate <NSObject>

- (void)nextPageWithBookID:(NSInteger)booID;
@end