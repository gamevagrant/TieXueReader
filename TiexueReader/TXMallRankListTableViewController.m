//
//  TXMallRankListTableViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-14.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallRankListTableViewController.h"
#import "TXSourceManager.h"
#import "TXBookData.h"
#import "TXMallBookRankTableViewCell.h"
#import "TXDefine.h"
#import "MJRefresh.h"
#import "TXAppUtils.h"

#define GROUP_TITLE_CELL_TAG (TAG_CUSTOM_BASE + 1000)

@interface TXMallRankListTableViewController () <MJRefreshBaseViewDelegate>

@end

@implementation TXMallRankListTableViewController
{
    NSDictionary *dataDic;
    NSArray *rankKindList;
    
    MJRefreshHeaderView *_header;
    
    AppTheme _theme;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self updateTheme];
    
    //集成下啦刷新控件
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tableView;
    header.delegate = self;
    [header beginRefreshing];
    _header = header;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_theme != [TXAppUtils instance].theme) {
        [self updateTheme];
    }
    
}

- (void)updateTheme
{
    self.tableView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    [self.tableView reloadData];
    _theme = [TXAppUtils instance].theme;
}

- (void)pressMoreButtonHandle:(id)sender
{
    UIView *senderView = sender;
    NSInteger index = senderView.superview.tag - GROUP_TITLE_CELL_TAG;
    NSNumber *type = [rankKindList objectAtIndex:index];
    
    UIViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"MallBookListPageViewController"];
    if ([view respondsToSelector:@selector(setValue:forKey:)])
    {
        [view setValue:type forKey:@"listType"];
    }
    [self.navigationController pushViewController:view animated:YES];
    

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
    TXMallBookRankTableViewCell *cell = sender;
    TXBookData *data = cell.bookData;
    
    UIViewController *view = segue.destinationViewController;
    if ([view respondsToSelector:@selector(setValue:forKey:)])
    {
        [view setValue:data forKey:@"bookData"];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return rankKindList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    NSNumber *kind=[rankKindList objectAtIndex:section];
    NSArray *bookList = [dataDic objectForKey:kind];
    return bookList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MallRankListCell" forIndexPath:indexPath];
    cell.backgroundColor = [TXAppUtils instance].tableViewCellBackGroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSNumber *kind=[rankKindList objectAtIndex:indexPath.section];
    NSArray *bookList = [dataDic objectForKey:kind];
    TXBookData *data = [bookList objectAtIndex:indexPath.row];

    if ([cell respondsToSelector:@selector(setValue:forKey:)])
    {
        [cell setValue:data forKey:@"bookData"];
    }
    
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSInteger kind = [[rankKindList objectAtIndex:section] integerValue];
//    return [TXEnumeUtils getBookListTypeName:(TXBookListType)kind];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGSize size = self.tableView.frame.size;
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [TXAppUtils instance].titleCellBackGroundColor;
    view.tag = GROUP_TITLE_CELL_TAG + section;
    
    NSInteger kind = [[rankKindList objectAtIndex:section] integerValue];
    NSString *title = [TXEnumeUtils getBookListTypeName:(TXBookListType)kind];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 30)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [TXAppUtils instance].fontTint;
    [view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(size.width-50, 0, 50, 30);
    [button setTitle:@"更多" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.tintColor = [TXAppUtils instance].interactionTint;
    [button addTarget:self action:@selector(pressMoreButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 下拉刷新控件代理
#pragma mark 开始进入刷新状态
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    [TXSourceManager getMallRankListWithCompletionHandler:^(NSDictionary *data,NSError *error) {
        if (data)
        {
            dataDic = data;
            rankKindList = [dataDic.allKeys sortedArrayUsingSelector:@selector(compare:)];
            
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
- (void)refreshView:(MJRefreshBaseView *)refreshView stateChange:(MJRefreshState)state
{
    switch (state) {
        case MJRefreshStateNormal:
            NSLog(@"%@----切换到：普通状态", refreshView.class);
            break;
            
        case MJRefreshStatePulling:
            NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
            break;
            
        case MJRefreshStateRefreshing:
            NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
            break;
        default:
            break;
    }
}


@end
