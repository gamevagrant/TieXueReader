//
//  TXBookInfoTableViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-10.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXBookInfoTableViewController.h"
#import "TXSourceManager.h"
#import "TXDefine.h"
#import "TXAppUtils.h"

@interface TXBookInfoTableViewController ()

@end

@implementation TXBookInfoTableViewController
{
    NSDictionary *bookInfo;
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
    
    [self updateTheme];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    [[TXAppUtils instance].indicator startAnimating];
    [TXSourceManager getBookInfoWithBookID:self.bookData.bookID completionHandler:^(NSDictionary *data,NSError *error) {
        if (data)
        {
            bookInfo = data;
            TXBookData *book = [[TXBookData alloc]init];
            book.bookName = data[@"bookname"];
            book.bookID = [data[@"bookid"] integerValue];
            book.author = data[@"penname"];
            book.frontCoverUrl = data[@"coverurl"];
            
            book.lastUpdateTime = [data[@"lastUpdateTime"] unsignedLongLongValue];
            book.lastChapterID = [data[@"lastChapterId"] integerValue];
            book.lastChapterName = data[@"lastChapterName"];
            
            book.bookscore = [data[@"bookscore"] integerValue];
            book.viewcount = [data[@"viewcount"] integerValue];
            book.collectnum = [data[@"collectnum"] integerValue];
            book.commentnum = [data[@"commentnum"] integerValue];
            book.summaryl = data[@"summary"];
            
            book.bookStateName = data[@"bookstatename"];
            book.bookKindName = data[@"bookkindname"];
            self.bookData = book;
            [self.tableView reloadData];

        }else
        {
            [TXAppUtils showAlertWithTitle:@"请求失败" Message:error.localizedDescription];
            [[TXAppUtils instance].indicator stopAnimating];
        }
        
    }];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
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

- (void)nextPageWithBookID:(NSInteger)booID
{
    TXBookInfoTableViewController *page = [self.storyboard instantiateViewControllerWithIdentifier:@"BookInfoPage"];
    TXBookData *bookData = [[TXBookData alloc]init];
    bookData.bookID = booID;
    page.bookData = bookData;
    
    [self.navigationController pushViewController:page animated:YES];

}



//选中一本书 切换界面、开始阅读 前的时候调用 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    
    TXBookData *data = self.bookData;
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
    if (!bookInfo) {
        return 0;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger num = 1;
    if (section == 3) {
        num = [bookInfo[@"comment_list"] count];
    }
    return num;
}




//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *name;
//    switch (section) {
//        case 0:
//            name = @"";
//            break;
//        case 1:
//            name = @"简介";
//            break;
//        case 2:
//            name = @"推荐";
//            break;
//        case 3:
//            name = @"评论";
//            break;
//            
//        default:
//            break;
//    }
//    return name;
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat hight;
    switch (indexPath.section)
    {
        case 0:
            hight = 173;
            break;
        case 1:
            hight = 99;
            break;
        case 2:
            hight = 130;
            break;
        case 3:
            hight = 100;
            break;
            
        default:
            hight = 22;
            break;
    }
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    if (indexPath.section == 1)
    {
        NSString *summary = bookInfo[@"summary"];
        CGRect rect = [summary boundingRectWithSize:CGSizeMake(self.view.frame.size.width-40, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
        return rect.size.height+30;
    }else if (indexPath.section == 3)
    {
        NSString *comment = bookInfo[@"comment_list"][indexPath.row][@"content"];
        CGRect rect = [comment boundingRectWithSize:CGSizeMake(self.view.frame.size.width-40, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
        return rect.size.height + 40;
    }
    return hight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    switch (indexPath.section) {
        case 0:
            identifier = @"bookInfoBaseCell";
            break;
        case 1:
            identifier = @"bookInfoSunnaryCell";
            break;
        case 2:
            identifier = @"bookInfoRecommendCell";
            break;
        case 3:
            identifier = @"bookInfoCommentCell";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setValue:forKey:)])
    {
        if (indexPath.section == 2) {
            [cell setValue:bookInfo forKey:@"bookInfo"];
            [cell setValue:self forKey:@"delegate"];
        }
        if (indexPath.section == 3) {
            NSArray *commentList = bookInfo[@"comment_list"];
            [cell setValue:commentList[indexPath.row] forKey:@"comment"];
        }else
        {
            [cell setValue:bookInfo forKey:@"bookInfo"];
        }
        
    }
    // Configure the cell...
    cell.backgroundColor = [TXAppUtils instance].tableViewCellBackGroundColor;
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

#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
//    headerView.backgroundView.backgroundColor = [TXAppUtils instance].titleCellBackGroundColor;
//    NSArray *subviews = headerView.contentView.subviews;
//    for (UIView *subView in subviews)
//    {
//        if ([subView isKindOfClass:[UILabel class]])
//        {
//            UILabel *label = (UILabel *)subView;
//            label.textColor = [TXAppUtils instance].titleFontTint;
//        }
//    }
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
   [[TXAppUtils instance].indicator stopAnimating];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    view.backgroundColor = [TXAppUtils instance].titleCellBackGroundColor;

    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 20)];
    label.font = [UIFont systemFontOfSize:13];
    NSString *name;
    switch (section) {
        case 0:
            name = @"";
            break;
        case 1:
            name = @"简介";
            break;
        case 2:
            name = @"推荐";
            break;
        case 3:
            name = @"评论";
            break;
            
        default:
            break;
    }
    
    label.text = name;
    label.textColor = [TXAppUtils instance].titleFontTint;

    [view addSubview:label];
    return view;
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

@end
