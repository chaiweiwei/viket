//
//  BaseViewController.m
//  TZAPP
//
//  基类视图控制器
//
//  Created by x-Alidao on 14-8-13.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "UIBarButtonItem+ALDBackBarButtonItem.h"
#import "ALDUtils.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "BasicsLoginViewController.h"
#import "AppDelegate.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize rootController = _rootController;
@synthesize background     = _background;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.hidesBottomBarWhenPushed=YES;
        self.background=kBackgroudColor;
    }
    return self;
}

- (void)dealloc
{
    self.background=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    BOOL isIos7=isIOS7;
    if (self.navigationController /*&& !isIos7*/ && [self.navigationController viewControllers].count>1) {
        UIBarButtonItem *leftBtn=[[UIBarButtonItem alloc] initBackButtonWithTitle:ALDLocalizedString(@"Back", @"返回") color:kNavigationBarTextColor target:self action:@selector(onBackClicked)];
        self.navigationItem.leftBarButtonItem=leftBtn;
        ALDRelease(leftBtn);
        
//        ALDImageView *backImg=[[ALDImageView alloc] initWithFrame:CGRectMake(0, 10, 14, 22)];
//        backImg.image=[UIImage imageNamed:@"back1"];
//        ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
//        btn.frame=CGRectMake(0, 0, 40, 40);
//        btn.backgroundColor=[UIColor clearColor];
//        btn.selectBgColor=[UIColor clearColor];
//        [btn addSubview:backImg];
//        [btn addTarget:self action:@selector(onBackClicked) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *leftBtn=[[UIBarButtonItem alloc] initWithCustomView:btn];
//        self.navigationItem.leftBarButtonItem=leftBtn;
//        ALDRelease(leftBtn);
    }
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    if (isIos7) {
        self.extendedLayoutIncludesOpaqueBars             = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.edgesForExtendedLayout                       = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets         = NO;
        self.baseStartY=0;
    }else{
        self.baseStartY=0;
    }
    
    [self drawBackground];
}

- (void) onBackClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) drawBackground {
    if (_background!=nil && [_background isKindOfClass:[UIColor class]]) {
        self.view.backgroundColor=_background;
    }else if (_background!=nil && [_background isKindOfClass:[NSString class]]) {
        NSString *bgImage = _background;
        CGRect bounds     = self.view.frame;
        ALDImageView *imageView = [[ALDImageView alloc] init];
        [imageView setImageUrl:bgImage];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        CGFloat startY = 0;
        if (isIOS7 && (!self.navigationController ||self.navigationController.navigationBarHidden))
            startY = 20;
        imageView.frame = CGRectMake(0, startY, bounds.size.width, bounds.size.height-startY);
        [self.view addSubview:imageView];
        [self.view sendSubviewToBack:imageView];
        ALDRelease(imageView);
    }
}

- (BOOL)isLogined {
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid          = [config objectForKey:kUidKey];
    int status=[config integerForKey:KUserStatus];
    if (!uid || [uid isEqualToString:@""] || status!=1) {
        [self showLoginView];
        return NO;
    }
    return YES;
}

-(void) showLoginView{
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if (![BasicsLoginViewController isLoginViewShowing]) {
        [appDelegate showLogin];
    }
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIView *)createLine:(CGRect) frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
}


-(UILabel *) createLabel:(CGRect) frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/**
 * 数据开始加载状态通知
 * @param httpClient 请求对象
 * @param requestPath 请求标识
 */
-(void) dataStartLoad:(ALDHttpClient*)httpClient requestPath:(HttpRequestPath) requestPath{
    
}

/**
 * 数据加载状态通知
 * @param httpClient 请求对象
 * @param requestPath 请求标识
 * @param code 请求结果状态,1:成功，其他
 * @param object 加载完成回调后返回的数据对象
 **/
-(void) dataLoadDone:(ALDHttpClient*)httpClient requestPath:(HttpRequestPath) requestPath withCode:(NSInteger) code withObj:(ALDResult*) result{
    [ALDUtils removeWaitingView:self.view];
}

/**
 * 接口需要登录权限时回调
 * @param httpClient 请求对象
 * @param requestPath 请求标识
 * @param code 返回状态
 **/
-(void) requestNeedLogin:(ALDHttpClient*)httpClient requestPath:(HttpRequestPath) requestPath withCode:(NSInteger) code{
    //跳转到登录界面
    [ALDUtils removeWaitingView:self.view];
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate loginOut];
    if (![BasicsLoginViewController isLoginViewShowing]) {
        [appDelegate showLogin];
    }
}

@end
