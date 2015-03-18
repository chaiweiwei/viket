//
//  DetailViewController.m
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/9.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "ShowViewController.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "ALDImageView.h"
#import "ALDButton.h"
#import "MJRefresh.h"
#import "StartView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PlayViewController.h"
#import "BaseViewDocViewController.h"
#import <Reachability.h>
#import "HttpClient.h"
#import "ChapterBean.h"
#import "ALDAsyncDownloader.h"
#import "ResultStatusBean.h"
#import "FeedBackViewController.h"
#import <ShareSDK/ShareSDK.h>

#define TAG_BTN_STAR 0x12
#define TAG_BTN_START 0x13
#define TAG_BTN_FEEK 0x16
#define TAG_BTN_SHARE  0x17

#define TAG_LABEL_COLLECTION 0x14
#define TAG_LABEL_COMMENTCOUNR  0x15

@interface ShowViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,StartViewDelegate> {
    UIButton *_sendBtn; //NO Retain
    int pageCount;         //列表行数
    BOOL hasNext; //是否还有下拉数据
    CGFloat bottomY;
    CGFloat currentHeigh;
}
@property (nonatomic,strong) UIView *filterView;
@property (nonatomic, retain) UITableView *pullTableView;//列表
//@property (nonatomic, strong) PlayViewController *moviePlayer;

@property (nonatomic,retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic,retain) ALDButton *playBtn; //播放按钮
@property (nonatomic,retain) NSString *movieURL;
@property (nonatomic,retain) ChapterBean *cbean;

@property (nonatomic,retain) NSNumber *pageTag;
@property (nonatomic)         BOOL                     bRefreshing;      //是否刷新
@property (nonatomic,retain) UIView *bottomView;

@end
@implementation ShowViewController

-(void)viewDidLoad
{
    pageCount=5;
    hasNext=NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayState:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinish:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    //监测网络状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [self initUI];
    [self loadData];
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        [self setFitsrImage];
//    });

}
-(void)setFitsrImage
{
    AttachmentBean *at = _cbean.attachments[0];
    NSString *text= at.url ? at.url:@"";
    
    self.movieURL=text;
    UIImage *firstFrameImg=nil; //第一帧图片
    ALDImageView *imgView = (ALDImageView *)[self.HeadView viewWithTag:0x1001];
    
    if(text && ![text isEqualToString:@""]){
        NSURL *url=[NSURL URLWithString:text];
        firstFrameImg=[self thumbnailImageForVideo:url atTime:0];
        imgView.image=firstFrameImg;
    }
}
-(void)initUI
{
    
    CGRect frame       = self.view.frame;
    CGFloat viewWidth  = CGRectGetWidth(frame);
    CGFloat viewHeight = CGRectGetHeight(frame);

    self.view.backgroundColor = [UIColor whiteColor];
    
    _pullTableView                  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight-49)];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.sectionHeaderHeight = 10;
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_pullTableView];

    [self setupRefresh];
    
    if (self.toController == 1) {
        //自定义导航栏
        UINavigationBar *bar=[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 64)];
        
        UINavigationItem *item=[[UINavigationItem alloc] initWithTitle:@"章节详情"];
        
        [bar pushNavigationItem:item animated:YES]; //把导航条推入到导航栏
        
        [self.view addSubview:bar]; //添加导航条视图
        
        //返回按钮
        UIBarButtonItem *left=[[UIBarButtonItem alloc] initWithTitle:@"课表" style:UIBarButtonItemStyleDone target:self action:@selector(cancelBtn)];
        [item setLeftBarButtonItem:left animated:YES];
        //改变高
        CGRect frame = _pullTableView.frame;
        frame.origin.y = 64;
        
        _pullTableView.frame = frame;

    }
    bottomY = viewHeight - 49.f;
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, viewHeight - 49.f, viewWidth, 49.f)];
    _bottomView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_bottomView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 0.5)];
    line.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    [_bottomView addSubview:line];
    
    _commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(37, 7.5f, viewWidth - 47, 34)];
    _commentTextView.delegate = self;
    _commentTextView.backgroundColor = [UIColor whiteColor];
    _commentTextView.textColor = KWordGrayColor;
    _commentTextView.font = kFontSize30px;
    _commentTextView.layer.masksToBounds = YES;
    _commentTextView.layer.cornerRadius = 17;
    _commentTextView.layer.borderColor = KWordBlackColor.CGColor;
    _commentTextView.layer.borderWidth = 0.5;
    _commentTextView.returnKeyType = UIReturnKeySend;
    [_bottomView addSubview:_commentTextView];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 8.5,32 , 32)];
    icon.image = [UIImage imageNamed:@"ooopic_1424102692"];
    [_bottomView addSubview:icon];
    
//    //发送
//    UIButton *sendBt =[UIButton buttonWithType:UIButtonTypeCustom];
//    sendBt.frame = CGRectMake(_commentTextView.right, 4.5f, 40, 40);
//    _sendBtn=sendBt;
//    [sendBt setTitle:ALDLocalizedString(@"Send", @"发送") forState:UIControlStateNormal];
//    sendBt.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    sendBt.backgroundColor = [UIColor blueColor];
//    [sendBt addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
//    //    [sendBt setBackgroundImage:[UIImage imageNamed:@"btn_chat_send"] forState:UIControlStateNormal];
//    [sendBt setTitleColor:RGBCOLOR(237, 34, 34) forState:UIControlStateNormal];
//    
//    [_bottomView addSubview:sendBt];
    
    //----------TableView HeadView---------
    UIView *HeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 160+49+40)];
    HeadView.backgroundColor = [UIColor clearColor];
    self.HeadView = HeadView;
    self.pullTableView.tableHeaderView = HeadView;
    
    //背景图片
    ALDImageView *remindImageView = [[ALDImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 160+49)];
    remindImageView.image = [UIImage imageNamed:@"bg_vshuo"];
    remindImageView.backgroundColor = [UIColor clearColor];
    [HeadView addSubview:remindImageView];

    AttachmentBean *at = _cbean.attachments[0];
    NSString *text= at.url ? at.url:@"";
    self.movieURL=[self chineseToUTf8Str:text];

    //视频
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    if(self.movieURL && ![self.movieURL isEqualToString:@""]){
        NSURL *url=[NSURL URLWithString:self.movieURL];
        [_moviePlayer setContentURL:url];
    }
    [_moviePlayer.view setFrame:CGRectMake(0, 0, viewWidth, 160.0f)];
    _moviePlayer.shouldAutoplay=NO;
    _moviePlayer.repeatMode = MPMovieRepeatModeOne;
    _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [HeadView addSubview:_moviePlayer.view];
    
    //播放按钮
    UIImage *playImg=nil;
    CGFloat playHeigh=50.0f;
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake((viewWidth-playHeigh)/2, (160-playHeigh)/2, playHeigh, playHeigh);
    
    ALDImageView *imgView=[[ALDImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 160.0f)];
    imgView.tag=0x1001;
    playImg=[UIImage imageNamed:@"icon_palySmall"];
    imgView.defaultImage=[UIImage imageNamed:@"default_adver"];
    imgView.imageUrl=_cbean.logo;
    playImg=[UIImage imageNamed:@"icon_palySmall"];
    
//    if(text && ![text isEqualToString:@""]){
//            NSURL *url=[NSURL URLWithString:text];
//            firstFrameImg=[self thumbnailImageForVideo:url atTime:0];
//            imgView.image=firstFrameImg;
//            playImg=[UIImage imageNamed:@"icon_palySmall"];
//        }else{
//            playImg=[UIImage imageNamed:@"icon_pauseSmall"];
//            btn.userInteractionEnabled=NO;
//        }

    [HeadView addSubview:imgView];
    
    [btn setBackgroundImage:playImg forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor clearColor];
    btn.selectBgColor=[UIColor clearColor];
    btn.tag=TAG_BTN_START;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [HeadView addSubview:btn];
    self.playBtn=btn;

    CGFloat btnWidth = viewWidth/4.f;
    //我也想说
    ALDButton *btnView = [self createView:CGRectMake(0, 160, btnWidth, 49) tag:0x1001];
    [HeadView addSubview:btnView];
    
    UILabel *title = [self createBtnLabel:btnView.frame title:@"收藏"];
    title.tag = TAG_LABEL_COLLECTION;
    if(_cbean.favoriteFlag)
        title.text = @"已收藏";
    [HeadView addSubview:title];
    
    //导师点评
    btnView = [self createView:CGRectMake(btnWidth, 160, btnWidth, 49) tag:0x1002];
    btnView.tag = TAG_BTN_SHARE;
    [HeadView addSubview:btnView];
    
    title = [self createBtnLabel:btnView.frame title:@"分享"];
    [HeadView addSubview:title];
    
    //评分
    btnView = [self createView:CGRectMake(btnWidth*2, 160, btnWidth, 49) tag:0x1003];
    btnView.tag = TAG_BTN_STAR;
    [HeadView addSubview:btnView];
    
    title = [self createBtnLabel:btnView.frame title:@"评分"];
    [HeadView addSubview:title];

    
    //赞
    btnView = [self createView:CGRectMake(btnWidth*3, 160, btnWidth, 49) tag:0x1004];
    btnView.tag = TAG_BTN_FEEK;
    [HeadView addSubview:btnView];
    
    title = [self createBtnLabel:btnView.frame title:@"反馈"];
    [HeadView addSubview:title];

    
    for (NSInteger j = 0; j<3; j++) {
        CGFloat statX = btnWidth * (j + 1) - 0.5f;
        UIView *line = [self crecteLine:CGRectMake(statX, 160, 1, 49)];
        [remindImageView addSubview:line];
    }
    
    //评论数
    UIView *comView = [self createLine:CGRectMake(0, 209, viewWidth, 40)];
    comView.backgroundColor = RGBCOLOR(246, 246, 246);
    comView.tag = TAG_LABEL_COMMENTCOUNR;
    [self.HeadView addSubview:comView];
    
    line = [self createLine:CGRectMake(0, 0, viewWidth, 0.5f)];
    line.backgroundColor = kLineColor;
    [comView addSubview:line];
    
    line = [self createLine:CGRectMake(0, 39.5f, viewWidth, 0.5f)];
    line.backgroundColor = kLineColor;
    [comView addSubview:line];
    
    UILabel *comLabel = [self createLabel:CGRectMake(10, 0, viewWidth-20, 40) title:@"评论" textColor:KWordBlackColor textFont:kFontSize34px];
    comLabel.tag = 0x16;
    comLabel.textAlignment = TEXT_ALIGN_LEFT;
    [comView addSubview:comLabel];
    
    if(_cbean.commentCount>0)
        text = [NSString stringWithFormat:@"评论 %i",_cbean.commentCount];
    else
        text = @"评论";
    comLabel.text = text;
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self queryCommentList];
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self changeSubFrame];
}
//-(void)textViewDidEndEditing:(UITextView *)textView
//{
//    
//}
//-(BOOL)textViewShouldEndEditing:(UITextView *)textView
//{
//    if([textView.text isEqualToString:@"评论"])
//        textView.text = @"";
//    NSString * str = textView.text; //得到输入框的内容
//    if ([str length] >=254) { //输入框内容不能大于254
//        [ALDUtils showToast:@"回帖内容不能超过254个字!"];
//        return NO;
//    }
//   else{
//        [textView resignFirstResponder];
//        [self sendComment];
//        return NO;
//    }
//    
//    return YES;
//}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([textView.text isEqualToString:@"评论"])
        textView.text = @"";
    NSString * str = textView.text; //得到输入框的内容
    if ([str length] >=254) { //输入框内容不能大于254
        [ALDUtils showToast:@"回帖内容不能超过254个字!"];
        return NO;
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self sendComment];
        return NO;
    }
    
    return YES;
}
-(void)changeSubFrame
{
    NSString *text=self.commentTextView.text;
    if(text && ![text isEqualToString:@""]){
        CGFloat subWidth=self.commentTextView.frame.size.width;
        CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:subWidth font:self.commentTextView.font];
        CGRect subFrame=self.commentTextView.frame;
        if(size.height>34){
            if(size.height>=100){
                size.height=100;
            }
            subFrame.size.height=size.height;
            self.commentTextView.frame=subFrame;
            
            CGFloat heigh=size.height-34;
            subFrame=self.commentTextView.frame;
            
            subFrame.origin.y=(bottomY-heigh);
            currentHeigh=heigh;
            subFrame.size.height=KBottomHeight+heigh;
            subFrame.origin.x = 0;
            self.bottomView.frame=subFrame;
            
            subFrame=self.pullTableView.frame;
            subFrame.size.height=CGRectGetHeight(self.view.frame)-(KBottomHeight+heigh);
            self.pullTableView.frame=subFrame;
        }else
        {
            CGFloat viewWidth = CGRectGetWidth(self.view.frame);
            CGFloat viewHeight = CGRectGetHeight(self.view.frame);
            
            self.commentTextView.frame=CGRectMake(37, 7.5f, viewWidth - 47, 34);
            
            
            self.bottomView.frame=CGRectMake(0.0f, viewHeight - 49.f, viewWidth, 49.f);
            
            self.pullTableView.frame=CGRectMake(0, 0, viewWidth, viewHeight-49);

        }
    }
}
//底部视图默认的frame
-(void)setDefaultFrame
{
    CGRect subFrame=self.bottomView.frame;
    CGFloat viewHeigh=CGRectGetHeight(self.view.frame);
    CGFloat startY=viewHeigh-49;
    subFrame.origin.y=startY;
    subFrame.size.height=49;
    self.bottomView.frame=subFrame;
    
    subFrame=self.commentTextView.frame;
    subFrame.size.height=34;
    self.commentTextView.frame=subFrame;
    
    subFrame=self.pullTableView.frame;
    subFrame.size.height=viewHeigh-49;
    self.pullTableView.frame=subFrame;
}

#pragma mark - LoadDataFromNet
- (void)queryCommentList
{
    BasicsHttpClient *http = [BasicsHttpClient httpClientWithDelegate:self];
    http.needTipsNetError = YES;
    [http commentList:5 sourceId:self.chapterId pagetag:self.pageTag pageCount:pageCount];
}
/**
 * 发表评论
 **/
-(void)sendComment
{
    NSString *text =_commentTextView.text;
    //发送 文本
    CommentBean *bean  = [[CommentBean alloc] init];
    bean.type = [NSNumber numberWithInt:5];
    bean.sourceId = self.chapterId;
    bean.content = text;
    bean.createTime=[ALDUtils getFormatDate:@"yyyy-MM-dd HH:mm:ss"];
    
    BasicsHttpClient *httpClient = [BasicsHttpClient httpClientWithDelegate:self];
    [httpClient commentSend:bean];
}

-(NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    chineseStr = [chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return chineseStr;
}
-(void)clicked:(UIButton *)sender
{
    switch (sender.tag) {
        case TAG_BTN_SHARE:
        {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"png"];
            //构造分享内容
            id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                               defaultContent:@"测试一下"
                                                        image:[ShareSDK imageWithPath:imagePath]
                                                        title:@"ShareSDK"
                                                          url:@"http://www.mob.com"
                                                  description:@"这是一条测试信息"
                                                    mediaType:SSPublishContentMediaTypeNews];
            //创建弹出菜单容器
            id<ISSContainer> container = [ShareSDK container];
            [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
            
            //弹出分享菜单
            [ShareSDK showShareActionSheet:container
                                 shareList:nil
                                   content:publishContent
                             statusBarTips:YES
                               authOptions:nil
                              shareOptions:nil
                                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                        
                                        if (state == SSResponseStateSuccess)
                                        {
                                            NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                            [ALDUtils showToast:@"分享成功"];
                                        }
                                        else if (state == SSResponseStateFail)
                                        {
                                            NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                        }
                                    }];
        }
            break;
        case TAG_BTN_FEEK:
        {
            FeedBackViewController *controller = [[FeedBackViewController alloc] init];
            controller.title = @"反馈";
            controller.type = 2;
            controller.sourceId = _cbean.sid;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 0x1001://收藏
        {

            HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
            if (_cbean.favoriteFlag) {
                [httpClient dataFavoriteOpt:[NSArray arrayWithObject:self.chapterId] type:5 opt:-1];
            }
            else
                [httpClient dataFavoriteOpt:[NSArray arrayWithObject:self.chapterId] type:5 opt:1];
            
        }
            break;
        case TAG_BTN_STAR://评分
        {
            StartView *startView = [[StartView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
            startView.delegate = self;
            [startView show];
            
        }
            break;
        case TAG_BTN_START://播放
        {
            AttachmentBean *at = _cbean.attachments[0];
            
            ALDAsyncDownloader *downloader=[ALDAsyncDownloader asyncDownloader];
            NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str:at.url]];
            NSString *path =[downloader getCachedForUrlPath:url];
            NSString *ext=[self getFileExt:at.url];
            
            if(path!=nil){
                
                if([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"MP4"] || [ext isEqualToString:@"3gp"] || [ext isEqualToString:@"m4v"]){
                    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                    
                    _moviePlayer.contentURL=url;
                    [_moviePlayer play];
                    
                    UIImageView *imgView=(UIImageView *)[self.HeadView viewWithTag:0x1001];
                    if(imgView){
                        [imgView removeFromSuperview];
                        imgView=nil;
                    }
                    _moviePlayer.controlStyle=MPMovieControlStyleFullscreen;
                    [_moviePlayer setFullscreen:YES animated:YES];
                    
//                    //设置横屏
//                    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
//                    // Rotate the view for landscape playback
//                    [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
//                    [[self view] setCenter:CGPointMake(160, 240)];
//                    //选中当前view
//                    [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
//                    
//                    // Set frame of movieplayer
//                    [[self.moviePlayer view] setFrame:CGRectMake(0, 0, 480, 320)];
//                    
//                    // Add movie player as subview
//                    [[self view] addSubview:[self.moviePlayer view]];
                }
            }
            else {
                if([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"MP4"] || [ext isEqualToString:@"3gp"] || [ext isEqualToString:@"m4v"]){
                    Reachability *r = [Reachability reachabilityWithHostname:@"www.baidu.com"];
                    switch ([r currentReachabilityStatus]) {
                        case NotReachable: { // 没有网络连接
                            [ALDUtils showAlert:@"温馨提示" strForMsg:@"网络异常，请稍后重试!" withTag:103 withDelegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        }
                            break;
                            
                        case ReachableViaWWAN:{// 使用3G网络
                            BOOL isAgree=[[NSUserDefaults standardUserDefaults] boolForKey:@"agreeViaWWAN"];
                            if(isAgree){
                                [ALDUtils showToast:@"您正在使用2G/3G网络!"];
                                [_moviePlayer play];
                            }else{
                                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"温馨提示!" message:@"您现在使用的是运营商网络,继续观看可能产生超额流量费" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
                                alertView.tag=0x10001;
                                [alertView show];
                            }
                        }
                            break;
                            
                        case ReachableViaWiFi:{// 使用WiFi网络
                            //[_moviePlayer setContentURL:[NSURL URLWithString:@"http://test.yuzhuohui.info/originalVideoForWeiweiTest.mp4"]];
                            [_moviePlayer play];
                        }
                            break;
                        default:{
                            
                        }
                            break;
                    }
                    
                    UIImageView *imgView=(UIImageView *)[self.HeadView viewWithTag:0x1001];
                    if(imgView){
                        [imgView removeFromSuperview];
                        imgView=nil;
                    }
                    _moviePlayer.controlStyle=MPMovieControlStyleFullscreen;
                    [_moviePlayer setFullscreen:YES animated:YES];
                    
//                    //设置横屏
//                    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
//                    // Rotate the view for landscape playback
//                    [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
//                    [[self view] setCenter:CGPointMake(160, 240)];
//                    //选中当前view
//                    [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
//    
//                    // Set frame of movieplayer
//                    [[self.moviePlayer view] setFrame:CGRectMake(0, 0, 480, 320)];
//    
//                    // Add movie player as subview
                   // [[self view] addSubview:[self.moviePlayer view]];
                    
                }else{
                    if([ext isEqualToString:@""]){
                        NSString *message=@"抱歉,该视频无法播放!";
                        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                        
                    }else{
                        NSString *message=[NSString stringWithFormat:@"抱歉,暂不支持%@视频文件的播放!",ext];
                        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }
            }

        }
            break;
        default:
            break;
    }
}
-(void)btnOKCallBack:(int)score
{
    //保存信息
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient sendScore:self.chapterId type:5 score:score];
}
//视频播放状态改变
-(void)moviePlayState:(NSNotification *)notification
{
    if(_moviePlayer.playbackState==MPMoviePlaybackStatePlaying){
        self.playBtn.hidden=YES;
    }
}
//done
-(void)movieFinish:(NSNotification *)notification
{
    _moviePlayer.controlStyle=MPMovieControlStyleNone;
    self.playBtn.hidden=NO;
}
-(BOOL)shouldAutorotate{
    return YES;
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

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)reachabilityChanged:(NSNotification *)notification
{
    Reachability* curReach = [notification object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (status == NotReachable){
        
    }else if(status==ReachableViaWiFi){
        
    }else if(status==ReachableViaWWAN){
        BOOL isAgree=[[NSUserDefaults standardUserDefaults] boolForKey:@"agreeViaWWAN"];
        if(isAgree){
            [ALDUtils showToast:@"您正在使用2G/3G网络!"];
        }else{
            if(_moviePlayer.playbackState!=MPMoviePlaybackStateStopped){
                [_moviePlayer pause];
                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"温馨提示!" message:@"您现在使用的是运营商网络,继续观看可能产生超额流量费" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续观看", nil];
                alertView.tag=0x10001;
                [alertView show];
            }
        }
    }
}
//获取视频某帧图片
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

-(void)cancelBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)loadData {
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getChapterDetail:self.chapterId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commentData.count;
}

#pragma mark - TableViewDataSource, TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellID];
    
    CGRect frame      = self.view.frame;
    CGFloat viewWidth = CGRectGetWidth(frame);
    CGFloat startX = 10;
    CGFloat startY = 10;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellID];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        ALDImageView *icon = [[ALDImageView alloc] initWithFrame:CGRectMake(startX, startY, 50, 50)];
        icon.defaultImage = [UIImage imageNamed:@"pic_photo"];
        icon.imageUrl = @"";
        icon.autoResize = NO;
        icon.fitImageToSize = NO;
        icon.layer.cornerRadius = 50/2.f;
        icon.layer.masksToBounds = YES;
        icon.backgroundColor=[UIColor clearColor];
        icon.tag = 0x1004;
        [cell addSubview:icon];
        
        //名称
        UILabel *name = [self createLabel:CGRectMake(icon.right+startX, 2*startY, 160, 15) title:@"MilkCocoa" textColor:KWordBlackColor textFont:kFontSize34px];
        name.tag = 0x1001;
        [cell addSubview:name];
        
        //评论内容
        UILabel *content = [self createLabel:CGRectMake(name.left, name.bottom+8, viewWidth-name.left-startX, 15) title:@"3天前23万播放3天前23万播放3天前" textColor:RGBCOLOR(142, 142, 142) textFont:kFontSize30px];
        content.numberOfLines = 0;
        content.tag = 0x1002;
        [cell addSubview:content];
        
        //时间
        UILabel *time = [self createLabel:CGRectMake(viewWidth-60-10, 2*startY, 60, 15) title:@"18分钟前" textColor:RGBCOLOR(142, 142, 142) textFont:kFontSize24px];
        time.textAlignment = TEXT_ALIGN_Right;
        time.tag = 0x1003;
        [cell addSubview:time];
        
        UIView *line = [self createLine:CGRectMake(name.left, content.bottom+9.5f, viewWidth-name.left, 0.5f)];
        line.tag = 0x1005;
        [cell addSubview:line];
    }
    CommentBean *bean = _commentData[indexPath.row];
    
    ALDImageView *icon = (ALDImageView *)[cell viewWithTag:0x1004];
    icon.imageUrl = bean.avatar;
    
    UILabel *name = (UILabel *)[cell viewWithTag:0x1001];
    name.text = bean.name;
    
    CGSize size = [ALDUtils captureTextSizeWithText:bean.content textWidth:viewWidth-80 font:kFontSize30px];
    UILabel *content = (UILabel *)[cell viewWithTag:0x1002];
    content.text = bean.content;
    CGRect rect = content.frame;
    rect.size.height = size.height;
    content.frame = rect;
    
    NSString *text=[ALDUtils delRealTimeData:bean.createTime];
    text=text==nil?@"":text;
    UILabel *time = (UILabel *)[cell viewWithTag:0x1003];
    time.text = text;
    
    size = [ALDUtils captureTextSizeWithText:text textWidth:200 font:kFontSize24px];
    rect = time.frame;
    rect.origin.x = viewWidth -size.width-10;
    rect.size.width = size.width;
    time.frame = rect;
    
    UIView *line = (UIView *)[cell viewWithTag:0x1005];
    rect = line.frame;
    rect.origin.y = content.bottom+9.5f;
    line.frame = rect;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentBean *bean = _commentData[indexPath.row];
    
    CGSize size = [ALDUtils captureTextSizeWithText:bean.content textWidth:CGRectGetWidth(self.view.frame)-80 font:kFontSize30px];
    if(size.width>15)
        return 75+size.height-15;
    return 75;
}

- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.view.backgroundColor;
    
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    NSLog(@"%f",self.view.frame.size.height);
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height-64;
    
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
        
    }];
    
    
}
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.pullTableView addFooterWithTarget:self action:@selector(getMore)];
    [self.pullTableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    self.pullTableView.headerRefreshingText = @"下拉刷新";
    self.pullTableView.headerReleaseToRefreshText = @"释放加载最新";
    self.pullTableView.headerRefreshingText =@"正在加载";
    self.pullTableView.footerPullToRefreshText = @"上拉加载更多";
    self.pullTableView.footerReleaseToRefreshText = @"释放加载更多";
    self.pullTableView.footerRefreshingText = @"正在加载";
}
-(void)headerRereshing
{
    [self refrashClick];
}

-(void)footerRereshing
{
    [self getMore];
}
- (void)refrashClick
{
    hasNext = NO;
    self.pageTag=nil;
    [self queryCommentList];
}

- (void)getMore
{
    if (hasNext)
    {
        if(self.commentData && self.commentData.count>0){
            CommentBean *bean=[self.commentData lastObject];
            self.pageTag=bean.pagetag;
        }
        [self queryCommentList];
    }
    else
        [_pullTableView footerEndRefreshing];
}

-(UILabel *)createLabel:(CGRect )frame title:(NSString *)title textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.text = title;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}
-(UIButton *) createButton:(CGRect) frame{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    button.titleLabel.font=[UIFont boldSystemFontOfSize:13.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [button.layer setBorderWidth:0];
    button.layer.cornerRadius =0;
    [button setBackgroundColor:[UIColor clearColor]];
    
    return button;
}

-(ALDButton *)createView:(CGRect)rect tag:(int)tag
{
    ALDButton *btn       = [ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame           = rect;
    btn.backgroundColor = RGBCOLOR(0, 0, 0);
    btn.alpha           = 0.2;
    btn.tag             = tag;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
    
}
-(UILabel *)createBtnLabel:(CGRect )frame title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.layer.shadowColor = KWordBlackColor.CGColor;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowRadius = 1.0;
    label.layer.shadowOpacity = 0.8;
    label.textColor = KWordWhiteColor;
    label.textAlignment = TEXT_ALIGN_CENTER;
    label.text = title;
    
    return label;

}
-(UILabel *)createLabel:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}

-(UIView *)crecteLine:(CGRect)rect
{
    UIView *line =[[UIView alloc] initWithFrame:rect];
    line.backgroundColor = KWordWhiteColor;
    line.alpha = 0.3;
    return line;
}

-(UIView *)createLine:(CGRect)frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForChapterDetail){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }else if(requestPath == HttpRequestPathForSendScore)
    {
        [ALDUtils addWaitingView:self.view withText:@"提交中,请稍候..."];
    }else if(requestPath == HttpRequestPathForDataFavorite)
    {
        [ALDUtils addWaitingView:self.view withText:@"操作处理中,请稍候..."];
    }else if(requestPath == HttpRequestPathForCommentSend){
        [ALDUtils hiddenTips:self.view];
        [ALDUtils addWaitingView:self.view withText:@"发布评论中,请稍候..."];
    }
    
    
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    
    if (requestPath == HttpRequestPathForCommentList) //获取评论
    {
        if (code == KOK)
        {
            if (!self.pageTag || [self.pageTag longLongValue]<1){
                self.commentData = result.obj;
            }else{
                [self.commentData addObjectsFromArray:result.obj];
            }
            hasNext = result.hasNext;
            if (!hasNext)
            {
                self.pullTableView.footerPullToRefreshText = @"没有更多数据了";
                [self.pullTableView footerEndRefreshing];
            }
            else
            {
                self.pullTableView.footerPullToRefreshText = @"上拉加载更多";
                self.pullTableView.footerReleaseToRefreshText = @"释放加载更多";
                self.pullTableView.footerRefreshingText = @"正在加载";
            }
            [_pullTableView headerEndRefreshing];
            [_pullTableView footerEndRefreshing];
            [_pullTableView reloadData];
        }
        else if (code == kNO_RESULT)
        {
//            hasNext = NO;
//            if (!self.commentData || self.commentData.count < 1)
//            {
//                
//                [_pullTableView tableViewDidFinishedLoading];
//                _pullTableView.reachedTheEnd = YES;
//            }
//            else
//            {
//                [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
//                _pullTableView.reachedTheEnd = YES;
//            }
            [_pullTableView reloadData];
        }
        else if (code == kNET_ERROR || code == kNET_TIMEOUT)
        {
            if (!self.commentData || self.commentData.count < 1)
            {
                [ALDUtils showToast:[NSString stringWithFormat:@"%@ 下拉刷新！",@"网络异常，请确认是否已连接!"]];
            }
            [_pullTableView footerEndRefreshing];
            [_pullTableView headerEndRefreshing];
            
        }
        else
        {
            if (!self.commentData || self.commentData.count < 1)
            {
                [ALDUtils showToast:@"抱歉，获取数据失败，下拉刷新！"];
            }
            else
            {
                [ALDUtils showToast:@"抱歉，加载更多失败！"];
            }
            [_pullTableView footerEndRefreshing];
            [_pullTableView headerEndRefreshing];
        }
    }
    else if (requestPath == HttpRequestPathForCommentSend)// 发布评论
    {
        if (code == KOK)
        {
            [self setDefaultFrame];
            
            [ALDUtils showToast:@"评论成功！"];
            
            NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
            NSString *nikName = [config objectForKey:KNickNameKey];
            NSString *icon = [config objectForKey:KIconKey];
            
            NSString *text =_commentTextView.text;
            //发送 文本
            CommentBean *bean  = [[CommentBean alloc] init];
            bean.name = nikName;
            bean.avatar = icon;
            bean.type = [NSNumber numberWithInt:5];
            bean.sourceId = self.chapterId;
            bean.content = text;
            bean.createTime=[ALDUtils getFormatDate:@"yyyy-MM-dd HH:mm:ss"];
            if(_commentData == nil)
            {
                _commentData = [NSMutableArray array];
            }
            [_commentData addObject:bean];
            _cbean.commentCount ++;
            [_pullTableView reloadData];
            
            _commentTextView.text = @"";
            
            UIView *comView = (UIView *)[_HeadView viewWithTag:TAG_LABEL_COMMENTCOUNR];
            UILabel *comLab = (UILabel *)[comView viewWithTag:0x16];
            comLab.text = [NSString stringWithFormat:@"评论 %i",_cbean.commentCount];
            
            if (self.dataChangedDelegate && [self.dataChangedDelegate respondsToSelector:@selector(dataChangedFrom:widthSource:byOpt:)]) {
                [self.dataChangedDelegate dataChangedFrom:self widthSource:self.cbean byOpt:1];
            }
            
            // 4.自动滚动表格到最后一行
            if(_commentData && _commentData.count>0)
            {
                NSIndexPath *lastPath = [NSIndexPath indexPathForRow:_commentData.count-1 inSection:0];
                [self.pullTableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } else {
            [ALDUtils showToast:@"评论失败，请稍候再试！"];
        }
    }
    else if(requestPath == HttpRequestPathForChapterDetail)
    {
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[ChapterBean class]]){
                _cbean = (ChapterBean *)obj;
                
                [self initUI];
            }
            [ALDUtils hiddenTips:self.view];
        }
    }else if(requestPath == HttpRequestPathForSendScore)
    {
        [ALDUtils showToast:result.errorMsg];
    }
    else if (requestPath == HttpRequestPathForDataFavorite)
    {
        if(code == KOK)
        {
//            [ALDUtils showToast:@"收藏成功"];
            if([result.obj isKindOfClass:[NSArray class]])
            {
                NSArray *arrayM = result.obj;
                
                for(ResultStatusBean *bean in arrayM)
                {
                    NSString *msg = bean.msg;
                    [ALDUtils showToast:msg];
                }
            }
            UILabel *title = (UILabel *)[self.HeadView viewWithTag:TAG_LABEL_COLLECTION];
            NSString *text;
            if([title.text isEqualToString:@"收藏"])
                text = @"已收藏";
            else if ([title.text isEqualToString:@"已收藏"])
                text = @"收藏";
            title.text = text;
            _cbean.favoriteFlag = !_cbean.favoriteFlag;
        }
        else
            [ALDUtils showToast:@"操作失败"];
    }
    [ALDUtils removeWaitingView:self.view];
}

@end