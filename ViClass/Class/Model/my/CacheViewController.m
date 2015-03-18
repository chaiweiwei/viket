//
//  CacheViewController.m
//  ViKeTang
//
//  Created by chaiweiwei on 15/1/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "CacheViewController.h"
#import "ClassRoomBean.h"
#import "ALDImageView.h"
#import "ChapterBean.h"
#import "ShowViewController.h"
#import "BaseViewDocViewController.h"
#import "FileDao.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Reachability.h>
#import "ALDAsyncDownloader.h"

@interface CacheViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) UITableView *tableView;//列表
@property (nonatomic, retain) NSMutableArray  *tableData;//列表数据

@property (nonatomic,retain) MPMoviePlayerController *moviePlayer;

@end
@implementation CacheViewController

- (void)dealloc
{
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KTableViewBackgroundColor;
    if(self.title == nil || self.title.length == 0)
    {
        self.title = @"缓存";
    }
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 80, 40);
    [btn setTitle:@"清空所有" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(deleteCilcked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightBtnItem;
    
     CGRect frame                    = self.view.frame;
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource       = self;
    _tableView.delegate         = self;
    _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_tableView];
    [self loadData];
    
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
-(void)loadData
{
    if(self.type ==1 || self.type == 3)
    {
        FileDao *fileDao = [[FileDao alloc] init];
        self.tableData = [NSMutableArray arrayWithArray:[fileDao queryFileData]];
    }else if(self.type == 2)
    {
        ChapterDao *chapterDao = [[ChapterDao alloc] init];
        self.tableData = [NSMutableArray arrayWithArray:[chapterDao queryChapterData:self.sid]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    ClassRoomBean *Rbean = nil;
    ChapterBean *Cbean = nil;
    if(self.type == 1)
        Rbean = self.tableData[indexPath.row];
    else
        Cbean = self.tableData[indexPath.row];
        

    ALDImageView *icon = (ALDImageView *)[cell viewWithTag:0x101];
    icon.imageUrl = Rbean.logo;
    if(self.type== 2)
        icon.imageUrl = Cbean.logo;
    
    UILabel *name = (UILabel *)[cell viewWithTag:0x102];
    name.text = Rbean.name;
    if(self.type == 2)
    {
        name.text = Cbean.name;
    }
    if(self.type== 3)
     name.text = [NSString stringWithFormat:@"%@",Cbean.shareUrl];
    
    UILabel *size = (UILabel *)[cell viewWithTag:0x103];
    size.text =[NSString stringWithFormat:@"类型：%@",Rbean.categoryName];
    if(self.type == 2)
    {
        AttachmentBean *bean = Cbean.attachments[0];
        size.text =[NSString stringWithFormat:@"类型：%@",[bean.type intValue]==3?@"视频":@"文档"];
    }
    UILabel *num = (UILabel *)[cell viewWithTag:0x104];
    
    num.text = [NSString stringWithFormat:@"时间：%@",[ALDUtils delRealTimeData:Rbean.createTime]];
    if(self.type == 2)
    {
        num.text = [NSString stringWithFormat:@"时间：%@",[ALDUtils delRealTimeData:Cbean.createTime]];
    }

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
    //删除其中的缓存
    //缓存删除
    if(self.type == 1)
    {
        ClassRoomBean *bean = self.tableData[indexPath.row];
        NSLog(@"%@",bean);

        FileDao *fileDao = [[FileDao alloc] init];
        [fileDao deleteFileData:bean.sid];
    }
    else if(self.type == 2)
    {
        ChapterBean *bean = self.tableData[indexPath.row];
        ChapterDao *chapterDao = [[ChapterDao alloc] init];
        [chapterDao deleteChapterData:bean.sid classId:self.sid];
    }
    
    [self.tableData removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.type == 1)
        return @"删除文件夹";
    return @"删除";
}
-(void)deleteCilcked:(UIButton *)sender
{
    UIActionSheet *alter = [[UIActionSheet alloc] initWithTitle:@"删除所有内容" delegate:self cancelButtonTitle:@"取消"  destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alter showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0://确定
        {
            //缓存删除
            if(self.type == 1)
            {
                FileDao *fileDao = [[FileDao alloc] init];
                [fileDao deleteFileData];
            }
            else if(self.type == 2)
            {
                ChapterDao *chapterDao = [[ChapterDao alloc] init];
                [chapterDao deleteChapterData:self.sid];
                //并删除该课程的保存数据
                
                FileDao *fileDao = [[FileDao alloc] init];
                [fileDao deleteFileData:self.sid];
            }
            //
            [self.tableData removeAllObjects];
            [self.tableView reloadData];
        }
            break;
        case 1://取消
            
            break;
        default:
            break;
    }
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
    if(self.type == 1)
    {
        ClassRoomBean *bean = self.tableData[indexPath.row];
        CacheViewController *controller = [[CacheViewController alloc] init];
        controller.title = @"缓存";
        controller.type = 2;
        controller.sid = bean.sid;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if(self.type == 2)
    {
        ChapterBean *bean = self.tableData[indexPath.row];
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
-(NSString *)getPathOfDocuments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    
    path = [path stringByAppendingPathComponent:@"ImagesCache"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSError *error=nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    return path;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
