//
//  TXBookshelfController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-17.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallBookListViewController.h"
#import "TXAppUtils.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"
#import "TXEnumeUtils.h"
#import "MJRefresh.h"

#define COUNT_ONE_PAGE 15

@interface TXMallBookListViewController () <MJRefreshBaseViewDelegate>

@end

@implementation TXMallBookListViewController
{
    NSMutableArray *bookList;
    NSInteger _pageNum;//当前数据加载的页数
    
    MJRefreshHeaderView *_header;
    MJRefreshFooterView *_footer;
    
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
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = [TXEnumeUtils getBookListTypeName:(TXBookListType)self.listType.integerValue];
    
    //这个地方不要请求线上数据而是从本地缓存拿数据
//    bookList = [TXSourceManager getMallListWithType:(TXBookListType)self.listType.integerValue pageSize:10 pageIndex:1];
    
    _pageNum = 0;
    //集成下啦刷新控件
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.delegate = self;
    [header beginRefreshing];
    _header = header;
    
    //上拉加载更多
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = self.tableView;
    footer.delegate = self;
    _footer = footer;
    
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
    self.navigationController.navigationBar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.navigationBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [TXAppUtils instance].titleFontTint,NSForegroundColorAttributeName, nil];
    
    self.tableView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    [self.tableView reloadData];
    _theme = [TXAppUtils instance].theme;
}
#pragma mark 刷新ui列表
- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    // 刷新表格
    [self.tableView reloadData];
    
    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
    [refreshView endRefreshing];
}

#pragma mark - override
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    self.hidesBottomBarWhenPushed = YES;
    TXMallBookListCell *cell = sender;
    TXBookData *data = cell.data;
    
    
    UIViewController *view = segue.destinationViewController;
    if ([view respondsToSelector:@selector(setValue:forKey:)])
    {
        [view setValue:data forKey:@"bookData"];
    }
    
}

#pragma mark - tableView SourceData
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return bookList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"MallBookListCell";
    TXBookData *data = [bookList objectAtIndex:indexPath.row];
    TXMallBookListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.backgroundColor = [TXAppUtils instance].tableViewCellBackGroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.data = data;
    
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


#pragma mark - 下拉刷新控件代理
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    _pageNum++;
    [TXSourceManager getMallListWithType:(TXBookListType)self.listType.integerValue pageSize:COUNT_ONE_PAGE pageIndex:_pageNum completionHandler:^(NSMutableArray *data,NSError *error) {
        if (data)
        {
            NSArray *list = data;
            if ([refreshView isKindOfClass:[MJRefreshHeaderView class]])
            {
                bookList = [NSMutableArray arrayWithArray:list];
            } else
            {
                [bookList addObjectsFromArray:list];
            }
            
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
    NSLog(@"%@----刷新完毕", refreshView.class);
}

#pragma mark 监听刷新状态的改变
//- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
//{
//    switch (state) {
//        case MJRefreshStateNormal:
//            NSLog(@"%@----切换到：普通状态", refreshView.class);
//            break;
//            
//        case MJRefreshStatePulling:
//            NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
//            break;
//            
//        case MJRefreshStateRefreshing:
//            NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
//            break;
//        default:
//            break;
//    }
//}



@end
