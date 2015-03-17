//
//  ViewDocViewController.m
//  hyt_pro
//  资料阅读
//  Created by yulong chen on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewDocViewController.h"
#import "Reachability.h"
#import "ALDAsyncDownloader.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface BaseViewDocViewController ()<AsyncDownloaderDelegate,UIAlertViewDelegate>
- (BOOL) IsEnableWIFI;
- (BOOL) IsEnable3G;
-(NSString *) captureSize:(long) size;
@property (retain,nonatomic) MPMoviePlayerController *moviePlayer;
@property (assign, nonatomic) UIDeviceOrientation nowOrientation;
@end

@implementation BaseViewDocViewController
@synthesize webView=_webView ;
@synthesize progressView = _progressView;
@synthesize progressText = _progressText;
@synthesize docUrl=_docUrl;
@synthesize docName=_docName;
@synthesize docSize=_docSize;

- (void)viewDidUnload
{
    [self removeObservers];
    _webView.delegate=nil;
    self.webView=nil;
    self.docUrl=nil;
    self.docName=nil;
    [self setProgressView:nil];
    [self setProgressText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)downloadData:(NSString *)htmlStr{
    [self hiddenTips];
    if (htmlStr) {
        htmlStr=[htmlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if(![htmlStr hasPrefix:@"http://"] && ![htmlStr hasPrefix:@"https://"]){
        htmlStr=[@"http://" stringByAppendingString:htmlStr];
    }
    self.progressText.hidden=YES;
    self.progressView.hidden=YES;
    
    ALDAsyncDownloader *downloader=[ALDAsyncDownloader asyncDownloader];
    NSURL *url=[NSURL URLWithString:htmlStr];
    NSString *path =[downloader getCachedForUrlPath:url];

    if(path!=nil){
        NSString *ext=[self getFileExt:path];
        if([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"MP4"] || [ext isEqualToString:@"3gp"] || [ext isEqualToString:@"m4v"]){
            NSURL *url=[NSURL fileURLWithPath:path];
            if(self.type == FinishStyleWithSave)
            {//只缓存不播放
                self.progressText.hidden = NO;
                self.progressText.text = @"下载完成";
                return;
            }
            if(!_moviePlayer){
                [self createMP];
            }
            _moviePlayer.contentURL=url;
            [_moviePlayer play];
        }else{
            NSURL *url = [NSURL fileURLWithPath:path];
            [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }else{
        [self.progressView setProgress:0.0f];

        [self showProgress];
        DownloadState state = [downloader downloadWithUrl:url delegate:self];
        if (state==DownloadStateWithLoading) {
            [self hiddenProgress];
            [ALDUtils addWaitingView:self.view withText:@"资料下载中，请稍候..."];
        }
    }
}

-(void)createMP
{
    _moviePlayer = [[MPMoviePlayerController alloc] init];
    [_moviePlayer.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame))];
    _moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    _moviePlayer.shouldAutoplay = NO;
    _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_moviePlayer.view];
}


-(NSString*) getFileExt:(NSString*) url{
    if (!url) {
        return nil;
    }
    NSArray *temp=[url componentsSeparatedByString:@"/"];
    if (temp && temp.count>0) {
        NSString *str=[temp objectAtIndex:(temp.count-1)];
        temp=[str componentsSeparatedByString:@"."];
        if (temp.count>1) {
            return [temp objectAtIndex:(temp.count-1)];
        }
    }
    return nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 101:{ //下载失败提示
            if (buttonIndex==0) { //取消重试
                [self hiddenProgress];
                [self onBackClicked];
            }else{ //重试
                [self downloadData:_docUrl];
            }
        }
            
        default:
            break;
    }
}

-(NSString *) captureSize:(long) size{
    if (size<1024) {
        return [NSString stringWithFormat:@"%ldB",size];
    }else if(size<1000*1000) {
        float kb=size/1000.f;
        return [NSString stringWithFormat:@"%.2fKB",kb];
    }else if (size<1000*1000*1000) {
        float m=1000.f*1000.f;
        float Mb=size/m;
        return [NSString stringWithFormat:@"%.2fMB",Mb];
    }else {
        float g=1000*1000*1000.f;
        float gb=size/g;
        return [NSString stringWithFormat:@"%.2fGB",gb];
    }
}

- (void)viewWillAppear:(BOOL)animated{
	if (self.hidesBottomBarWhenPushed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCustomTabBar" object:nil];
    }
    [self sizeToFitOrientation:[self currentOrientation]];
}

-(void) viewWillDisappear:(BOOL)animated{
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//        [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
//                                       withObject:(id)UIInterfaceOrientationPortrait];
//    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    backClicked=NO;
    ///////////
    if(!self.title || [self.title isEqualToString:@""]){
        self.title=@"加载中，请稍候...";
    }
    
    // Do any additional setup after loading the view from its nib.
    CGRect frame=self.view.frame;
    UIWebView *webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    webView.delegate=self;
    webView.backgroundColor=[UIColor whiteColor];
    webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    self.webView=webView;
    
    UIProgressView *progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(43, 174, 234, 2)];
    progressView.progress=0.0f;
    [self.view addSubview:progressView];
    self.progressView=progressView;
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(43, 174, 234, 21)];
    label.backgroundColor=[UIColor clearColor];
    [self.view addSubview:label];
    self.progressText=label;
    
    if(!_docUrl || [_docUrl isEqualToString:@""]){
        [self showTips:@"该资料不存在或已被删除"];
        self.webView.hidden=YES;
        return;
    }
    
    BOOL hasCache=NO;//[HttpClient hasCachedData:_docUrl];
    ALDAsyncDownloader *downloader=[ALDAsyncDownloader asyncDownloader];
    NSURL *url=[NSURL URLWithString:_docUrl];
    NSString *path =[downloader getCachedForUrlPath:url];
    if(path && ![path isEqualToString:@""]){
        hasCache=YES;
    }
    
    Reachability *r = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable: { // 没有网络连接
            [ALDUtils showAlert:@"温馨提示" strForMsg:@"你的网络未连接，请连接网络后再试." withTag:101 withDelegate:self otherButtonTitles:nil];
            return;
        }
            break;
            
        case ReachableViaWWAN:{// 使用3G网络
            if (_docSize>1024*500) { //大于500kb
                NSString *sizeText=[self captureSize:_docSize];
                NSString *text=[NSString stringWithFormat:@"你目前不是使用wifi网络,浏览文件:%@需耗费%@流量,您确定要浏览吗？",_docName,sizeText];
                [ALDUtils showAlert:@"温馨提示" strForMsg:text withTag:101 withDelegate:self otherButtonTitles:@"下载"];
                return;
            }
        }
            break;
            
        case ReachableViaWiFi:{// 使用WiFi网络
            
        }
            break;
        default:{
            
        }
            break;
    }

    [self downloadData:_docUrl];
    
    [self addObservers];
}

// 去掉UIWebView上下滚动出边界时的黑色阴影
- (void)clearWebViewBackgroundWithColor{
    for (UIView *view in [self.webView subviews]){
        if ([view isKindOfClass:[UIScrollView class]]){
            for (UIView *shadowView in view.subviews){
                // 上下滚动出边界时的黑色的图片 也就是拖拽后的上下阴影
                if ([shadowView isKindOfClass:[UIImageView class]]){
                    shadowView.hidden = YES;
                }
            }
        }
    }
}
/**
 * 当前请求是否有缓存
 * @param url 请求url
 * @return 如果有缓存，则直接返回该缓存文件路径
 **/
-(NSString*) hasCachedForUrl:(NSString *)name fileType:(NSString *)fileType
{
    NSFileManager *filemager = [NSFileManager defaultManager];
    NSString *path = [self getPathOfDocuments];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",name,fileType]];
    if([filemager fileExistsAtPath:path])
    {
        return path;
    }
    return nil;
}
-(NSString *)getPathOfDocuments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    return path;
}
-(void) showTips:(NSString *)text{
    self.progressText.hidden=YES;
    self.progressView.hidden=YES;
    if (!_textLabel || ![_textLabel isKindOfClass:[UILabel class]]) {
        if (UIInterfaceOrientationIsLandscape(previousOrientation))
        {
            _textLabel=[[UILabel alloc] initWithFrame:CGRectMake(90,  70, 300, 40)];
        }else {
            _textLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,  80, 300, 40)];
        }
        
        _textLabel.highlighted = YES;
        _textLabel.textColor=[UIColor blackColor];
        _textLabel.font=[UIFont boldSystemFontOfSize:14.0];
        _textLabel.textAlignment  = TEXT_ALIGN_CENTER;
        //textLabel.adjustsFontSizeToFitWidth =  YES ;
        _textLabel.numberOfLines = 0;
        _textLabel.backgroundColor=[UIColor clearColor];
        _textLabel.text=text;
        [self.view addSubview:_textLabel];
        //_textLabel.hidden=NO;
        _webView.hidden=YES;
    }else {
        _textLabel.text=text;
        _textLabel.hidden=NO;
        _webView.hidden=YES;
    }
}

-(void) hiddenTips{
    if (_textLabel) {
        _textLabel.hidden=YES;
    }
    _webView.hidden=NO;
}

-(void)back{
    @synchronized(self){ //防止点击过快而crash了
        if (backClicked) {
            return;
        }
        backClicked=YES;
    }
	[self.navigationController popViewControllerAnimated:YES];
}

- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
		return CGAffineTransformMakeRotation(-M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
		return CGAffineTransformMakeRotation(M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
		return CGAffineTransformMakeRotation(-M_PI);
	}
    else
    {
		return CGAffineTransformIdentity;
	}
}

- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation
{
    //[self.view setTransform:CGAffineTransformIdentity];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        // self.view.frame=CGRectMake(0, 0, 480, 320);
        if (_textLabel) {
            _textLabel.frame=CGRectMake(90,  70, 300, 40);
        }
        // _webView.frame=CGRectMake(0, 0, 480, 320);
        self.progressView.frame=CGRectMake(121, 131, 238, 9);
        self.progressText.frame=CGRectMake(121, 147, 238, 21);
    }else{
        self.view.frame=CGRectMake(0, 0, 320, 480);
        if (_textLabel) {
            _textLabel.frame=CGRectMake(10,  80, 300, 40);
        }
        self.webView.frame=CGRectMake(0, 0, 320, 480);
        self.progressView.frame=CGRectMake(43, 174, 234, 9);
        self.progressText.frame=CGRectMake(43, 188, 234, 21);
    }
    
    // [self.view setTransform:[self transformForOrientation:orientation]];
    
    previousOrientation = orientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}



//IOS6横屏需要的两个方法
- (BOOL)shouldAutorotate
{
    return YES;
//    return [[self.navigationController.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations
{
//    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
    return UIInterfaceOrientationMaskAll;

}


#pragma mark - UIWebViewDelegate
-(void) webViewDidStartLoad:(UIWebView *)webView{
    _progressText.text=@"文件已加载完成，正在解析.";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (!self.title || [self.title isEqualToString:@""]) {
        NSString *htmlTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if(htmlTitle && ![htmlTitle isEqualToString:@""]){
            self.title = htmlTitle;
        }else {
            self.title=@"详情";
        }
    }
	self.progressText.hidden=YES;
    self.progressView.hidden=YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self showTips:@"加载失败，请稍候再试..."];
    if (error) {
        NSLog(@"error:%@",error);
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //NSLog(@"shouldStartLoadWithRequest url:%@",request.URL.absoluteString);
    NSString *scheme=request.URL.scheme;
    NSString *rurl=request.URL.absoluteString;
    if([scheme isEqualToString:@"tel"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rurl]];
        return NO;
    }else if([scheme isEqualToString:@"sms"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rurl]];
        return NO;
    }else if([scheme isEqualToString:@"mailto"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rurl]];
        return NO;
    }else if ([scheme isEqualToString:@"http"]||[scheme isEqualToString:@"https"]) {
        
    }
    return YES;
}

/*
 *判断是否通过wifi
 */
- (BOOL) IsEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

/*
 *判断是否通过3G
 */
- (BOOL) IsEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}
/*
- (void)setProgress:(float)progress{
    [_progressView setProgress:progress];
    float bfb=progress*100;
    NSString *text=[NSString stringWithFormat:@"正在加载文件,已完成%0.1f",bfb];
    text=[text stringByAppendingString:@"%"];
    _progressText.text=text;
}

- (void)setProgress:(float)progress animated:(BOOL)animated{
    [_progressView setProgress:progress animated:animated];
    float bfb=progress*100;
    NSString *text=[NSString stringWithFormat:@"正在加载文件,已完成%0.1f",bfb];
    text=[text stringByAppendingString:@"%"];
    _progressText.text=text;
}*/
-(void) showProgress{
    self.progressView.hidden=NO;
    self.progressText.hidden=NO;
}

-(void) hiddenProgress{
    self.progressView.hidden=YES;
    self.progressText.hidden=YES;
    [ALDUtils removeWaitingView:self.view];
}

#pragma mark AsyncDownloaderDelegate methods
-(void) request:(ASIHTTPRequest*)request downloadedFailed:(NSError *) error{
    NSLog(@"error:%@",error);
    if (!backClicked) {
        [ALDUtils showAlert:@"错误提示" strForMsg:@"抱歉，资料下载失败，是否重试？" withTag:101 withDelegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重试"];
    }
}

-(void) request:(ASIHTTPRequest*)request downloadedFinish:(NSString *) localPath{
    [self hiddenProgress];
    if (backClicked) {
        return;
    }
    [self downloadData:_docUrl];
}
-(void) setProgress:(float)progress animated:(BOOL)animated
{
    self.progressText.hidden=NO;
    self.progressView.hidden=NO;
    [self.progressView setProgress:progress animated:animated];
    float bfb=progress*100;
    NSString *text=[NSString stringWithFormat:@"正在加载文件,已完成%0.1f",bfb];
    text=[text stringByAppendingString:@"%"];
    self.progressText.text=text;
}
- (void)setProgress:(float)progress{
    self.progressText.hidden=NO;
    self.progressView.hidden=NO;
    [self.progressView setProgress:progress];
    float bfb=progress*100;
    NSString *text=[NSString stringWithFormat:@"正在加载文件,已完成%0.1f",bfb];
    text=[text stringByAppendingString:@"%"];
    _progressText.text=text;
}
#pragma mark AsyncDownloaderDelegate end


-(void)onBackClicked{
    @synchronized(self){ //防止点击过快而crash了
        if (backClicked) {
            return;
        }
        backClicked=YES;
    }
    
    if (self.hidesBottomBarWhenPushed) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"bringCustomTabBarToFront" object:nil];
	}
    self.navigationController.navigationBarHidden=NO;
	[self.navigationController popViewControllerAnimated:YES];
}


-(void) dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    //[ALDUtils addWaitingView:self.view withText:@""];
    [self.progressView setProgress:0.0f];
    self.progressView.hidden=NO;
}

-(void) dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if (requestPath==HttpRequestPathForDownload) {
        //_progressView.hidden=YES;
        if (code==KOK) {
            NSString *path=(NSString*)result;
            NSURL *url = [NSURL fileURLWithPath:path];
            [_webView loadRequest:[NSURLRequest requestWithURL:url]];
        }else if (code==kNO_RESULT) {
            [self showTips:@"该课程资料不存在或已被删除"];
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT) {
            [self showTips:@"你的网络很不给力，请连接后重试!"];
        }else {
            [self showTips:@"加载该课程资料失败,请稍候再试..."];
        }
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
	UIInterfaceOrientation orientation = [self currentOrientation];
	if ([self shouldAutorotateToInterfaceOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)doRotate:(NSNotification *)notification
{
    if(_moviePlayer.fullscreen){
        UIApplication *myApp=[UIApplication sharedApplication];
        if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationPortrait)
        {
            [myApp setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
        }
        else if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationPortraitUpsideDown)
        {
            [myApp setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown animated:YES];
        }
        else if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeRight)
        {
            [myApp setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
        }
        else if ([[UIDevice currentDevice] orientation]==UIDeviceOrientationLandscapeLeft)
        {
            [myApp setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
        }
    }
}

-(void)dealloc
{
    [self removeObservers];
    _webView.delegate=nil;
    self.webView=nil;
    self.docUrl=nil;
    self.docName=nil;
    [self setProgressView:nil];
    [self setProgressText:nil];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}


@end
