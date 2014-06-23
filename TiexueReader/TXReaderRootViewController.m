
//  TXReaderRootViewController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-2-21.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXReaderRootViewController.h"
#import "TXDataViewController.h"
#import "TXPageModelController.h"
#import "TXAppUtils.h"
#import "TXSourceManager.h"
#import "TXChapterListCell.h"
#import "TXDefine.h"
#import "TXFontSettingViewController.h"
#import "TXUserConfig.h"
#import "TXPagesSettingViewController.h"
#import "MobClick.h"


@interface TXReaderRootViewController ()
@property (readonly, strong, nonatomic) TXPageModelController *modelController;
@property (readonly,strong, nonatomic) NSDictionary *stringAttribute;
@property (strong, nonatomic) NSArray *chapterIDArray;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookMarkBtn;


@end

@implementation TXReaderRootViewController
{
    CGRect rect;
    UIBarButtonItem *fontSettingBtn;
    UIBarButtonItem *rightBarbutton;
    
    UITableViewController *leftTableViewController;
    
    TXFontSettingViewController *fontSettingViewController;
    TXPagesSettingViewController *pagesSettingViewController;
    BOOL isMarked ;
    BOOL _isWillPushingPanel;
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
    _isWillPushingPanel = NO;
	// Do any additional setup after loading the view.
    [self startWait];
    [self setupModelController];
    [self setupPageView];
    [self setupDeckView];
    [self setupToolBar];
    [self setupGestureRecognizer];
    [self addObservers];
    
    [self addHistoryReadData:self.bookData];
    //隐藏状态栏和工具栏 不带动画效果
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self clear];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"阅读器"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"阅读器"];
    
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSNumber *bookID = [NSNumber numberWithInteger:self.bookData.bookID];
    BOOL needAddShelf = [[TXUserConfig instance].bookDataList objectForKey:bookID]?NO:YES;
    if (needAddShelf && !_isWillPushingPanel)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加入书架" message:@"喜欢这本书就加入书架吧" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
}

#pragma mark - 初始化组件
//设置翻页组件
- (void)setupPageView
{
    //设置翻页组件
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self.modelController;
    [self setFirstPagviewData];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    [self.pageViewController didMoveToParentViewController:self];
    
    //将pageView得监听列表付给self，这样self上得ui就不会遮挡住翻页得手势了
    //self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}
//设置左右view切换控件＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
- (void)setupDeckView
{
    UIStoryboard *storyboard = self.storyboard;
    UITableViewController *leftController = [storyboard instantiateViewControllerWithIdentifier:@"LeftViewController"];
    leftController.tableView.dataSource = self;
    leftController.tableView.delegate = self;
    leftTableViewController = leftController;
    
    UIViewController *rightController = [storyboard instantiateViewControllerWithIdentifier:@"RightViewController"];
    
    
    self.deckController = [[IIViewDeckController alloc] initWithCenterViewController:self.pageViewController leftViewController:leftController rightViewController:rightController];
    self.deckController.delegate = self;
    self.deckController.panningMode = IIViewDeckPanningViewPanning;
    self.deckController.panningView = self.pageViewController.view;
    self.deckController.view.frame = self.view.bounds;
    self.deckController.leftController.view.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
    //    self.deckController.openSlideAnimationDuration = 2.0f; // In seconds
    //    self.deckController.closeSlideAnimationDuration = 2.0f;
    //    self.deckController.leftSize = 50;
    //    self.deckController.rightSize = 50;
    [self.view addSubview:self.deckController.view];
}
//设置toolbar
- (void)setupToolBar
{
    self.title = self.bookData.bookName;//设置标题
    UIBarButtonItem *one = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"directory"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnAction)];
    fontSettingBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"font"] style:UIBarButtonItemStylePlain target:self action:@selector(fontSettingAction)];
    //    UIBarButtonItem *three = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
    UIBarButtonItem *three = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pageBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnAction)];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self setToolbarItems:[NSArray arrayWithObjects:flexItem, one, flexItem, fontSettingBtn, flexItem,  three, flexItem, nil]];
}
//设置手势
- (void)setupGestureRecognizer
{
    //加入点击手势的监听
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.delegate=self;
    [self.pageViewController.view addGestureRecognizer:tapGesture];
    rect = CGRectMake(self.view.center.x-80, self.view.center.y-142, 160, 284);//中间可点击区域
    
}
//设置字体设置面板
- (TXFontSettingViewController *)createFontSettingView
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    TXFontSettingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FontSetting"];
    viewController.nightModelIsOn = userConfig.isNightMode;
    viewController.light = [UIScreen mainScreen].brightness;
    viewController.fontSize = (userConfig.fontSize - FONT_SIZE_MIN)/FONT_SIZE_STEP ;
    viewController.lineSpace = (userConfig.lineHeightMultiple - 1)/0.5;
    
    
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //添加关闭模态得手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapCloseFontSetting:)];
    tapGesture.delegate=self;
    [viewController.view addGestureRecognizer:tapGesture];
    
    
    UIViewController* rootViewController = self.view.window.rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;//必须这样设置不然ios会因为父级view呗遮盖而卸载父级view造成背景变成黑色
    
    return viewController;
}

//设置进度设置面板
- (TXPagesSettingViewController *)createPagesSettingView
{
    TXPagesSettingViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PagesSetting"];
    [viewController setCurrentPage:self.modelController.currentPage totlePage:self.modelController.totlePage];
    
    
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //添加关闭模态得手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapClosePagesSetting:)];
    tapGesture.delegate=self;
    [viewController.view addGestureRecognizer:tapGesture];
    
    
    UIViewController* rootViewController = self.view.window.rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;//必须这样设置不然ios会因为父级view呗遮盖而卸载父级view造成背景变成黑色
    
    return viewController;
}

#pragma mark - 私有方法
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lightChangeHandle:) name:CHANGE_LIGHT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChangeHandle:) name:CHANGE_FONTSIZE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lineSpaceChangeHandle:) name:CHANGE_LINE_SPACE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightModeChangeHandle:) name:CHANGE_NIGHT_MODEL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrentPageHandle:) name:CHANGE_CURRENT_PAGE object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_LIGHT object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_FONTSIZE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_LINE_SPACE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_NIGHT_MODEL object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGE_CURRENT_PAGE object:nil];
}

- (void)clear
{
    [self removeObservers];
}

- (void)setFirstPagviewData
{

    NSInteger page = self.bookData.currentPage;
    
    TXDataViewController *startingViewController = [self.modelController viewControllerAtIndex:page storyboard:self.storyboard];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

}

- (void)addHistoryReadData:(TXBookData *)bookData
{
    NSMutableArray *list = [TXUserConfig instance].historyReadData;
    for (int i = 0 ; i<list.count; i++)
    {
        if (i>10)
        {
            [list removeObjectAtIndex:i];
            i--;
        }else
        {
            TXBookData *data = (TXBookData *)[list objectAtIndex:i];
            if (data.bookID == bookData.bookID)
            {
                [list removeObjectAtIndex:i];
                i--;
            }
        }
        
        
    }

    [[TXUserConfig instance].historyReadData addObject:self.bookData];
}
#pragma mark 数据获取方法
//初始化 数据模型
- (void)setupModelController
{
    if (!_modelController)
    {
        _modelController = [[TXPageModelController alloc] init];
        _modelController.delegate = self;
        
        if ([self isNeedDownloadChapterListWithBookData:self.bookData])
        {
            [TXSourceManager getChapterListWithBookID:self.bookData.bookID completionHandler:^(NSDictionary *data,NSError *error) {
                
                if (data && data.count>0)
                {
                    self.bookData.chapterList = data;
                    self.bookData.chapterListlastUpdateTime = [TXAppUtils getMillisecondTimestampWithDate:[NSDate date]];
                    self.chapterIDArray = [self.bookData.chapterList.allKeys sortedArrayUsingSelector:@selector(compare:)];
                    
                    //因为_modelController 要负责翻章时的处理 所以必须把整本书的数据给他
                    _modelController.bookData = self.bookData;
                    [_modelController setFileWithChapterID:self.bookData.currentChapterID pageIndex:self.bookData.currentPage attribute:self.stringAttribute];
                }else
                {
                    
                    [TXAppUtils showAlertWithTitle:@"下载失败" Message:error.localizedDescription];
                    [self stopWait];
                }
                
            }];
        }else
        {
            self.chapterIDArray = [self.bookData.chapterList.allKeys sortedArrayUsingSelector:@selector(compare:)];
            _modelController.bookData = self.bookData;
            [_modelController setFileWithChapterID:self.bookData.currentChapterID pageIndex:self.bookData.currentPage attribute:self.stringAttribute];
        }
        

    }

}

- (BOOL)isNeedDownloadChapterListWithBookData:(TXBookData *)bookData
{

    if (bookData.chapterList && bookData.chapterList.count>0 && bookData.lastUpdateTime<bookData.chapterListlastUpdateTime)
    {
        return NO;
    }
    return YES;
}
//- (TXPageModelController *)modelController
//{
//    // Return the model controller object, creating it if necessary.
//    // In more complex implementations, the model controller may be passed to the view controller.
//    
//    return _modelController;
//}

//取得文章显示需要用的attribute
- (NSDictionary *)stringAttribute
{
    TXUserConfig *userConfig = [TXUserConfig instance];
    //段落属性
    NSMutableParagraphStyle *ps =[[NSMutableParagraphStyle alloc]init];
    ps.lineBreakMode = NSLineBreakByCharWrapping;
    ps.alignment=NSTextAlignmentJustified;
    ps.lineHeightMultiple = userConfig.lineHeightMultiple;
    
//    ps.paragraphSpacing=8;
//    ps.firstLineHeadIndent =40;
//    ps.headIndent =20;
//    ps.tailIndent = -20;
    
    UIFont *font = [UIFont fontWithName:userConfig.fontName size:userConfig.fontSize];
    
    NSDictionary *attribute = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:ps};
    
//    NSString *key = [TXAppUtils getOffsetKeyWithAttributr:attribute];
//    self.bookData.currentOffsetKey = key;
    return attribute;
}







#pragma mark 行为方法
//添加移除书签
- (void)markBook
{
    //根据书签列表判断是要添加书签还是移除书签
    if (isMarked) {
        isMarked = NO;
        self.bookMarkBtn.image = [UIImage imageNamed:@"bookmark_click"];
    }else
    {
        isMarked = YES;
        self.bookMarkBtn.image = [UIImage imageNamed:@"bookmark_empty"];
    }
    
}
//更改当前章节
- (void)changeChapterWithChapterID:(int)chapterID
{
    [_modelController setFileWithChapterID:chapterID pageIndex:1 attribute:self.stringAttribute];
}

- (void)updateTheme
{
    self.navigationController.navigationBar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.navigationBar.barTintColor = [TXAppUtils instance].navigationBarBackGroundColor;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [TXAppUtils instance].titleFontTint,NSForegroundColorAttributeName, nil];
    
    self.navigationController.toolbar.tintColor = [TXAppUtils instance].interactionTint;
    self.navigationController.toolbar.barTintColor = [TXAppUtils instance].toolBarBackGroundColor;
    
    self.deckController.leftController.view.backgroundColor = [TXAppUtils instance].tableViewBackGroundColor;
}

//显示或者隐藏工具栏
- (void)hideToolsUI:(BOOL)isHiden
{
    [self.navigationController setNavigationBarHidden:isHiden animated:YES];
    [self.navigationController setToolbarHidden:isHiden animated:YES];
    //隐藏和显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:isHiden withAnimation:UIStatusBarAnimationFade];
    _fontSettingHidden =YES;
    _pagesSettingHidden =YES;
}

//显示或者隐藏字体设置界面
- (void)setFontSettingHidden:(BOOL)hide
{
    _fontSettingHidden = hide;
    if (fontSettingViewController)
    {
        if (hide)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            _isWillPushingPanel = NO;
        }else
        {
            _isWillPushingPanel = YES;
            [self presentViewController:fontSettingViewController animated:YES completion:nil];
        }
        
    }else
    {
        if (!hide)
        {
            _isWillPushingPanel = YES;
            fontSettingViewController = [self createFontSettingView];
            [self presentViewController:fontSettingViewController animated:YES completion:nil];
        }
    }
    
}
//显示或者隐藏进度设置界面
- (void)setPagesSettingHidden:(BOOL)hide
{
    _pagesSettingHidden = hide;
    [pagesSettingViewController setCurrentPage:self.modelController.currentPage totlePage:self.modelController.totlePage];
    if (pagesSettingViewController)
    {
        if (hide)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            _isWillPushingPanel = NO;
        }else
        {
            _isWillPushingPanel = YES;
            [self presentViewController:pagesSettingViewController animated:YES completion:nil];
        }
        
    }else
    {
        if (!hide)
        {
            _isWillPushingPanel = YES;
            pagesSettingViewController = [self createPagesSettingView];
            [self presentViewController:pagesSettingViewController animated:YES completion:nil];
        }
    }
    
}
#pragma mark UI事件处理函数
//打开目录页
- (void)leftBtnAction
{
    [self.deckController toggleLeftViewAnimated:YES];
    [self hideToolsUI:YES];
    [leftTableViewController.tableView reloadData];
}

////打开评论页
//- (void)rightBtnAction
//{
//    [self.deckController toggleRightViewAnimated:YES];
//    [self hideToolsUI:YES];
//}

//打开评论页
- (void)rightBtnAction
{
    self.pagesSettingHidden = !self.pagesSettingHidden;
}

//打开字体设置页
- (void)fontSettingAction
{
    self.fontSettingHidden = !self.fontSettingHidden;
}
- (IBAction)pressBookMarkBtn:(id)sender {
    [self markBook];
}

#pragma mark 全局事件处理函数
- (void)fontSizeChangeHandle:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    NSNumber *value = [dic objectForKey:@"value"];
    NSInteger size = value.integerValue * FONT_SIZE_STEP + FONT_SIZE_MIN;
    TXUserConfig *userConfig = [TXUserConfig instance];
    userConfig.fontSize = size;
    
    NSDictionary *attribute = [self stringAttribute];
    
    
    [self.modelController changeAttribute:attribute];
    
}
- (void)lineSpaceChangeHandle:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    NSNumber *value = [dic objectForKey:@"value"];
    float size = value.intValue * 0.5f + 1;
    TXUserConfig *userConfig = [TXUserConfig instance];
    userConfig.lineHeightMultiple = size;
    
    
    NSDictionary *attribute = [self stringAttribute];
    
    
    [self.modelController changeAttribute:attribute];
}
- (void)lightChangeHandle:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    NSNumber *value = [dic objectForKey:@"value"];
    [[UIScreen mainScreen] setBrightness:value.floatValue];
}

- (void)nightModeChangeHandle:(NSNotification *)notification {
    NSDictionary *dic = notification.userInfo;
    NSNumber *value = [dic objectForKey:@"value"];
    BOOL isOn = value.boolValue;

    TXUserConfig *userConfig = [TXUserConfig instance];
    userConfig.isNightMode = isOn;
    

    //发送 更改主题的消息
    AppTheme theme = isOn?THEME_NIGHT:THEME_NORMAL;
    [[TXAppUtils instance] setTheme:theme];
    [self updateTheme];
    
    
}

- (void)changeCurrentPageHandle:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    NSNumber *value = [dic objectForKey:@"value"];
    
    [self.modelController changePage:value.integerValue];
}

#pragma mark 手势处理函数
// 询问一个手势接收者是否应该开始解释执行一个触摸接收事件 只要这里返回no就不响应此次事件，将事件继续向后传递
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.deckController.isAnySideOpen)
    {
        return YES;
    }else
    if (gestureRecognizer.view == self.pageViewController.view)
    {
        CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
        if (CGRectContainsPoint(rect, currentPoint) )
        {
            return YES;
        }else
        {
            return NO;
        }
        
    }
    
    return YES;

}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view == self.pageViewController.view)
    {
        CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
        if (CGRectContainsPoint(rect, currentPoint) )
        {
            BOOL isHiden = self.navigationController.navigationBarHidden;
            [self hideToolsUI:!isHiden];
        }else
        {
            [self.deckController closeLeftViewAnimated:YES];
        }
    }
}

- (void)handleTapCloseFontSetting:(UIGestureRecognizer *)gestureRecognizer
{
    self.fontSettingHidden = YES;
}

- (void)handleTapClosePagesSetting:(UIGestureRecognizer *)gestureRecognizer
{
    self.pagesSettingHidden = YES;
}


#pragma mark - IIViewDeckControllerDelegate methods
//DeckController判断是否允许拖拽
- (BOOL)viewDeckController:(IIViewDeckController *)viewDeckController shouldBeginPanOverView:(UIView *)view
{
    return viewDeckController.isAnySideOpen;
}


#pragma mark - UIPageViewController delegate methods
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

//pageViewController翻页前调用
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{

    if (!self.navigationController.navigationBarHidden) {
        [self hideToolsUI:YES];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
    if (!completed) {
        //这里是为了解决在翻章的过程中 翻页到一半又退回去的时候页面还在显示前一章 但是数据已经到了下一章的问题 但同时会带来“如果分页计算没有完成将会重新开始计算分页”的问题，影响不大 以后解决
        TXDataViewController *controller = previousViewControllers[0];
        [self.modelController changeCurrentPageViewController:controller];
        [self.modelController setFileWithChapterID:controller.currentChapterID pageIndex:-1 attribute:self.stringAttribute];
        
        
    }

}

#pragma mark - UITableViewController dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookData.chapterList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ChapterListCell";
    
    NSNumber *key = self.chapterIDArray[indexPath.row];
    TXChapterData *data = [self.bookData.chapterList objectForKey:key];
    TXChapterListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDataWithChapterData:data];
    if (self.bookData.currentChapterID == key.integerValue) {
        cell.backgroundColor = COLOR_BLUE_LIGHT;
    }else
    {
        cell.backgroundColor = [TXAppUtils instance].tableViewCellBackGroundColor;
    }
    
    NSArray *subviews = cell.contentView.subviews;
    for (UIView *subView in subviews)
    {
        if ([subView isKindOfClass:[UILabel class]])
        {
            UILabel *label = (UILabel *)subView;
            label.textColor = [TXAppUtils instance].titleFontTint;
            
            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.deckController closeLeftViewAnimated:YES];

    NSNumber *key = self.chapterIDArray[indexPath.row];
    [self changeChapterWithChapterID:key.intValue];
    
}

#pragma mark - TXPageModelDelegate
- (void)startWait
{
    self.view.userInteractionEnabled = NO;
//    [self.activityIndicator startAnimating];
    [[TXAppUtils instance].indicator startAnimating];
}

- (void)stopWait
{
    self.view.userInteractionEnabled = YES;
//    [self.activityIndicator stopAnimating];
    [[TXAppUtils instance].indicator stopAnimating];
}

#pragma mark - uiAlertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [TXSourceManager addBookToShelfWithBookData:self.bookData completionHandler:^(BOOL isSuccess, NSError *error) {
            
        }];
    }
}

@end
