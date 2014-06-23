//
//  TXMallSearchViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-5-5.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXMallSearchViewController.h"
#import "TXSourceManager.h"
#import "TXUserConfig.h"
#import "TXBookData.h"
#import "TXAppUtils.h"

#define HOT_SEARCH_FONT_SIZE 14
#define TABLE_TYPE_HISTORY 1
#define TABLE_TYPE_SEARCH 2

@interface TXMallSearchViewController ()


@property (nonatomic,strong) NSArray *tableData;

@end

@implementation TXMallSearchViewController
{
    NSMutableArray *_historyData;
    NSArray *_searchData;
    NSArray *_hotData;
    
    UIFont *_hotSearchLabelFont;
    NSInteger _tableType;//tableView 显示的内容类型 1：显示历史数据 2：显示查询数据
    
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
    [self setupSubview];
    [self updateTheme];
    
    _historyData = [TXUserConfig instance].historySearchData;
    [TXSourceManager getHotSearchDataWithCompletionHandler:^(NSArray *data, NSError *error) {
        _hotData = data;
        [self.collectionView reloadData];
    }];
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
    self.collectionView.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    self.searchBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.searchBar.tintColor = [TXAppUtils instance].interactionTint;
    [self.tableView reloadData];
    _theme = [TXAppUtils instance].theme;
}

- (void)setupSubview
{
    CGRect rect = self.searchBar.frame;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y + rect.size.height;
    CGFloat width = rect.size.width;
    CGFloat height = [ UIScreen mainScreen ].applicationFrame.size.height - y;
    
    UITableView *tableView = self.tableView;
    [tableView setFrame:CGRectMake(x, y, width, height)];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.hidden = YES;
    

    
    UICollectionView *collectionView = self.collectionView;
    collectionView.frame = CGRectMake(x, y, width, height);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    
    self.searchBar.delegate = self;
    
}


- (void)setTableData:(NSArray *)tableData
{
    if (tableData == _historyData)
    {
        _tableType = TABLE_TYPE_HISTORY;
    }else if(tableData == _searchData)
    {
        _tableType = TABLE_TYPE_SEARCH;
    }else
    {
        _tableType = 0;
    }
    _tableData = tableData;
    
    [self.tableView reloadData];
}

- (UIColor *)randomColor
{
	static BOOL seeded = NO;
	if (!seeded) {
		seeded = YES;
        (time(NULL));
	}
	CGFloat red = (CGFloat)random() / (CGFloat)RAND_MAX;
	CGFloat green = (CGFloat)random() / (CGFloat)RAND_MAX;
	CGFloat blue = (CGFloat)random() / (CGFloat)RAND_MAX;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

//计算文本大小
- (CGSize)sizeWithString:(NSString *)str font:(UIFont *)font
{
    
    NSDictionary *attribute = @{NSFontAttributeName:font};
    NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str attributes:attribute];
    
    //计算当前文本所占显示空间的大小
    CGSize labelSize = [aStr boundingRectWithSize:CGSizeMake(0, 30) options: NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    return labelSize;
}

//搜索
- (void)searchWithString:(NSString *)str
{
    [TXSourceManager searchBookWithContent:str pageSize:10 pageIndex:1 completionHandler:^(NSArray *list, NSError *error) {
        _searchData = list;
        self.tableData = _searchData;
        
        [self addHistoryList:str];
        [self.searchBar resignFirstResponder];
    }];
    
    
}




//清理历史搜索记录
- (void)clearHistorySearchData
{
    [_historyData removeAllObjects];
    [self.tableView reloadData];
}

- (void)addHistoryList:(NSString *)str
{
    BOOL isInHistory = NO;
    for (NSString *historyData in _historyData)
    {
        if ([historyData isEqual:str])
        {
            isInHistory = YES;
            break;
        }
    }
    if (!isInHistory)
    {
        [_historyData addObject:str];
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

#pragma mark - overRide UIView
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    TXBookData *data = _searchData[indexPath.row];
    
    UIViewController *view = segue.destinationViewController;
    if ([view respondsToSelector:@selector(setValue:forKey:)])
    {
        [view setValue:data forKey:@"bookData"];
    }
    
}
#pragma mark - UISearchBarDelegate
//搜索框进入输入状态
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.view bringSubviewToFront:self.tableView];
    self.tableView.hidden = NO;
    self.tableData = _historyData;
}
//搜索框退出输入状态
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    
//    self.searchBar.text = nil;
//}
//点击搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchWithString:self.searchBar.text];
}
//点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.tableView.hidden = YES;
    self.searchBar.text = nil;
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = _tableData.count;
    if (_tableType == TABLE_TYPE_HISTORY)
    {
        num ++;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [[UITableViewCell alloc]init];
    UITableViewCell *cell;
    
    if (_tableType == TABLE_TYPE_HISTORY)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchHistoryCell" forIndexPath:indexPath];
        if (indexPath.row == _tableData.count)
        {
            cell.textLabel.text = @"清除历史数据";
        }else
        {
            cell.textLabel.text = _tableData[indexPath.row];
        }
        cell.textLabel.textColor = [TXAppUtils instance].titleFontTint;
    }else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
        TXBookData *data = _tableData[indexPath.row];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:10001];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:data.frontCoverUrl];
            UIImage *image = [TXAppUtils getImageFromCacheWithURL:url];
            
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //这里写视图更新相关得方法 视图只能在主线程更新
                    imageView.image = image;

                });
            }
            
        });
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:10002];
        nameLabel.text = data.bookName;
        nameLabel.textColor = [TXAppUtils instance].titleFontTint;
        UILabel *authorLabel = (UILabel *)[cell viewWithTag:10003];
        authorLabel.text = data.author;
        authorLabel.textColor = [TXAppUtils instance].fontTint;
        UILabel *summaryLabel = (UILabel *)[cell viewWithTag:10004];
        summaryLabel.text = data.summaryl;
        summaryLabel.textColor = [TXAppUtils instance].fontTint;
        UILabel *statuseLabel = (UILabel *)[cell viewWithTag:10005];
        statuseLabel.text = data.bookStateName;
        statuseLabel.textColor = [TXAppUtils instance].fontTint;
    }
    cell.backgroundColor = [TXAppUtils instance].tableViewCellBackGroundColor;
    return cell;
}

#pragma mark - uiTableViewDelegate
//选中一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableType == TABLE_TYPE_HISTORY )
    {
        //历史数据
        if (indexPath.row == _tableData.count)
        {
            //清除历史数据
            [self clearHistorySearchData];
        }else
        {
            NSString *str = _historyData[indexPath.row];
            self.searchBar.text = str;
            [self searchWithString:str];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableType == TABLE_TYPE_HISTORY) {
        return 44;
    }else{
        return 120;
    }
}

//开始滑动的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _hotData.count;
}

//返回cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HotSearchCell" forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.cornerRadius = 4;
    
    UILabel *label = (UILabel *)[cell viewWithTag:10001];
    label.text = _hotData[indexPath.row];
    label.textColor = [self randomColor];
    label.font = [UIFont systemFontOfSize:HOT_SEARCH_FONT_SIZE];
    
    return cell;
}
#pragma mark - UICollectionViewDelegateFlowLayout
//设置每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGSize estimateSize = [self sizeWithString:_hotData[indexPath.row] font:[UIFont systemFontOfSize:HOT_SEARCH_FONT_SIZE]];
    return CGSizeMake(estimateSize.width+10, 30);
}
//最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}
//前后cell最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0f;
}
//上下左右的边距
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets insets = UIEdgeInsetsMake(20, 10, 20, 10);
    return insets;
}
//选中一个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = _hotData[indexPath.row];
    self.tableView.hidden = NO;
    self.searchBar.text = str;
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar becomeFirstResponder];
    [self searchWithString:str];
}


@end
