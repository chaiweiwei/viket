//
//  TalkListViewController.m
//  WeTalk
//
//  1.达人显示页 2.导师显示页 3.我的微说 4.我的收藏
//
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "ClassListViewController.h"
#import "UIBarButtonItem+ALDBackBarButtonItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ALDImageView.h"
#import "ALDButton.h"
#import "CircularProgressView.h"
#import "ToggleButton.h"
#import "ShowViewController.h"
#import "CheckoutViewController.h"
#import "BaseViewDocViewController.h"
#import "DownloadHandler.h"
#import "ClassListCell.h"
#import "ChapterBean.h"
#import "HttpClient.h"
#import "ClassRoomBean.h"
#import "ALDButton.h"
#import "ALDAsyncDownloader.h"
#import "FileDao.h"
#import "ChapterDao.h"
#import "NewCheckViewController.h"

#define TAG_BTN_DOWN   0x10001
#define TAG_BTN_TEST   0x10002
#define TAG_BTN_PROGRESS  0x10003
#define TAG_BTN_COMMENT         0x025
#define TAG_BTN_GOOD            0x026
#define TAG_BTN_TITLE           0x027
#define TAG_BTN_PRAISEICON      0x028 //点赞的图标
#define TAG_VIEW_BGVIEW      0x029 //点赞的图标
@interface ClassListViewController ()<DownloadDelegate,PullingRefreshTableViewDelegate>
{
    ALDAsyncDownloader * aldDownloadHandler;
    BOOL ifModel;
}

@property (nonatomic, retain) UIButton         *playOrPauseButton;
@property (nonatomic,strong) UIButton *hideView;//点击显示隐藏的view
@property (nonatomic,strong) UILabel *titleLabel;//点击显示隐藏的view
@property (nonatomic,strong) UILabel *contentLabel;//点击显示隐藏的view
@property (nonatomic,retain) ClassRoomBean *firstBean;
@property(nonatomic,retain) UIView *headView;
@property (nonatomic,retain) NSMutableArray *handlers;//下载器
@property (nonatomic,retain) ALDButton *praiseBtn;//点击点赞
@property (nonatomic,retain) NSArray *chapterCachData;//是否有同用户下载的文件
@property (nonatomic,retain) UIView *joinView;
@end

@implementation ClassListViewController
@synthesize pullTableView  = _pullTableView;
@synthesize tableData      = _tableData;
@synthesize bRefreshing    = _bRefreshing;

- (void)dealloc
{
    self.pullTableView.dataSource      = nil;
    self.pullTableView.delegate        = nil;
    self.pullTableView                 = nil;
    self.tableData                     = nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    [self initParams];
   // [self initUI];
    //[self loadData];
    
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getClassDetail:self.courseId];
    
    //加载下载文件
    ChapterDao *chapterDao = [[ChapterDao alloc] init];
    _chapterCachData = [NSArray arrayWithArray:[chapterDao queryChapterData:self.courseId]];
    
}
- (void)clickButton:(ALDButton *)sender {
    switch (sender.tag) {
        case 0x010: { //返回按钮
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
            break;
        default:
            break;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.handlers != nil && self.handlers.count>0)
    {
        for(DownloadHandler *down in self.handlers)
        {
            [down removeRequestFromQueue];
        }
    }
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

//==============
// 初始化界面
//==============
- (void)initUI
{
    //-------------------
    // 列表
    //-------------------
    CGFloat viewWidth  = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight  = CGRectGetHeight(self.view.frame);
    
    _pullTableView                  = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight) pullingDelegate:self];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_pullTableView];
    
    UIView *HeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 32+3*2+80+32)];
    HeadView.backgroundColor = [UIColor whiteColor];
    self.pullTableView.tableHeaderView = HeadView;
    self.headView = HeadView;
    
    //背景
    ALDImageView *bgImgView = [[ALDImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 150)];
    bgImgView.defaultImage = [UIImage imageNamed:@"bg_my"];
    bgImgView.imageUrl = _firstBean.logo;
    bgImgView.userInteractionEnabled = YES;
    bgImgView.clickAble = YES;
    bgImgView.tag = 000100;
    [bgImgView addTarget:self action:@selector(imgClick) forControlEvents:UIControlEventTouchUpInside];
    [HeadView addSubview:bgImgView];
    
    CGSize size = [ALDUtils captureTextSizeWithText:_firstBean.name textWidth:200 font:kFontSize34px];
    CGFloat lineWidth = (viewWidth - 30 -size.width-20)/2.0f;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15,CGRectGetMaxY(bgImgView.frame)-50+7,lineWidth, 1)];
    line.backgroundColor = KWordWhiteColor;
    [bgImgView addSubview:line];
    
    //名称
    UILabel *name = [self createLabel:CGRectMake(CGRectGetMaxX(line.frame)+10, CGRectGetMaxY(bgImgView.frame)-50, size.width, 15) title:_firstBean.name textColor:KWordWhiteColor textFont:kFontSize34px];
    name.layer.shadowColor = KWordBlackColor.CGColor;
    name.layer.shadowOffset = CGSizeMake(0, 1);
    name.layer.shadowRadius = 1.0;
    name.layer.shadowOpacity = 0.8;
    name.tag = 000101;
    [bgImgView addSubview:name];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(name.frame)+size.width+10,CGRectGetMaxY(bgImgView.frame)-50+7,lineWidth, 1)];
    line.backgroundColor = KWordWhiteColor;
    [bgImgView addSubview:line];
    
//    //说说数量
//    UILabel *num = [self createLabel:CGRectMake(name.left, name.bottom+10, name.width, 15) title:@"课程数量" textColor:[UIColor redColor] textFont:k30pxBoldFont];
//    num.layer.shadowColor = KWordBlackColor.CGColor;
//    num.layer.shadowOffset = CGSizeMake(0, 1);
//    num.layer.shadowRadius = 1.0;
//    num.layer.shadowOpacity = 0.8;
//    [bgImgView addSubview:num];
//    
//    //播放数量
//    size = [ALDUtils captureTextSizeWithText:@"粉丝数量" textWidth:200 font:k30pxFont];
//    UILabel *playNum = [self createLabel:CGRectMake(num.left + size.width + 15, num.top, name.width, 15) title:@"粉丝数量" textColor:[UIColor redColor] textFont:k30pxBoldFont];
//    playNum.layer.shadowColor = KWordBlackColor.CGColor;
//    playNum.layer.shadowOffset = CGSizeMake(0, 1);
//    playNum.layer.shadowRadius = 1.0;
//    playNum.layer.shadowOpacity = 0.8;
//    [bgImgView addSubview:playNum];
    
    //隐藏的view
    self.hideView = [[UIButton alloc] initWithFrame:bgImgView.frame];
    self.hideView.backgroundColor = [UIColor whiteColor];
    self.hideView.alpha = 0.8;
    self.hideView.hidden = YES;
    [self.hideView addTarget:self action:@selector(imgClick) forControlEvents:UIControlEventTouchUpInside];
    [bgImgView addSubview:self.hideView];
    
    size = [ALDUtils captureTextSizeWithText:@"课程介绍" textWidth:(viewWidth-25) font:kFontSize28px];
    self.titleLabel = [self createLabel:CGRectMake(0,10, viewWidth, size.height) title:@"课程介绍" textColor:RGBACOLOR(30, 30, 30, 1) textFont:KFontSizeBold28px];
//    label.layer.shadowColor = KWordBlackColor.CGColor;
//    label.layer.shadowOffset = CGSizeMake(0, 1);
//    label.layer.shadowRadius = 1.0;
//    label.layer.shadowOpacity = 0.8;
    self.titleLabel.textAlignment = TEXT_ALIGN_CENTER;
    self.titleLabel.hidden = YES;
    [bgImgView addSubview:self.titleLabel];
    
//    size = [ALDUtils captureTextSizeWithText:[NSString stringWithFormat:@"%@\n\n教师名称: %@\n教师简介: %@",_firstBean.note,_firstBean.teacherName,_firstBean.teacherNote] textWidth:(viewWidth-25) font:KFontSizeBold24px];
//    self.contentLabel = [self createLabel:CGRectMake(15, 50, viewWidth-25, size.height) title:[NSString stringWithFormat:@"%@\n\n教师名称: %@\n教师简介: %@",_firstBean.note,_firstBean.teacherName,_firstBean.teacherNote] textColor:RGBACOLOR(30, 30, 30, 1) textFont:KFontSizeBold24px];
//    self.contentLabel.numberOfLines = 0;
    size = [ALDUtils captureTextSizeWithText:[NSString stringWithFormat:@"%@",_firstBean.note] textWidth:(viewWidth-25) font:KFontSizeBold24px];
    self.contentLabel = [self createLabel:CGRectMake(15, 50, viewWidth-25, size.height) title:[NSString stringWithFormat:@"%@",_firstBean.note] textColor:RGBACOLOR(30, 30, 30, 1) textFont:KFontSizeBold24px];
    self.contentLabel.numberOfLines = 0;

//    label.layer.shadowColor = KWordBlackColor.CGColor;
//    label.layer.shadowOffset = CGSizeMake(0, 1);
//    label.layer.shadowRadius = 1.0;
//    label.layer.shadowOpacity = 0.8;
    self.contentLabel.hidden = YES;
    [bgImgView addSubview:self.contentLabel];
    
    size = [ALDUtils captureTextSizeWithText:@"加入课程" textWidth:200 font:kFontSize24px];
    
    _joinView = [[UIView alloc] initWithFrame:CGRectMake(viewWidth-size.width-10, 15, size.width, size.height+32)];
    [bgImgView addSubview:_joinView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 15)];
    label.text = @"加入课程";
    label.font = kFontSize24px;
    label.textColor = RGBACOLOR(234, 245, 255, 1);
    [_joinView addSubview:label];
    
    UIButton *clickIcon = [[UIButton alloc] initWithFrame:CGRectMake(size.width/2.0, 17, 16, 32)];
    [clickIcon setBackgroundImage:[UIImage imageNamed:@"icon_click"] forState:UIControlStateNormal];
    [clickIcon addTarget:self action:@selector(courseApply) forControlEvents:UIControlEventTouchUpInside];
    [_joinView addSubview:clickIcon];
    
    if(_firstBean.applyFlag)
        _joinView.hidden = YES;
    else
        _joinView.hidden = NO;

}
-(void)courseApply
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient courseApply:self.courseId];
}
-(void)loadData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getChapterList:_iPage pageCount:_iPageSize subjectId:self.courseId];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = KTableViewBackgroundColor;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}

#pragma mark - TableViewDataSource, TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellID = @"CellID";
    ClassListCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellID];
    
    CGRect frame      = self.view.frame;
    CGFloat viewWidth = CGRectGetWidth(frame);
    CGFloat cellWidth = CGRectGetWidth(self.view.frame);
    CGFloat startX = 10;
    CGFloat startY = 10;
    if (cell == nil)
    {
        cell = [[ClassListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellID];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 15)];
        grayView.backgroundColor = KTableViewBackgroundColor;
        [cell addSubview:grayView];
        
        ALDImageView *icon = [[ALDImageView alloc] initWithFrame:CGRectMake(0, grayView.bottom, viewWidth, 80)];
        if (viewWidth == 414) {
            icon.frame = CGRectMake(0, grayView.bottom, viewWidth, 312/3.f);
        }
        icon.tag = 0x0010;
        icon.autoResize = NO;
        icon.fitImageToSize = NO;
        icon.userInteractionEnabled = YES;
        icon.backgroundColor=[UIColor clearColor];
        [cell addSubview:icon];
        
//        //标记
//        UILabel *num = [[UILabel alloc] initWithFrame:CGRectMake(startX+3, (icon.height-60)/2.f + 3, 54, 54)];
//        num.layer.masksToBounds = YES;
//        num.layer.borderWidth =2;
//        num.layer.cornerRadius = 27;
//        num.tag = 0x0011;
//        num.textColor = [UIColor whiteColor];
//        num.backgroundColor = [UIColor clearColor];
//        num.font = KFontSizeBold40px;
//        num.textAlignment = TEXT_ALIGN_CENTER;
//        num.layer.borderColor = [UIColor whiteColor].CGColor;
//        [icon addSubview:num];
        
        //标题
        UILabel *name = [self createLabel:CGRectMake(15, 25, viewWidth-2*startX -70, 15) title:@"第几节课" textColor:KWordBlackColor textFont:kFontSize30px];
        name.tag = 0x0012;
        [icon addSubview:name];
        
        //标题
        UILabel *content = [self createLabel:CGRectMake(15, 50, viewWidth-2*startX -70, 15) title:@"关键词: 空 " textColor:KWordBlackColor textFont:kFontSize28px];
        content.tag = 0x0013;
        [icon addSubview:content];
        
        //标签
//        ALDImageView *iconTag = [[ALDImageView alloc] initWithFrame:CGRectMake(viewWidth-18-startX, 0, 18, 22)];
//        iconTag.tag = 0x0014;
//        iconTag.image = [UIImage imageNamed:@"icon_collect"];
//        if (viewWidth == 414) {
//            iconTag.image = [UIImage imageNamed:@"icon_collect@3x"];
//        }
//        iconTag.autoResize = NO;
//        iconTag.fitImageToSize = NO;
//        iconTag.backgroundColor=[UIColor clearColor];
//        [icon addSubview:iconTag];
        UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth-60+3, 10, 60, 25)];
        tag.tag = 0x0014;
        tag.textAlignment = TEXT_ALIGN_CENTER;
        tag.textColor = KWordWhiteColor;
        tag.backgroundColor = [UIColor redColor];
        tag.font = KFontSizeBold30px;
        tag.layer.masksToBounds = YES;
        tag.layer.cornerRadius = 3;
        [icon addSubview:tag];
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(icon.frame), viewWidth, 50)];
        btnView.backgroundColor = KWordWhiteColor;
        btnView.tag = TAG_VIEW_BGVIEW;
        [cell addSubview:btnView];
        
        ProgressIndicator *progress = [[ProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.frame), 15)];
        progress.tag = TAG_BTN_PROGRESS;
        [btnView addSubview:progress];
        
        ALDButton *btn= [self createMarkBtn:@"练习" rect:CGRectMake(15, 10, 60, 30)];
        btn.tag = TAG_BTN_TEST;
        [btnView addSubview:btn];
        
        btn= [self createMarkBtn:@"下载" rect:CGRectMake(90, 10, 60, 30)];
        [btn setTitle:@"已下载" forState:UIControlStateDisabled];
        btn.tag = TAG_BTN_DOWN;
        [btnView addSubview:btn];
        
        //删除
        CGSize size = [ALDUtils captureTextSizeWithText:@"评论" textWidth:200 font:kFontSize24px];
        //评论
        btn = [self createTitleBtn:CGRectMake(cellWidth-60, 0, 40, 40) icon:@"bt_pinlun_xq" title:@"评论" tag:TAG_BTN_COMMENT];
        [btnView addSubview:btn];
        
        //点赞
        btn = [self createTitleBtn:CGRectMake(cellWidth-87-size.width, 0, 40, 40) icon:@"bt_pinlun_n_xq" title:@"点赞" tag:TAG_BTN_GOOD];
        [btnView addSubview:btn];

        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 144, viewWidth, 1)];
        line.backgroundColor = RGBACOLOR(242, 242, 242, 1);
        [cell addSubview:line];
        
        cell.tag = indexPath.row + 0x200;
    }
    ChapterBean *bean = _tableData [indexPath.row];
    AttachmentBean *at = bean.attachments[0];
    
    ALDButton *btn = (ALDButton *)[cell viewWithTag:TAG_BTN_TEST];
    btn.userInfo = [NSDictionary dictionaryWithObject:bean forKey:@"data"];
    
    btn = (ALDButton *)[cell viewWithTag:TAG_BTN_DOWN];
    //btn.userInfo = [NSDictionary dictionaryWithObject:bean forKey:@"data"];
    btn.userInfo = [NSDictionary dictionaryWithObject:indexPath forKey:@"index"];
    
    NSString *text = @"";
    UILabel *tag = (UILabel *)[cell viewWithTag:0x0014];
    if([at.type intValue] == 3)
        text = @"视频";
    else if ([at.type intValue] == 4)
        text = @"文档";
    tag.text = text;
    
    //判断是否有缓存，有就显示进度条
    ProgressIndicator *progress = (ProgressIndicator *)[cell viewWithTag:TAG_BTN_PROGRESS];
    if(aldDownloadHandler == nil)
        aldDownloadHandler=[ALDAsyncDownloader asyncDownloader];
    NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str:at.url]];
    NSString *path =[aldDownloadHandler getCachedForUrlPath:url];
    if(path)
    {
        BOOL save = NO;
        for(ChapterBean *temp in _chapterCachData)
        {
           save = [temp.sid isEqualToString:bean.sid];
            if(save)//存在
            {
                save = YES;
                break;
            }
        }
        if (save) {
            progress.progressView.progress = 1;
            btn.enabled = NO;
        }
        else {
            progress.progressView.progress = 0;
            btn.enabled = YES;
        }
    }
    else
    {
        progress.progressView.progress = 0;
        btn.enabled = YES;
    }
    ALDImageView *icon = (ALDImageView *)[cell viewWithTag:0x0010];
    NSInteger index = indexPath.row%4;
    if (index == 0) {
        icon.image = [UIImage imageNamed:@"bg_list01"];
        if (viewWidth == 414) {
            icon.image = [UIImage imageNamed:@"bg_list01@3x"];
        }
    }else if (index == 1) {
        icon.image = [UIImage imageNamed:@"bg_list02"];
        if (viewWidth == 414) {
            icon.image = [UIImage imageNamed:@"bg_list02@3x"];
        }
    }else if (index == 2) {
        icon.image = [UIImage imageNamed:@"bg_list03"];
        if (viewWidth == 414) {
            icon.image = [UIImage imageNamed:@"bg_list03@3x"];
        }
    }else if (index == 3) {
        icon.image = [UIImage imageNamed:@"bg_list04"];
        if (viewWidth == 414) {
            icon.image = [UIImage imageNamed:@"bg_list04@3x"];
        }
    }
    
    UILabel *label = (UILabel *)[icon viewWithTag:0x0012];
    label.text = bean.name;
    
    label = (UILabel *)[icon viewWithTag:0x0013];
    label.text = [NSString stringWithFormat:@"关键词: %@",bean.tags];
    
    UIView *bgView = (UIView *)[cell viewWithTag:TAG_VIEW_BGVIEW];
    
    text = @"评论";
    if(bean.commentCount>0)
    {
        text = [NSString stringWithFormat:@"%i",bean.commentCount];
    }
    CGSize size = [ALDUtils captureTextSizeWithText:text textWidth:200 font:kFontSize24px];
    
    //评论
    ALDButton *commentBtn = (ALDButton *)[bgView viewWithTag:TAG_BTN_COMMENT];
    frame = commentBtn.frame;
    frame.origin.y = startY;
    frame.origin.x = cellWidth - 33-size.width;
    commentBtn.frame = frame;
    commentBtn.userInfo=[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"data"];
    UILabel *title = (UILabel *)[commentBtn viewWithTag:TAG_BTN_TITLE];
    title.text = text;
    
    //点赞
    text = @"点赞";
    if(bean.praiseCount>0)
    {
        text = [NSString stringWithFormat:@"%i",bean.praiseCount];
    }
    size = [ALDUtils captureTextSizeWithText:text textWidth:200 font:kFontSize24px];
    ALDButton *good = (ALDButton *)[bgView viewWithTag:TAG_BTN_GOOD];
    good.userInfo=[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"data"];
    frame = good.frame;
    frame.origin.y = startY;
    frame.origin.x = CGRectGetMinX(commentBtn.frame)-33-size.width;
    good.frame = frame;
    title = (UILabel *)[good viewWithTag:TAG_BTN_TITLE];
    title.text = text;
    
    //改变点赞图标
    UIImageView *praiseIcon = (UIImageView *)[good viewWithTag:TAG_BTN_PRAISEICON];
    praiseIcon.image = [UIImage imageNamed:@"bt_pinlun_n_xq"];
    
    if(bean.praiseFlag)//已点赞
    {
        praiseIcon.image = [UIImage imageNamed:@"bt_pinlun_c_xq"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 145;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterBean *bean = self.tableData[indexPath.row];
     AttachmentBean *at = bean.attachments[0];
    
    if([at.type intValue] == 3)
    {//视频
        ShowViewController *controller = [[ShowViewController alloc] init];
        controller.title = @"章节详情";
        controller.dataChangedDelegate = self;
        controller.chapterId = bean.sid;
        controller.url = [self chineseToUTf8Str:at.url];
        controller.toController = 2;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if([at.type intValue] == 4)
    {
        BaseViewDocViewController *controller = [[BaseViewDocViewController alloc] init];
        controller.docUrl=[self chineseToUTf8Str:at.url];
        controller.docName=bean.name;
        controller.fileType = [at.url pathExtension];
        controller.docSize=[at.size longValue];
        controller.title=@"下载";
        controller.type = FinishStyleWithSave;
        [self.navigationController pushViewController:controller animated:YES];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
         ProgressIndicator *progress =(ProgressIndicator *)[cell viewWithTag:TAG_BTN_PROGRESS];
        progress.progressView.progress = 1;
    }
        
}
//strToHex([url.absoluteString UTF8String])
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
-(void)imgClick
{
    self.hideView.hidden = !self.hideView.hidden;
    self.contentLabel.hidden = !self.contentLabel.hidden;
    self.titleLabel.hidden = !self.titleLabel.hidden;
}
-(void)dataChangedFrom:(id)from widthSource:(id)source byOpt:(int)opt
{
    if([source isKindOfClass:[ChapterBean class]]){
        if(opt==1){
            
//             FriendsCircleBean *sourceBean=[FriendsCircleBean initFriendCircle:source];
//             if (self.tableData.count>0) {
//             [self.tableData insertObject:sourceBean atIndex:1];
//             }else{
//             self.tableData=[NSMutableArray arrayWithObject:sourceBean];
//             }
//             [self.tableView reloadData];
            _bRefreshing=YES;
            [self scrollLoadData];
        }
    }
}

//format audio time
- (NSString *)formatTime:(int)num{
    
    int sec = num % 60;
    int min = num / 60;
    if (num < 60) {
        return [NSString stringWithFormat:@"00:%02d",num];
    }
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
}
-(ALDButton *)createMarkBtn:(NSString *)title rect:(CGRect )rect
{
    ALDButton *btn = [[ALDButton alloc] initWithFrame:rect];
    [btn setTitleColor:RGBACOLOR(142, 142, 142, 1) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *img = [self resizedImage:@"bg_biaoqian2"];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}
-(void)clicked:(ALDButton *)sender
{
    switch (sender.tag) {
        case TAG_BTN_TEST:
        {
            ChapterBean *bean = [sender.userInfo objectForKey:@"data"];
            if(bean.questionCount<=0)
            {
                [ALDUtils showToast:@"没有上传练习，请等待"];
                return;
            }
//            CheckoutViewController *controller = [[CheckoutViewController alloc] init];
//            controller.title = @"练习";
//            controller.chapterId = bean.sid;
//            
//            [self.navigationController pushViewController:controller animated:YES];
            NewCheckViewController *controller = [[NewCheckViewController alloc] init];
            controller.title = @"题目1";
            controller.chapterId = bean.sid;
            controller.num = 0;
            [self.navigationController pushViewController:controller animated:YES];

        }
        break;
        case TAG_BTN_DOWN:
        {
            [self btnStartDownload:sender];
        }
        break;
        case TAG_BTN_GOOD://点赞
        {
            self.praiseBtn = sender;
            int row = [[sender.userInfo objectForKey:@"data"] intValue];
            ChapterBean *bean = self.tableData[row];
            HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
            //1：赞，-1：取消赞
            if(!bean.praiseFlag)
                [httpClient dataPraise:bean.sid type:5 opt:1];
            else
                [httpClient dataPraise:bean.sid type:5 opt:-1];
        }
            break;
        case TAG_BTN_COMMENT://评论
        {
            int row = [[sender.userInfo objectForKey:@"data"] intValue];
            ChapterBean *bean = self.tableData[row];
            AttachmentBean *at = bean.attachments[0];
            
            if([at.type intValue] == 3)
            {//视频
                ShowViewController *controller = [[ShowViewController alloc] init];
                controller.title = @"章节详情";
                controller.dataChangedDelegate = self;
                controller.chapterId = bean.sid;
                controller.url = [self chineseToUTf8Str:at.url];
                controller.toController = 2;
                [self.navigationController pushViewController:controller animated:YES];
            }
            else if([at.type intValue] == 4)
            {
                BaseViewDocViewController *controller = [[BaseViewDocViewController alloc] init];
                controller.docUrl=[self chineseToUTf8Str:at.url];
                controller.docName=bean.name;
                controller.fileType = [at.url pathExtension];
                controller.docSize=[at.size longValue];
                controller.title=@"下载";
                controller.type = FinishStyleWithSave;
                [self.navigationController pushViewController:controller animated:YES];
                
            }

            
        }
            break;

        default:
            break;
    }
}

-(ALDButton *)createTitleBtn:(CGRect) frame icon:(NSString *)icon title:(NSString *)title tag:(int)tag
{
    CGFloat startX = 0;
    ALDButton *btn = [ALDButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    img.image = [UIImage imageNamed:icon];
    img.tag = TAG_BTN_PRAISEICON;
    [btn addSubview:img];
    startX += 23;
    
    CGSize size = [ALDUtils captureTextSizeWithText:title textWidth:200 font:kFontSize24px];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(startX, 0, size.width, 20)];
    lable.backgroundColor = [UIColor clearColor];
    lable.textAlignment = TEXT_ALIGN_LEFT;
    lable.font = kFontSize24px;
    lable.tag = TAG_BTN_TITLE;
    lable.textColor = RGBACOLOR(130, 130, 130, 1);
    lable.text = title;
    [btn addSubview:lable];
    
    startX += size.width;
    frame.size.width =startX;
    btn.frame = frame;
    return btn;
}
// 启动下载
-(void)btnStartDownload:(ALDButton *)sender
{
    NSLog(@"btnStartDownload");
    
    NSDictionary *dic = sender.userInfo;
    NSIndexPath *index = [dic objectForKey:@"index"];
    
    ClassListCell *cell = (ClassListCell *)[_pullTableView cellForRowAtIndexPath:index];
    ChapterBean *bean = self.tableData[index.row];
    
    ProgressIndicator *progress =(ProgressIndicator *)[cell viewWithTag:TAG_BTN_PROGRESS];
    DownloadHandler *downloadHandler = [[DownloadHandler alloc] init];

    AttachmentBean *at = bean.attachments[0];
    
    downloadHandler.url = [self chineseToUTf8Str:at.url];
    downloadHandler.name = bean.name;
    downloadHandler.fileType = [at.url pathExtension];
    downloadHandler.savePath = [self getPathOfDocuments];
    downloadHandler.progress = progress;
    downloadHandler.delegate = self;
    downloadHandler.sign = (int)cell.tag;
    cell.down = downloadHandler;
    
    [downloadHandler start];
    
    //方便之后移除
    if(self.handlers == nil)
    {
        self.handlers = [NSMutableArray array];
    }
    [self.handlers addObject:downloadHandler];
    
    sender.enabled = NO;
    [sender setTitle:@"正在下载" forState:UIControlStateDisabled];
}
-(NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    chineseStr = [chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return chineseStr;
}
-(void)downloadFinish:(int)sign
{
    [ALDUtils showToast:@"下载完成"];
    UITableViewCell *cell = (UITableViewCell *)[self.pullTableView viewWithTag:sign];
    ALDButton *button = (ALDButton *)[cell viewWithTag:TAG_BTN_DOWN];
    [button setTitle:@"已下载" forState:UIControlStateDisabled];
    
    NSDictionary *dic = button.userInfo;
    NSIndexPath *index = [dic objectForKey:@"index"];
    ChapterBean *cb = _tableData [index.row];
    
    //数据库保存
    FileDao *fileDao = [[FileDao alloc] init];
    [fileDao addFileData:_firstBean];
    
    ChapterDao *chapterDao = [[ChapterDao alloc] init];
    [chapterDao addChapterData:cb classId:_firstBean.sid];
    
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
#pragma  mark - 图片拉伸
-(UIImage *)resizedImage:(NSString *)imgName
{
    UIImage *image = [UIImage imageNamed:imgName];
    return [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
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
-(void) showTips:(NSString *) text{
    _pullTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [ALDUtils showTips:self.view text:text];
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
    if(requestPath==HttpRequestPathForClassDetail){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }else if(requestPath==HttpRequestPathForCourseApply){
        [ALDUtils addWaitingView:self.view withText:@"课程报名中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if(requestPath == HttpRequestPathForCourseApply)
    {
        if(code == KOK)
        {
            if(_joinView.hidden == NO)
                _joinView.hidden = YES;
            [ALDUtils showToast:@"报名成功,在课表中查看"];
        }
        else
            [ALDUtils showToast:result.errorMsg];
    }
    else if(requestPath == HttpRequestPathForClassDetail)
    {
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[ClassRoomBean class]]){
                _firstBean = (ClassRoomBean *)obj;
                [self initUI];
                
//                ALDImageView *bgImgae =(ALDImageView *) [self.headView viewWithTag:000100];
//                bgImgae.imageUrl = _firstBean.logo;
//                self.titleLabel.text = _firstBean.name;
//                self.contentLabel.text = _firstBean.note;
//                
                [self loadData];

            }
            [ALDUtils hiddenTips:self.view];
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

    }else if (requestPath==HttpRequestPathForDataPraise){
        self.praiseBtn.userInteractionEnabled=YES;
        if (code==KOK) {
            id obj=result.obj;
            if([obj isKindOfClass:[NSDictionary class]]){
                NSDictionary *dic=(NSDictionary *)obj;
                int praiseCount=[[dic objectForKey:@"praiseNum"] intValue];
                int praiseFlag=[[dic objectForKey:@"praiseAble"] intValue];
                
                int row = [[self.praiseBtn.userInfo objectForKey:@"data"] intValue];
                ChapterBean *bean = self.tableData[row];
                
                bean.praiseFlag = praiseFlag;
                bean.praiseCount = praiseCount;
                
                [_pullTableView reloadData];
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if (code!=kNET_ERROR && code!=kNET_TIMEOUT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"抱歉，发表赞失败！";
                }
            }else{
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"网络连接失败,请检查网络设置!";
                }
            }
            [ALDUtils showToast:errMsg];
        }
        [ALDUtils removeWaitingView:self.view];
        self.view.userInteractionEnabled=YES;
        
    }
    else if(requestPath==HttpRequestPathForChapterList){
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
                [self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"抱歉，暂无会务数据!"]];
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
                [self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"网络异常，请确认是否已连接!"]];
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
