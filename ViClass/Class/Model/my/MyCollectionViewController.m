//
//  MyCollectionViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/12.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "HttpClient.h"
#import "ChapterBean.h"
#import "PullingRefreshTableView.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "BaseViewDocViewController.h"
#import "ResultStatusBean.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Reachability.h>
#import "ALDAsyncDownloader.h"

@interface MyCollectionViewController()<PullingRefreshTableViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    
}
@property(nonatomic,retain) PullingRefreshTableView *pullTableView;
@property(nonatomic,retain) NSMutableArray *tableData;
@property (nonatomic,assign) BOOL  bRefreshing;
@property (nonatomic,retain) NSIndexPath *deleIndexPath;

@property (nonatomic,retain) MPMoviePlayerController *moviePlayer;
@end
@implementation MyCollectionViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initParams];
    [self loadData];
    
    //-------------------
    // 列表
    //-------------------
       _pullTableView                  = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))pullingDelegate:self];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_pullTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayState:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinish:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    //监测网络状态变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    //视频
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    [_moviePlayer.view setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 180)];
    _moviePlayer.shouldAutoplay=NO;
    _moviePlayer.repeatMode = MPMovieRepeatModeOne;
    _moviePlayer.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_moviePlayer.view];
    _moviePlayer.view.hidden = YES;

}
//==============
// 初始化参数
//==============
- (void)initParams
{
    _iPage            = 1;
    _iPageSize        = 20;
    _bDataListHasNext = NO;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:str];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        CGFloat startX = 10.0;
        CGFloat startY = 5.0f;
        CGFloat cellWidth = CGRectGetWidth(self.view.frame);
        
        ALDImageView *icon = [[ALDImageView alloc] initWithFrame:CGRectMake(startX, startY, 144, 75)];
        icon.defaultImage = [UIImage imageNamed:@"class_default"];
        icon.imageUrl = @"";
        [cell.contentView addSubview:icon];
        icon.tag = 0x101;
        
        CGFloat viewWidth = cellWidth-164;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(154, startY, viewWidth, 75)];
        view.layer.borderWidth =0.5;
        view.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
        view.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:view];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, viewWidth-10, 37.5)];
        name.tag = 0x102;
        name.textColor = RGBACOLOR(30, 30, 30, 1);
        name.font = kFontSize26px;
        name.font = kFontSize26px;
        name.textAlignment = TEXT_ALIGN_LEFT;
        [view addSubview:name];
        
        
        UILabel *size = [[UILabel alloc] initWithFrame:CGRectMake(10, 37.5, viewWidth-10, 15)];
        size.tag = 0x103;
        size.textColor = RGBACOLOR(130, 130, 130, 1);
        size.font = kFontSize24px;
        size.textAlignment = TEXT_ALIGN_LEFT;
        [view addSubview:size];
        
        UILabel *num = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, viewWidth-20, 37.5)];
        num.tag = 0x104;
        num.textColor = RGBACOLOR(130, 130, 130, 1);
        num.font = kFontSize24px;
        num.textAlignment = TEXT_ALIGN_LEFT;
        [view addSubview:num];
        
    }
    ChapterBean *bean = self.tableData[indexPath.row];
    AttachmentBean *at = bean.attachments[0];
    
    ALDImageView *icon = (ALDImageView *)[cell viewWithTag:0x101];
    icon.imageUrl = bean.logo;
    
    UILabel *name = (UILabel *)[cell viewWithTag:0x102];
    name.text = bean.name;
    
    UILabel *size = (UILabel *)[cell viewWithTag:0x103];
    size.text =[NSString stringWithFormat:@"类型：%@",[at.type intValue]==3?@"视频":@"文档"];
    
    UILabel *num = (UILabel *)[cell viewWithTag:0x104];
    num.text = [NSString stringWithFormat:@"时间：%@",bean.createTime];

    return cell;

}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterBean *bean = self.tableData[indexPath.row];
    
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient dataFavoriteOpt:[NSArray arrayWithObject:bean.sid] type:5 opt:-1];
    
    _deleIndexPath = indexPath;
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消收藏";
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterBean *bean = _tableData[indexPath.row];
    AttachmentBean *at = bean.attachments[0];
    if([at.type intValue]== 3)
    {
        _moviePlayer.view.hidden = NO;
        
        ALDAsyncDownloader *downloader=[ALDAsyncDownloader asyncDownloader];
        NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str:at.url]];
        NSString *path =[downloader getCachedForUrlPath:url];
        NSString *ext=[self getFileExt:at.url];
        
        if(path!=nil){
            
            if([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"MP4"] || [ext isEqualToString:@"3gp"] || [ext isEqualToString:@"m4v"]){
                NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
                
                _moviePlayer.contentURL=url;
                [_moviePlayer play];
                
                _moviePlayer.controlStyle=MPMovieControlStyleFullscreen;
                [_moviePlayer setFullscreen:YES animated:YES];
                
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
                        NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str:at.url]];
                        [_moviePlayer setContentURL:url];
                        [_moviePlayer play];
                    }
                        break;
                    default:{
                        
                    }
                        break;
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
    else if([at.type intValue] == 4)
    {
        BaseViewDocViewController *controller = [[BaseViewDocViewController alloc] init];
        controller.docUrl=[self chineseToUTf8Str:at.url];
        controller.docName=bean.name;
        controller.fileType = [at.url pathExtension];
        controller.docSize=[at.size longValue];
        controller.title=@"文档";
        controller.type = FinishStyleWithSave;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
//视频播放状态改变
-(void)moviePlayState:(NSNotification *)notification
{
    if(_moviePlayer.playbackState==MPMoviePlaybackStatePlaying){
        _moviePlayer.view.hidden = NO;
    }
}
//done
-(void)movieFinish:(NSNotification *)notification
{
    _moviePlayer.controlStyle=MPMovieControlStyleNone;
    _moviePlayer.view.hidden = YES;
}
-(BOOL)shouldAutorotate{
    return YES;
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

-(NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    chineseStr = [chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return chineseStr;
}
-(void)loadData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient queryMyFavorites:5 page:_iPage paeCount:_iPageSize];
}
#pragma mark - Scroll Action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullTableView tableViewDidEndDragging:scrollView];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    self.bRefreshing = YES;
    [self performSelector:@selector(scrollLoadData) withObject:[NSNumber numberWithInt:1] afterDelay:1.f];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(scrollLoadData) withObject:[NSNumber numberWithInt:1] afterDelay:1.f];
}
- (void)scrollLoadData
{
    if (self.bRefreshing == YES)
    {
        _iPage=1;
    }
    else
    {
        _iPage++;
    }
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForMyFavorites){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
    else if(requestPath==HttpRequestPathForDataFavorite){
        [ALDUtils addWaitingView:self.view withText:@"取消收藏中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if (requestPath == HttpRequestPathForDataFavorite)
    {
        if(code == KOK)
        {

            if([result.obj isKindOfClass:[NSArray class]])
            {
                NSArray *arrayM = result.obj;
                
                for(ResultStatusBean *bean in arrayM)
                {
                    NSString *msg = bean.msg;
                    [ALDUtils showToast:msg];
                }
                if(_deleIndexPath)
                {
                    [self.tableData removeObjectAtIndex:_deleIndexPath.row];
                    [self.pullTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_deleIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
        else
            [ALDUtils showToast:@"操作失败"];
    }
    else if(requestPath==HttpRequestPathForMyFavorites){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *array=(NSArray *)obj;
                if(_iPage==1){
                    _tableData=[NSMutableArray arrayWithArray:array];
                }else{
                    [_tableData addObjectsFromArray:array];
                }
                
                _bDataListHasNext = result.hasNext;
                if (!_bDataListHasNext){
                    [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                    _pullTableView.reachedTheEnd = YES;
                }else{
                    [_pullTableView tableViewDidFinishedLoading];
                    _pullTableView.reachedTheEnd = NO;
                }
                [_pullTableView reloadData];
            }
            [ALDUtils hiddenTips:self.view];
        }else if(code==kNO_RESULT){
            _bDataListHasNext = NO;
            if(_iPage==1){
                self.tableData=nil;
                [self.pullTableView reloadData];
            }
            if (!_tableData || _tableData.count < 1){
                [_pullTableView tableViewDidFinishedLoading];
                _pullTableView.reachedTheEnd = NO;
            }else{
                [ALDUtils hiddenTips:self.view];
                [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                _pullTableView.reachedTheEnd = YES;
            }
        }else if(code==kHOST_ERROR) {
            NSString *errMsg=result.errorMsg;
            //            [ALDUtils showTips:self.view text:errMsg];
            //            [ALDUtils showToast:errMsg];
            NSString *text=[NSString stringWithFormat:@"该%@，请重新登录。",errMsg];
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alertView.tag=0x550;
            [alertView show];
            
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            if (!_tableData || _tableData.count < 1){
            }
            [_pullTableView tableViewDidFinishedLoading];
            if (_iPage>1) {
                _iPage--;
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if (!_tableData || _tableData.count < 1)
            {
                errMsg=@"抱歉，获取数据失败！下拉刷新！";
            } else {
                errMsg=@"抱歉，获取数据失败！";
            }
            [ALDUtils showToast:errMsg];
            [_pullTableView tableViewDidFinishedLoading];
            _pullTableView.reachedTheEnd = YES;
            if (_iPage>1) {
                _iPage--;
            }
        }
    }
    [ALDUtils removeWaitingView:self.view];
}

@end
