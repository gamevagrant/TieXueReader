//
//  TXReadHistoryTableViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-6-3.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXReadHistoryTableViewController.h"
#import "TXUserConfig.h"
#import "TXAppUtils.h"
#import "TXBookData.h"

@interface TXReadHistoryTableViewController ()

@end

@implementation TXReadHistoryTableViewController
{
    NSMutableArray *history;
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
    
    history = [TXUserConfig instance].historyReadData;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return history.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXBookData *data = [history objectAtIndex:history.count - indexPath.row - 1];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    UIImageView *image = (UIImageView *)[cell viewWithTag:10001];
    [TXAppUtils loadImageByThreadWithView:image url:data.frontCoverUrl];
    
    
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
    
    // Configure the cell...
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    TXBookData *data = [history objectAtIndex:indexPath.row];
    UIViewController *view = segue.destinationViewController;
    if ([view respondsToSelector:@selector(setValue:forKey:)])
    {
        [view setValue:data forKey:@"bookData"];
    }
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
