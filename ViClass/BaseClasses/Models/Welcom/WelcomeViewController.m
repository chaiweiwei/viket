//
//  WelcomeViewController.m
//  TZAPP
//  欢迎界面
//  Created by alidao on 14-9-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ALDImageView.h"

@interface WelcomeViewController ()<UIScrollViewDelegate>{
//    BOOL direction;
    BOOL _notified;
}

@property (retain,nonatomic) UIPageControl *pageControl;
@property (retain,nonatomic) UIScrollView *imagesScroll;
@property (assign,nonatomic) NSInteger pageCount;
@property (retain,nonatomic) NSTimer *showTimer;

-(void)clickBtn:(ALDImageView *)sender;

@end

@implementation WelcomeViewController

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
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    
    if (!self.welcomeImages || self.welcomeImages.count<1) {
        NSString *imageName=nil;
        UIImage *bgImage=nil;
        if (frame.size.height>480) {
            imageName=@"Default-568h@2x";
            bgImage=[UIImage imageNamed:imageName];
        }
        if (bgImage==nil) {
            imageName=@"Default";
        }
        self.welcomeImages=[NSArray arrayWithObject:imageName];
    }
    
    int count=self.welcomeImages.count;
    self.pageCount=count;
    
    if (self.autoScroll==nil) {
        if (count>1) {
            self.autoScroll=[NSNumber numberWithBool:NO];
        }else{
            self.autoScroll=[NSNumber numberWithBool:YES];
        }
    }
    _notified=NO;
    if (self.onePageTimes<=0) {
        self.onePageTimes=2; //默认2s
    }
    
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh)];
    scrollView.delegate=self;
    scrollView.contentSize=CGSizeMake(count*viewWidth, 0);
    scrollView.pagingEnabled=YES;
    [self.view addSubview:scrollView];
    self.imagesScroll=scrollView;
    
    UIPageControl *pageControl=[[UIPageControl alloc] initWithFrame:CGRectMake((viewWidth-40)/2, viewHeigh-50, 40, 36)];
    pageControl.numberOfPages = count ;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor=[UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor=KGreenColor;
    
    [self.view addSubview:pageControl];
    self.pageControl=pageControl;
    
    for(int i=0;i<count;i++){
        CGFloat startX=i*viewWidth;
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(startX, 0, viewWidth, viewHeigh)];
        ALDImageView *imgView=[[ALDImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh)];
        UIImage *image=[UIImage imageNamed:[self.welcomeImages objectAtIndex:i]];
        imgView.image=image;
        imgView.backgroundColor=[UIColor clearColor];
        if(i==count-1){
            imgView.clickAble=YES;
            [imgView addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        }
        [view addSubview:imgView];
        [scrollView addSubview:view];
    }
    if (count<=1) {
        self.pageControl.hidden=YES;
    }
    
    if (self.autoScroll!=nil && [self.autoScroll boolValue]) {
        [self performSelector:@selector(start) withObject:nil afterDelay:self.onePageTimes];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.view.frame.size.width;
    CGFloat contentOffsetX=scrollView.contentOffset.x;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage=page;
    if(contentOffsetX>(self.pageCount-1)*pageWidth){
        [self stop];
        [self welcomeDone];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /*
    CGFloat pageWidth = self.view.frame.size.width;
    CGFloat contentOffsetX=scrollView.contentOffset.x;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage=page;
    if(contentOffsetX>(self.pageCount-1)*pageWidth){
        [self stop];
        [self welcomeDone];
    }*/
}

/**
 * 开始变换
 */
-(void) start{
    [self stop];
    if(_pageCount<1){
        return ;
    }
    //定时器
    self.showTimer = [NSTimer scheduledTimerWithTimeInterval:self.onePageTimes target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
    [self.showTimer fire];
}

/**
 * 停止
 */
-(void) stop{
    if (self.showTimer) {
        [self.showTimer invalidate];
        self.showTimer=nil;
    }
}

-(void) welcomeDone{
    //调用委托方法
    @synchronized(self){
        if (_notified) {
            return;
        }
        _notified=YES;
    }
    if (self.delegate) {
        [self.delegate onWelcomeLoadDone:self];
    }
}

-(void)clickBtn:(ALDImageView *)sender
{
    [self welcomeDone];
}

- (void)scrollToNextPage:(id)sender { //切换到下一张
    int page = _pageControl.currentPage;
    if (page >= _pageCount - 1) {
        [self stop];
        [self welcomeDone];
        return;
    }
    page++;
    CGFloat x = self.imagesScroll.frame.size.width * page;
    CGFloat y = 0;
    _pageControl.currentPage=page;
    CGPoint point=CGPointMake(x, y);
    [self.imagesScroll setContentOffset:point animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self stop];
    self.pageControl=nil;
    self.imagesScroll=nil;
    self.welcomeImages=nil;
    self.autoScroll=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
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

@end
