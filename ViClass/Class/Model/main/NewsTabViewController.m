//
//  NewsTabViewController.m
//  WhbApp
//
//  首页入口、滑动Tab
//
//  Created by chen yulong on 13-9-4.
//  Copyright (c) 2013年 Bibo. All rights reserved.
//

#import "NewsTabViewController.h"
#import "NewsTabView.h"
#import "MainViewController.h"
#import "TypeBean.h"
#import "TypesBean.h"
#import "AppDelegate.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "MyViewController.h"
#import "TheTopViewController.h"
#import "TableListViewController.h"
#import "AllCourseViewController.h"

#define kTagTabBase 80
#define kColorTopTitle RGBCOLOR(237, 34, 34);

@interface NewsTabViewController ()<ALDTabViewDelegate>{
    UIScrollView *_myscrollerview; //NO Retain
    BOOL _isNotifyRefrash;
}
//@property (nonatomic, assign, readwrite) UIView *contentView;
@property (nonatomic, assign, readwrite) UIScrollView *contentView;
@property (nonatomic, retain           ) ALDTabsView  *tabsContainerView;
@property (nonatomic, retain           ) NSArray      *viewControllers;
@property (nonatomic, retain           ) NSArray      *newsTypes;

@end

@implementation NewsTabViewController

@synthesize contentView       = _contentView;
@synthesize tabsContainerView = _tabsContainerView;
@synthesize viewControllers   = _viewControllers;
@synthesize tabStyle          = _tabStyle;
@synthesize delegate          = _delegate;
@synthesize newsTypes         = _newsTypes;

- (void)viewWillAppear:(BOOL)animated{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"bringCustomTabBarToFront" object:nil];
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isViewLoaded]) {
            [viewController viewWillAppear:animated];
        }
    }
    [super viewWillAppear:animated];
}

- (id)init
{
    self = [super init];
    if (self) {
        _isNotifyRefrash               = NO;
        ALDTabStyle *style             = [ALDTabStyle  defaultStyle];
        style.tabsViewHeight           = 40;
        style.tabHeight                = 40;
        style.selectedTagBgColor       = RGBCOLOR(237, 34, 34);
        style.unselectedTabColor       = [UIColor clearColor];
        style.selectedTabColor         = [UIColor clearColor];
        style.selectedTitleTextColor   = kColorTopTitle;//标题选中颜色
        style.selectedTitleFont        = kFontSize30px;//标题选中字体大小
        style.unselectedTitleFont      = kFontSize30px;//标题未选中时字体大小
        style.unselectedTitleTextColor = KWordBlackColor;
        self.tabStyle                  = style;
    }
    return self;
}

- (void)_reconfigureTabs {
    NSUInteger thisIndex = 0;
    
    for (NewsTabView *aTabView in self.tabsContainerView.tabViews) {
        aTabView.style = self.tabStyle;
        
        if (thisIndex == currentTabIndex) {
            aTabView.selected = YES;
            [self.tabsContainerView bringSubviewToFront:aTabView];
        } else {
            aTabView.selected = NO;
            [self.tabsContainerView sendSubviewToBack:aTabView];
        }
        
        aTabView.autoresizingMask = UIViewAutoresizingNone;
        
        [aTabView setNeedsDisplay];
        
        ++thisIndex;
    }
}

-(void) setSelecteTabIndex:(NSInteger) index{
    if (index>=_tabsContainerView.tabViews.count) {
        return;
    }else if (index<0){
        return;
    }
    NewsTabView *tabView=[_tabsContainerView.tabViews objectAtIndex:index];
    [self didTapTabView:tabView];
}

- (void)scrollToIndex:(NSInteger)index { //切换到下一张
    if (_myscrollerview) {
        NSArray *tabViews=self.tabsContainerView.tabViews;
        if (index<tabViews.count) {
            if (index>2) {
                CGRect frame;
                UIView *tabView=[tabViews objectAtIndex:(index-2)];
                frame.origin.x = tabView.frame.origin.x;
                frame.origin.y = 0;
                frame.size     = _myscrollerview.frame.size;
                [_myscrollerview scrollRectToVisible:frame animated:YES];
            }else {
                CGRect frame;
                UIView *tabView=[tabViews objectAtIndex:0];
                frame.origin.x = tabView.frame.origin.x;
                frame.origin.y = 0;
                frame.size     = _myscrollerview.frame.size;
                [_myscrollerview scrollRectToVisible:frame animated:YES];
            }
        }
    }
}

/**
 *按钮点击事件
 */
- (void)typeAction
{
    AllCourseViewController *controller = [[AllCourseViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)_makeTabViewCurrent:(NewsTabView *)tabView {
    if (!tabView) return;
    currentTabIndex = tabView.tag - kTagTabBase;
    
    [self scrollToIndex:currentTabIndex];
    
    [_contentView setContentOffset:CGPointMake(currentTabIndex*_contentView.frame.size.width, 0)  animated:YES];
    if (currentTabIndex<_viewControllers.count) {
        id controller=[_viewControllers objectAtIndex:currentTabIndex];
        if ([controller respondsToSelector:@selector(setViewShowing:)]) {
            [controller setViewShowing:YES];
        }
    }
    
//    UIViewController *viewController = [self.viewControllers objectAtIndex:currentTabIndex];
//    
//    [self.contentView removeFromSuperview];
//    self.contentView = viewController.view;
//    
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    self.contentView.frame = CGRectMake(0, self.tabsContainerView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height-self.tabsContainerView.bounds.size.height);
//
//    [self.view addSubview:self.contentView];
    
    [self _reconfigureTabs];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UITableView class]]) {
        return;
    }
    
    if(scrollView==_contentView){
        int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
        currentTabIndex = index;
        
        [self scrollToIndex:currentTabIndex];
        [self _reconfigureTabs];
        if (currentTabIndex<_viewControllers.count) {
            id controller=[_viewControllers objectAtIndex:currentTabIndex];
            if ([controller respondsToSelector:@selector(setViewShowing:)]) {
                [controller setViewShowing:YES];
            }
        }
    }
}

- (void)didTapTabView:(NewsTabView *)tappedView {
    NSUInteger index = tappedView.tag - kTagTabBase;
    NSAssert(index < [self.viewControllers count], @"invalid tapped view");
    
    UIViewController *viewController = [self.viewControllers objectAtIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(shouldMakeTabCurrentAtIndex:controller:tabBarController:)])
        if (![self.delegate shouldMakeTabCurrentAtIndex:index controller:viewController tabBarController:self])
            return;
    
    [self _makeTabViewCurrent:tappedView];
    
    if ([self.delegate respondsToSelector:@selector(didMakeTabCurrentAtIndex:controller:tabBarController:)])
        [self.delegate didMakeTabCurrentAtIndex:index controller:viewController tabBarController:self];
}

-(void)TestData
{
    TypesBean *bean1=[[TypesBean alloc] init];
    bean1.sid=[NSNumber numberWithInt:1];
    bean1.name=@"热门";
    bean1.defaultDisplay=[NSNumber numberWithInt:1];
    
    TypesBean *bean2=[[TypesBean alloc] init];
    bean2.sid=[NSNumber numberWithInt:2];
    bean2.name=@"最新";
    bean2.defaultDisplay=[NSNumber numberWithInt:0];
    
    TypesBean *bean3=[[TypesBean alloc] init];
    bean3.sid=[NSNumber numberWithInt:3];
    bean3.name=@"推荐";
    bean3.defaultDisplay=[NSNumber numberWithInt:0];

    NSArray *array=[NSArray arrayWithObjects:bean1,bean2,bean3, nil];
    
    [self initData:array];
}

-(void) initData:(NSArray *)array{
    if(!array || array.count==0){
        return;
    }

    BOOL defaultDisplay=NO;
    int index=0;
    NSMutableArray *tempArray = [NSMutableArray array];
    for (TypesBean *bean in array) {

        MainViewController *subView=[[MainViewController alloc] init];
        subView.title            = bean.name;
        subView.typeId           = bean.sid;
        subView.parentController = self;
        [tempArray addObject:subView];
        
        if(!defaultDisplay && [bean.defaultDisplay intValue]==1){
            defaultDisplay=YES;
            currentTabIndex=index;
        }
        
        index++;
    }
    
    self.viewControllers=tempArray;
    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
}

-(void) updateView{
    [ALDUtils removeWaitingView:self.view];
    _tabsContainerView.hidden=NO;
    NSArray *subViews=[_myscrollerview subviews];
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
    
    subViews=[_contentView subviews];
    for (UIView *subView in subViews) {
        [subView removeFromSuperview];
    }
    
    CGRect frame = self.view.frame;
    CGFloat viewWidth = CGRectGetWidth(frame);
    
    NSMutableArray *allTabViews = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
    CGFloat overlap             = (viewWidth - 3*45)/6.f;
    CGFloat startX              = overlap;
    CGFloat defaultWidth        = 45;
    CGFloat allWidth            = startX;
    
    CGFloat selfWidth=_contentView.frame.size.width;
    CGFloat selfHeght=_contentView.frame.size.height;
    for (UIViewController *viewController in self.viewControllers) {
        NSUInteger tabIndex = [allTabViews count];
        // The selected tab's bottom-most edge should overlap the top shadow of the tab bar under it.
        if (tabIndex == 2) {
            startX = 5*(viewWidth - 3*45)/6.f + 45*2;
        }
        CGRect tabFrame         = CGRectMake(startX, 0, defaultWidth, self.tabStyle.tabsViewHeight);
        NewsTabView *tabView    = [[NewsTabView alloc] initWithFrame:tabFrame title:viewController.title];
        tabView.tag             = kTagTabBase + tabIndex;
        tabView.titleLabel.font = self.tabStyle.unselectedTitleFont;
        tabView.delegate        = self;
        [_myscrollerview addSubview:tabView];
        [allTabViews addObject:tabView];
        allWidth               += tabView.frame.size.width;
        startX=(tabIndex+2)*overlap+allWidth;
        
        viewController.view.frame            = CGRectMake(selfWidth*tabIndex, 0, selfWidth, selfHeght);
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_contentView addSubview:viewController.view];
        
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(2*(viewWidth - 3*45)/6.f + 45 - 0.5f, 12.5f, 1, 15.f)];
    line.backgroundColor = kLineColor;
    [_myscrollerview addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(4*(viewWidth - 3*45)/6.f + 45*2 - 0.5f, 12.5f, 1, 15.f)];
    line.backgroundColor = kLineColor;
    [_myscrollerview addSubview:line];
    
    [_myscrollerview setContentSize:CGSizeMake(startX, self.tabStyle.tabsViewHeight)];
    
    self.tabsContainerView.tabViews = allTabViews;
    
    CGFloat width=selfWidth*_viewControllers.count;
    [_contentView setContentSize:CGSizeMake(width, 0)];
    
    [self setSelecteTabIndex:currentTabIndex];
}

-(void) viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    CGRect frame               = self.view.frame;
    CGFloat viewWidth               = CGRectGetWidth(frame);
    CGFloat viewHeight              = CGRectGetHeight(frame);
    
    //导航栏设置按钮
    UIButton *btn                          = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame                              = CGRectMake(0, 0, 25, 25);
    [btn setBackgroundImage:[UIImage imageNamed:@"zoonBg"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(typeAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem          = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    self.view.backgroundColor  = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    CGRect tabsViewFrame                    = CGRectMake(0, 0, frame.size.width, self.tabStyle.tabsViewHeight);
    self.tabsContainerView                  = [[ALDTabsView alloc] initWithFrame:tabsViewFrame];
    self.tabsContainerView.needResizeTab    = NO;
    self.tabsContainerView.backgroundColor  = [UIColor clearColor];
    self.tabsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tabsContainerView.style            = self.tabStyle;
    [self.view addSubview:_tabsContainerView];
    
    // Tabs are resized such that all fit in the view's width.
    // We position the tab views from left to right, with some overlapping after the first one.
    CGFloat height                            = self.tabStyle.tabsViewHeight;
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, height)];
    scrollView.backgroundColor=RGBCOLOR(240, 240, 240);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask               = UIViewAutoresizingFlexibleWidth;
    scrollView.delegate                       = self;
    [scrollView setContentSize:CGSizeMake(frame.size.width, height)];
    [self.tabsContainerView addSubview:scrollView];
    _myscrollerview                           = scrollView;
//    UIView *redLineView         = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabStyle.tabsViewHeight-1,frame.size.width, 1)];
//    redLineView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
//    redLineView.backgroundColor = kColorTopTitle;
//    [_tabsContainerView addSubview:redLineView];
    _tabsContainerView.hidden=YES;
    
    
    
    //内容栏
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, self.tabsContainerView.bounds.size.height, frame.size.width, frame.size.height-self.tabsContainerView.bounds.size.height)];
    scrollView.backgroundColor                = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.autoresizingMask               = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.delegate                       = self;
    scrollView.pagingEnabled                  = YES;
    [scrollView setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
    self.contentView                          = scrollView;
    [self.view addSubview:scrollView];
    
    
    //底部工具栏
    ALDImageView *bottomImageView = [[ALDImageView alloc] initWithFrame:CGRectMake(0, viewHeight - 70, viewWidth, 70)];
    if (viewHeight == 736) {
        bottomImageView.frame = CGRectMake(0, viewHeight - 220/3.f, viewWidth, 220/3.f);
    }
    bottomImageView.backgroundColor = [UIColor clearColor];
    bottomImageView.userInteractionEnabled = YES;
    bottomImageView.image = [UIImage imageNamed:@"bg_bottom"];
    if (viewHeight == 667) {
        bottomImageView.image = [UIImage imageNamed:@"bg_bottom-667h"];
    }else if (viewHeight == 736) {
        bottomImageView.image = [UIImage imageNamed:@"bg_bottom@3x"];
    }
    bottomImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bottomImageView];
    
    //说说按钮
    ALDButton *button = [self createButton:CGRectMake((viewWidth - 100/2.f)/2.f, 10, 100/2.f, 100/2.f) title:@"课表" textColor:RGBCOLOR(255, 255, 255) textFont:kFontSize28px];
    button.tag = 0x0010;
    button.backgroundColor = [UIColor redColor];
   //    [button setBackgroundImage:[UIImage imageNamed:@"icon_microphone"] forState:UIControlStateNormal];
//    if (viewWidth == 414) {
//        button.frame = CGRectMake((viewWidth - 100/2.f)/2.f, 13.3f, 100/2.f, 100/2.f);
//        [button setBackgroundImage:[UIImage imageNamed:@"icon_microphone@3x"] forState:UIControlStateNormal];
//    }
    [button addTarget:self action:@selector(ClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 100/4.f;
    button.layer.masksToBounds = YES;
    [bottomImageView addSubview:button];
    
    //我的按钮
    button=[self createIconTextButton:CGRectMake((viewWidth/2.f - 32 - 65)/2.f + 32 + viewWidth/2.f, 21, 65, 70-21) tag:0x0011 text:@"我的" icon:[UIImage imageNamed:@"icon_my"] textColor:KWordWhiteColor];
    if (viewWidth == 414) {
        button=[self createIconTextButton:CGRectMake((viewWidth/2.f - 32 - 85)/2.f + 32 + viewWidth/2.f, 24.5f, 85, 220/3.f-24) tag:0x0011 text:@"我的" icon:[UIImage imageNamed:@"icon_my@3x"] textColor:KWordWhiteColor];
    }
    [bottomImageView addSubview:button];
    
    //导师按钮
    button=[self createIconTextButton:CGRectMake((viewWidth/2.f - 32 - 65)/2.f, 21, 65, 70-21) tag:0x0012 text:@"排行榜" icon:[UIImage imageNamed:@"icon_tutor"] textColor:KWordWhiteColor];
    if (viewWidth == 414) {
        button=[self createIconTextButton:CGRectMake((viewWidth/2.f - 32 - 85)/2.f, 24.5f, 85, 220/3.f-24) tag:0x0012 text:@"排行榜" icon:[UIImage imageNamed:@"icon_tutor@3x"] textColor:KWordWhiteColor];
    }
    [bottomImageView addSubview:button];
    
//    [self performSelectorInBackground:@selector(loadData) withObject:nil];
    [self TestData];
}

-(void)ClickBtn:(ALDButton *)sender {
    switch (sender.tag) {
        case 0x0010:{ //课表
            TableListViewController *releaseController=[[TableListViewController alloc] init];
            releaseController.title = @"我的课表";
//            releaseController.modalTransitionStyle=UIModalTransitionStyleCoverVertical; //设置模态视图的变换样式
//            [self presentViewController:releaseController animated:YES completion:^{}];//加载模态视图
            [self.navigationController pushViewController:releaseController animated:YES];
        }
            break;
            
        case 0x0011:{ //我的
            MyViewController *myController = [[MyViewController alloc] init];
            myController.title = @"我的";
            [self.navigationController pushViewController:myController animated:YES];
        }
            break;
            
        case 0x0012:{ //排行榜
            TheTopViewController *tutorController = [[TheTopViewController alloc] init];
            tutorController.title = @"排行榜";
            [self.navigationController pushViewController:tutorController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(ALDButton*) createIconTextButton:(CGRect) frame tag:(int)tag text:(NSString*)text icon:(UIImage*)icon textColor:(UIColor*)textColor{
    ALDButton *button = [ALDButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    CGFloat startX=(frame.size.width-25)/2.f;
    CGFloat startY=4;
    CGRect iconFrame=CGRectMake(startX, startY, 25.f, 25.f);
    ALDImageView *iconView = [[ALDImageView alloc] initWithFrame:iconFrame];
    iconView.image = icon;
    [button addSubview:iconView];
    startY+=iconFrame.size.height;
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, startY, frame.size.width, 18.0f)];
    label.text=text;
    label.textColor=textColor;
    label.font = [UIFont systemFontOfSize:13.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment=TEXT_ALIGN_CENTER;
    [button addSubview:label];
    
    button.backgroundColor=[UIColor clearColor];
    button.selectBgColor=[UIColor clearColor];
    button.tag = tag;
    [button addTarget:self action:@selector(ClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (ALDButton *)createButton:(CGRect )frame title:(NSString *)title textColor:(UIColor *)textColor textFont:(UIFont *)textFont {
    ALDButton *button = [ALDButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    button.titleLabel.font = textFont;
    [button setBackgroundColor:[UIColor clearColor]];
    
    return button;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.contentView       = nil;
    self.viewControllers   = nil;
    self.tabStyle          = nil;
    self.tabsContainerView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.newsTypes         = nil;
    self.tabsContainerView = nil;
    self.tabStyle          = nil;
    self.contentView       = nil;
    self.viewControllers   = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
