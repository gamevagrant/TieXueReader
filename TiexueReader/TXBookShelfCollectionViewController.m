//
//  TXBookShelfCollectionViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-3-24.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookShelfCollectionViewController.h"
#import "TXAppUtils.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"
#import "TXBookShelfCollectionCell.h"
#import "TXDefine.h"
#import "MJRefresh.h"
#import "MobClick.h"

@interface TXBookShelfCollectionViewController ()<MJRefreshBaseViewDelegate>

@end

@implementation TXBookShelfCollectionViewController
{
    NSIndexPath *actionIndex;//正在操作的书籍在列表中的索引
    UIView *_statuseBar;//状态栏的底图
    UILabel *_tipsLabel;//提示文字
    UIAlertView *_updateAlert;//提示更新的alert
    MJRefreshHeaderView *_header;
    
    AppTheme _theme;
}

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
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;//阻止滑动返回
    
    
    [self updateTheme];

    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    //遍历collectionView中的所有手势 创建手势之间的依赖关系 避免和控件自带手势冲突
    NSArray *recognizers = [self.collectionView gestureRecognizers];
    for (UIGestureRecognizer *arecognizer in recognizers) {
        if ([arecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            //当longPressGR手势识别失败的时候才响应arecognizer手势
            [arecognizer requireGestureRecognizerToFail:longPressGR];
        }
    }
    
    [self.view addGestureRecognizer:longPressGR];
    
    _statuseBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEGHT)];
    [self.view addSubview:_statuseBar];
    

    self.collectionView.alwaysBounceVertical = YES;
    // 3.集成刷新控件
    // 3.1.下拉刷新
    _header = [MJRefreshHeaderView header];
    _header.scrollView = self.collectionView;
    _header.delegate = self;
    
    //自动刷新
    [_header beginRefreshing];
    
    //判断是否需要更新
    [TXAppUtils getAppInfoCompletionHandler:^(NSDictionary *data, NSError *error) {
        if (data) {
            NSString *latestVersion = data[@"version"];
            if (latestVersion && ![latestVersion isEqual:VERSION])
            {
                if (!_updateAlert) {
                    _updateAlert = [[UIAlertView alloc]initWithTitle:@"有新版本" message:@"是否前往应用商店下载最新版本" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
                }
               
                [_updateAlert show];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateTips
{
    if (!self.bookList || self.bookList.count==0)
    {
        if (!_tipsLabel)
        {
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, screenHeight*0.3, screenWidth, 80)];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"您的书架里还没有书籍\n请到商城选购吧";
            label.numberOfLines = 0;
            [self.view addSubview:label];
            _tipsLabel = label;
            
        }
        _tipsLabel.hidden = NO;
    }else
    {
        if (_tipsLabel) {
            _tipsLabel.hidden = YES;
        }
        
    }
    
}
- (void)showSheet:(NSString *)title
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:title
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"删除"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)showAlert:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:nil
                          delegate:self
                          cancelButtonTitle:@"取消"
                          otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)updateTheme
{
    self.navigationController.navigationBar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.navigationBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [TXAppUtils instance].titleFontTint,NSForegroundColorAttributeName, nil];
    
    self.navigationController.toolbar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.toolbar.barTintColor = [TXAppUtils instance].toolBarBackGroundColor;
    
    self.collectionView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    _statuseBar.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    [self.collectionView reloadData];
    
    _theme = [TXAppUtils instance].theme;
}
#pragma mark - override
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
    [self.navigationController setToolbarHidden:YES animated:NO];
    self.bookList = [NSMutableArray arrayWithArray:[TXUserConfig instance].bookDataList.allValues];
    if (_theme!= [TXAppUtils instance].theme) {
        [self updateTheme];
    }
    
    //友盟监控
    [MobClick beginLogPageView:@"书架"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //友盟监控
    [MobClick endLogPageView:@"书架"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([TXAppUtils instance].needUpdateBookShelf) {
        [_header beginRefreshing];
        [TXAppUtils instance].needUpdateBookShelf = NO;
    }
}


#pragma mark - ui事件

//长按一本书触发事件
- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //通过点击的点来确认点到哪个数据
        CGPoint point = [gesture locationInView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath) {
            TXBookData *book = [self.bookList objectAtIndex:indexPath.row];
            actionIndex = indexPath;
            [self showSheet:book.bookName];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bookList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"bookListCell";
    TXBookData *data = [self.bookList objectAtIndex:indexPath.row];
    TXBookShelfCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setDataWithBookData:data];
    
    NSArray *subviews = cell.contentView.subviews;
    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            subView.tintColor = [TXAppUtils instance].interactionTint;
        }
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            if (label.tag == 20000) {
                label.textColor = [TXAppUtils instance].titleFontTint;
            }else
            {
                label.textColor = [TXAppUtils instance].fontTint;
            }
            
            
        }
    }
    
    return cell;
}
#pragma mark - UICollectionViewDelegate

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    TXBookShelfCollectionCell *cell = (TXBookShelfCollectionCell *)sender;
    if (![TXAppUtils hasNetworking] && !cell.data.chapterList) {
        
        [TXAppUtils showAlertWithTitle:@"图书下载失败" Message:@"没有网络连接，无法下载图书"];
        return NO;
    }
    return YES;
    
}
//选中一本书 切换界面前的时候调用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    TXBookShelfCollectionCell *cell = sender;
    TXBookData *data = cell.data;
    
    
    UIViewController *view = segue.destinationViewController;
    if ([view respondsToSelector:@selector(setValue:forKey:)])
    {
        [view setValue:data forKey:@"bookData"];
    }
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self showAlert:[NSString stringWithFormat:@"你确定要将%@从书架移除吗？",actionSheet.title]];
    }
}


#pragma mark - UIAlertViewDelegate
//点击alert确定后调用 删除指定书籍
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_updateAlert == alertView) {
        if (buttonIndex == 1)
        {
            [TXAppUtils gotoAppStore];
        }
    }else
    {
        if (buttonIndex == 1)
        {
            TXBookData *book = [self.bookList objectAtIndex:actionIndex.row];
            //请求删除自己的书架上的这本书
            [TXSourceManager removeBookFromShelfWithBookData:book completionHandler:^(BOOL isSuccess,NSError *error) {
                if (isSuccess)
                {
                    //删除UI上保存的数据
                    [self.bookList removeObjectAtIndex:actionIndex.row];
                    
                    [self.collectionView performBatchUpdates:^{
                        NSArray *deleteArray = [NSArray arrayWithObjects:actionIndex, nil];
                        [self.collectionView deleteItemsAtIndexPaths:deleteArray];
                    }completion:nil];
                }else
                {
                    [TXAppUtils showAlertWithTitle:@"请求失败" Message:error.localizedDescription];
                }
                
            }];
    }
    
        
        
    }
}
#pragma mark 刷新UI
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    self.bookList = [[NSMutableArray alloc]initWithArray:[TXUserConfig instance].bookDataList.allValues];
    // 刷新表格
    [self.collectionView reloadData];
    [self updateTips];
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}
#pragma mark - 刷新空间代理方法
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    
    if (userConfig.userData)
    {
        [TXSourceManager syncShelfOperate:userConfig.operateList completionHandler:^(BOOL isSuccess, NSError *error) {
            if (isSuccess)
            {
                [TXSourceManager getBookShelfListWithCompletionHandler:^(NSMutableDictionary *data,NSError *error) {
                    if (error)
                    {
                        [TXAppUtils showAlertWithTitle:@"同步失败" Message:error.localizedDescription];
                    }
                    
                    [self doneWithView:refreshView];
                }];

            }else
            {
                [TXAppUtils showAlertWithTitle:@"同步失败" Message:error.localizedDescription];
                [self doneWithView:refreshView];
            }
        }];
    }else
    {
        [TXSourceManager getTempBookshelfListWithBookIDList:userConfig.bookDataList.allKeys completionHandler:^(NSMutableDictionary *data, NSError *error)
         {
             if (error)
             {
                 [TXAppUtils showAlertWithTitle:@"更新失败" Message:error.localizedDescription];
             }
             
             [self doneWithView:refreshView];
         }];
    }
    
    
    

}

#pragma mark 刷新完毕
- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    
}

#pragma mark 监听刷新状态的改变
- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
{
    switch (state) {
        case MJRefreshStateNormal:
            
            break;
            
        case MJRefreshStatePulling:
            
            break;
            
        case MJRefreshStateRefreshing:
            
            break;
        default:
            break;
    }
}
@end
