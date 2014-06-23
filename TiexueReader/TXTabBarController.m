//
//  SVScrollViewController.m
//  SlideView
//
//  Created by 齐宇 on 14-4-2.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import "TXTabBarController.h"
#import "TXTabBarButtonsView.h"
#import "TXTabBarPageView.h"

@interface TXTabBarController ()

@end

@implementation TXTabBarController
{
    NSInteger pageCount;//总页数
    NSInteger currentPage;//当前页
    NSMutableDictionary *pageLoadeViewDic; //加载进来的子页面view集合
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
    CGRect screenBound = [UIScreen mainScreen].bounds;
    CGRect tabBarFreame = CGRectMake(0, 0, screenBound.size.width, TABBAR_HEIGHT + STATUS_BAR_HEGHT);
    CGRect contentViewFreame = CGRectMake(0, STATUS_BAR_HEGHT + TABBAR_HEIGHT, screenBound.size.width, screenBound.size.height - STATUS_BAR_HEGHT - TABBAR_HEIGHT);
    self.tabBarTopView = [[TXTabBarButtonsView alloc]initWithFrame:tabBarFreame];
    self.tabBarTopView.nameArray = [NSArray arrayWithObjects:@"推荐",@"排行",@"分类",@"免费", nil];
    self.tabBarPageView = [[TXTabBarPageView alloc]initWithFrame:contentViewFreame];
    self.tabBarPageView.delegate = self;
    self.tabBarTopView.customDelegate = self;
    self.dataSource = self;
    
    
    [self layoutSubviews];
    [self.view addSubview:self.tabBarPageView];
    [self.view addSubview:self.tabBarTopView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)layoutSubviews
{
    if(!pageLoadeViewDic)
    {
        CGRect frame = self.tabBarPageView.frame;
        pageCount = [self.dataSource tabBarContentView:self.tabBarPageView];
        self.tabBarPageView.contentSize = CGSizeMake(frame.size.width * pageCount, frame.size.height);
        pageLoadeViewDic = [[NSMutableDictionary alloc]init];
        
        for (int i = 0; i<2; i++)
        {
            [self loadPageView:i];
        }
    }
}

//加载指定页的view
- (void)loadPageView:(NSInteger)page
{
    UIViewController *viewController = [self.dataSource tabBarContentView:self.tabBarPageView pageAtIndex:page];
    UIView *view = viewController.view;
    view.frame = CGRectMake(page * self.view.frame.size.width, 0, view.frame.size.width, view.frame.size.height - TABBAR_HEIGHT);
    [self addChildViewController:viewController];
    [self.tabBarPageView addSubview:view];
    
    [pageLoadeViewDic setObject:viewController forKey:[NSNumber numberWithInteger:page]];

}

//卷动结束后的一些跟新操作
- (void)updateScrollView
{
    TXTabBarPageView *pageView = self.tabBarPageView;
    CGFloat pagewidth = pageView.frame.size.width;
    int page = floor(pageView.contentOffset.x/pagewidth);
    currentPage = page;
    
    
    if (page>0 && page<pageCount)
    {
        BOOL isCurrentPageLoade = [pageLoadeViewDic objectForKey:[NSNumber numberWithInt:page]]?YES:NO;
        BOOL isPrePageLoade = [pageLoadeViewDic objectForKey:[NSNumber numberWithInt:page-1]]?YES:NO;
        BOOL isNextPageLoade = [pageLoadeViewDic objectForKey:[NSNumber numberWithInt:page+1]]?YES:NO;
        if (!isCurrentPageLoade)
        {
            [self loadPageView:page];
        }
        
        if (page - 1 > 0)
        {
            if (!isPrePageLoade)
            {
                [self loadPageView:page-1];
            }
        }
        
        if (page + 1 <pageCount)
        {
            if (!isNextPageLoade)
            {
                [self loadPageView:page+1];
            }
        }
        

    }
    
    [self.tabBarTopView setSelectedButton:page];
    
}

//改变当前显示的页面
- (void)changePageWithPage:(NSInteger)page
{
    [self.tabBarPageView setContentOffset:CGPointMake(page * self.view.frame.size.width, 0) animated:YES];
}


#pragma mark - UIScrollViewDelegate
//通过滑动结束时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //调整顶部滑条按钮状态
    [self updateScrollView];
}



//通过按钮翻页时调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateScrollView];
    [self.tabBarPageView endEditing:YES];
}

//开始滑动的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tabBarPageView endEditing:YES];//滑动时使tabBarPageView中所有对象退出第一响应者 使键盘关掉
}



#pragma mark - TXTabBardataSource
- (UIViewController *)tabBarContentView:(TXTabBarPageView *)tabBarContentView pageAtIndex:(NSInteger)indexPath
{
    UITableViewController *controller = [[UITableViewController alloc]init];
    
    return controller;
}

- (NSInteger)tabBarContentView:(TXTabBarPageView *)tabBarContentView
{
    return 4;
}

#pragma mark - TXTabBardelegat
- (void)changeSelectedWithIndex:(NSInteger)index
{
    [self changePageWithPage:index];
}
@end
