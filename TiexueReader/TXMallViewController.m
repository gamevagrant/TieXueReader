//
//  TXMallViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-4.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallViewController.h"
#import "TXMallBookCell.h"
#import "TXBookData.h"
#import "TXSourceManager.h"
#import "TXDefine.h"
#import "TXEnumeUtils.h"
#import "MJRefresh.h"
#import "TXAppUtils.h"

#define GROUP_TITLE_CELL_TAG (TAG_CUSTOM_BASE + 1000)

@interface TXMallViewController () <MJRefreshBaseViewDelegate>

@end

@implementation TXMallViewController
{
    NSMutableDictionary *dataDic;
    NSArray *mallKindList;
    
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
    
    [self updateTheme];
    
    
    self.collectionView.alwaysBounceVertical = YES;
    // 3.集成刷新控件
    // 3.1.下拉刷新
    _header = [MJRefreshHeaderView header];
    _header.scrollView = self.collectionView;
    _header.delegate = self;
    
    //自动刷新
    [_header beginRefreshing];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_theme!=[TXAppUtils instance].theme) {
        [self updateTheme];
    }
    
}


- (void)updateTheme
{
    self.collectionView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    [self.collectionView reloadData];
    _theme = [TXAppUtils instance].theme;
}

#pragma mark 刷新UI
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [self.collectionView reloadData];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (!dataDic) {
        return 0;
    }
    return dataDic.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSNumber *kind=[mallKindList objectAtIndex:section];
    NSArray *bookList = [dataDic objectForKey:kind];
    return bookList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TXMallBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MallListCell" forIndexPath:indexPath];
    
    NSNumber *kind=[mallKindList objectAtIndex:indexPath.section];
    NSArray *bookList = [dataDic objectForKey:kind];
    TXBookData *data = [bookList objectAtIndex:indexPath.row];
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
            if (label.tag == 20000)
            {
                label.textColor = [TXAppUtils instance].titleFontTint;
            }else
            {
                label.textColor = [TXAppUtils instance].fontTint;
            }
            
            
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MallListHeader" forIndexPath:indexPath];
    cell.backgroundColor = [TXAppUtils instance].titleCellBackGroundColor;

    
    TXBookListType type = (TXBookListType)[[mallKindList objectAtIndex:indexPath.section]integerValue];
    UILabel *label = (UILabel *)[cell viewWithTag:10001];
    UIButton *button = (UIButton *)[cell viewWithTag:10002];
    switch (type) {
        case TX_ENUME_MALL_BOOKLIST_TYPE_RE_TUI:
            cell.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
            label.text = @"";
            button.hidden = YES;
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RE_XIAO:
            label.text = [TXEnumeUtils getBookListTypeName:type];
            label.textColor = [TXAppUtils instance].titleFontTint;
            button.hidden = YES;
            break;
            
        default:
            label.text = [TXEnumeUtils getBookListTypeName:type];
            label.textColor = [TXAppUtils instance].titleFontTint;
            button.tintColor = [TXAppUtils instance].interactionTint;
            button.hidden = NO;
            break;
    }


    NSInteger tag = GROUP_TITLE_CELL_TAG + indexPath.section;
    cell.tag = tag;
    return cell;
}



#pragma mark - UICollectionViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIView *senderView = sender;
        NSInteger index = senderView.superview.tag - GROUP_TITLE_CELL_TAG;
        NSNumber *type = [mallKindList objectAtIndex:index];
        
        UIViewController *view = segue.destinationViewController;
        if ([view respondsToSelector:@selector(setValue:forKey:)])
        {
            [view setValue:type forKey:@"listType"];
        }

    }else
    {
        TXMallBookCell *cell = sender;
        TXBookData *data = cell.data;
        
        UIViewController *view = segue.destinationViewController;
        if ([view respondsToSelector:@selector(setValue:forKey:)])
        {
            [view setValue:data forKey:@"bookData"];
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


#pragma mark - 刷新空间代理方法
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [TXSourceManager getMallListWithCompletionHandler:^(NSMutableDictionary *data,NSError *error) {
        if (data)
        {
            dataDic = data;
            mallKindList = [dataDic.allKeys sortedArrayUsingSelector:@selector(compare:)];
            
        }else
        {
            [TXAppUtils showAlertWithTitle:@"请求失败" Message:error.localizedDescription];
        }
        [self doneWithView:refreshView];
    }];
    
    
    // 2.2秒后刷新表格UI
    // 模拟延迟加载数据，因此2秒后才调用 使用真实数据加载的时候去掉延时调用
//    [self performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:1.0];
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
