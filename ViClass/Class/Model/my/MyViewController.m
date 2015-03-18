//
//  MyViewController.m
//  WeTalk
//
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "MyViewController.h"
#import "ALDButton.h"
#import "ALDImageView.h"
#import "UIViewExt.h"
#import "ALDUtils.h"
#import "PwdViewController.h"
#import "MyInfomationViewController.h"
#import "TableListViewController.h"
#import "FeedBackViewController.h"
#import "CacheViewController.h"
#import "StartViewController.h"
#import "HttpClient.h"
#import "UserBean.h"
#import "TimeDao.h"
#import "TimeViewController.h"
#import "MyCollectionViewController.h"
#import "MessagePushViewController.h"
#import "TimeDao.h"
#import "TimeBean.h"

#define TAG_IMAGE_ICON         0x001
#define TAG_LABLE_NAME         0x0016
#define TAG_LABLE_TALK         0x002
#define TAG_LABLE_RANKING     0x003
#define TAG_LABLE_HUANCUN      0x005
#define TAG_LABLE_HOMEWORK     0x006
#define TAG_IMAGE_RECODE       0x007
#define TAG_IMAGE_TEL          0x008
#define TAG_LABLE_PASS         0x009
#define TAG_IMAGE_CENTER       0x0010
#define TAG_LABLE_QUEST        0x0011
#define TAG_LABLE_SET          0x0012
#define TAG_LABLE_FEEDBACK     0X0013
#define TAG_LABLE_MYCOMMENT    0X0014
#define TAG_LABLE_HUANCUN_TEXT      0X0015
#define TAG_LABLE_LASTTIME          0X0017

@interface MyViewController ()<UIScrollViewDelegate>
@property(nonatomic,strong) UIScrollView *scroller;
@property (nonatomic,retain) UserBean *ub;
@property (nonatomic,retain) UILabel *cirIcon;
@end

@implementation MyViewController

- (void)dealloc
{
    self.scroller = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.scroller.backgroundColor = [UIColor clearColor];
    self.scroller.showsVerticalScrollIndicator = NO;
    self.scroller.delegate = self;
    [self.view addSubview:self.scroller];
    [self initData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)initUI
{
    //没有网络
    if(!_ub)
    {
        _ub = [[UserBean alloc] init];
        
        NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
        
        UserInfoBean *userInfo = [[UserInfoBean alloc] init];
        userInfo.avatar = [config objectForKey:KIconKey];
        userInfo.nickname = [config objectForKey:KNickNameKey];
        _ub.userInfo = userInfo;
        
        UserBehaviourBean *userBeha = [[UserBehaviourBean alloc] init];
        userBeha.integralCount = [NSNumber numberWithInt:0];
        userBeha.commentCount = [NSNumber numberWithInt:0];
        _ub.userBehaviour = userBeha;
        
        NSDictionary *exert = [NSDictionary dictionaryWithObject:@"0" forKey:@"ranking"];
        _ub.extra = exert;
        
    }
    UserInfoBean *ib = _ub.userInfo;
    UserBehaviourBean *ub = _ub.userBehaviour;
    
    NSDictionary *exera = _ub.extra;
    
    self.view.backgroundColor = KTableViewBackgroundColor;
    CGFloat viewWidth = self.view.width;
    //背景
    ALDImageView *bgImgView = [[ALDImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 32+3*2+80+32+49)];
    bgImgView.defaultImage = [UIImage imageNamed:@"bg_my"];
    bgImgView.imageUrl = @"";
    bgImgView.tag = 0x10001;
    bgImgView.userInteractionEnabled = YES;
    [self.scroller addSubview:bgImgView];
    
    //头像
    ALDImageView *icon = [[ALDImageView alloc] initWithFrame:CGRectMake(15, 32, 86, 86)];
    icon.defaultImage = [UIImage imageNamed:@"pic_photo"];
    icon.imageUrl = ib.avatar;
    icon.clickAble = YES;
    [icon addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    icon.layer.cornerRadius = 43;
    icon.layer.borderWidth = 3;
    icon.layer.borderColor = RGBACOLOR(169, 155, 114, 1).CGColor;
    icon.layer.masksToBounds = YES;
    icon.autoResize=NO;
    icon.fitImageToSize=NO;
    icon.tag = TAG_IMAGE_ICON;
    icon.backgroundColor=[UIColor clearColor];
    [bgImgView addSubview:icon];
    
    //标志
    UIImageView *tag = [[UIImageView alloc] initWithFrame:CGRectMake(icon.right-25-3, icon.bottom-25-3, 25, 25)];
    tag.image = [UIImage imageNamed:@"icon_female"];
    if (viewWidth == 414) {
        tag.frame = CGRectMake(icon.right-75/3.f-3, icon.bottom-75/3.f-3, 75/3.f, 75/3.f);
        tag.image = [UIImage imageNamed:@"icon_female@3x"];
    }
    //[bgImgView addSubview:tag];
    
    //名称
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(icon.right+10, 52, viewWidth-111, 15)];
    name.textColor = KWordWhiteColor;
    name.font = KFontSizeBold32px;
    name.layer.shadowColor = KWordBlackColor.CGColor;
    name.layer.shadowOffset = CGSizeMake(0, 1);
    name.layer.shadowRadius = 1.0;
    name.layer.shadowOpacity = 0.8;
    name.tag = TAG_LABLE_NAME;
    name.text = ib.nickname;
    [bgImgView addSubview:name];

    //说说数量
    UILabel *num = [[UILabel alloc] initWithFrame:CGRectMake(name.left, name.bottom+10, name.width, 15)];
    num.backgroundColor = [UIColor clearColor];
    num.textColor = KWordWhiteColor;
    num.font = kFontSize30px;
    num.layer.shadowColor = KWordBlackColor.CGColor;
    num.layer.shadowOffset = CGSizeMake(0, 1);
    num.layer.shadowRadius = 1.0;
    num.layer.shadowOpacity = 0.8;
    
    num.tag = TAG_LABLE_LASTTIME;
    [bgImgView addSubview:num];
    
    TimeDao *timeDao = [[TimeDao alloc] init];
    NSArray *arrayM = [timeDao queryTimeData];
    
    TimeBean *tb ;
    if(arrayM.count>0)
    {
        tb = arrayM[0];
        num.text =[NSString stringWithFormat:@"最近登陆时间:%@",[ALDUtils delRealTimeData:tb.time]];
    }
    else
    {
        tb = [[TimeBean alloc] init];
        tb.time = @"当前";
        num.text = @"最近登陆时间:当前";
    }
    
    
    //我的微说
    CGFloat btnWidth = (viewWidth-2)/3.0;
    UIView *btnView = [self createView:CGRectMake(0, icon.bottom+32+6, btnWidth, 49) title:@"我的积分" count:[NSString stringWithFormat:@"%@",ub.integralCount] tag:TAG_LABLE_TALK];
    [bgImgView addSubview:btnView];
    
    UIView *line = [self crecteLine:CGRectMake(btnView.right, btnView.top, 1, 49)];
    [bgImgView addSubview:line];
    
    //听过我
    btnView = [self createView:CGRectMake(line.right, icon.bottom+32+6, btnWidth, 49) title:@"成绩排名" count:[NSString stringWithFormat:@"%@",[exera valueForKey:(@"ranking")]] tag:TAG_LABLE_RANKING];
    [bgImgView addSubview:btnView];
    
    line = [self crecteLine:CGRectMake(btnView.right, btnView.top, 1, 49)];
    [bgImgView addSubview:line];
    
    //听过我
    btnView = [self createView:CGRectMake(line.right, icon.bottom+32+6, btnWidth, 49) title:@"我的评价" count:[ub.commentCount stringValue] tag:TAG_LABLE_MYCOMMENT];
    [bgImgView addSubview:btnView];
    
    //灰色分割线
    UIView *gayView = [self createGayView:CGRectMake(0, bgImgView.bottom, viewWidth, 15)];
    [self.scroller addSubview:gayView];
    
    UIButton *btn = [self createCellView:CGRectMake(0, gayView.bottom, viewWidth, 44) title:@"离线缓存" tag:TAG_LABLE_HUANCUN];
    [self.scroller addSubview:btn];
    
    //灰色分割线
    line = [self crecteGayLine:CGRectMake(15, btn.bottom, btn.width-15, 1)];
    [self.scroller addSubview:line];
    
//    btn = [self createCellView:CGRectMake(0, gayView.bottom+45, viewWidth, 44) title:@"文档类缓存" tag:TAG_LABLE_HUANCUN_TEXT];
//    [self.scroller addSubview:btn];
//
//    
//    //灰色分割线
//    line = [self crecteGayLine:CGRectMake(15, btn.bottom, btn.width-15, 1)];
//    [self.scroller addSubview:line];
    
    btn = [self createCellView:CGRectMake(0, line.bottom, viewWidth, 44) title:@"时间轴" tag:TAG_LABLE_HOMEWORK];
    [self.scroller addSubview:btn];
    
    //灰色分割线
    line = [self crecteGayLine:CGRectMake(15, btn.bottom, btn.width-15, 1)];
    [self.scroller addSubview:line];
    
    btn = [self createCellView:CGRectMake(0, line.bottom, viewWidth, 44) title:@"我的收藏" tag:TAG_LABLE_HUANCUN_TEXT];
    [self.scroller addSubview:btn];
    
    //灰色分割线
    line = [self crecteGayLine:CGRectMake(15, btn.bottom, btn.width-15, 1)];
    [self.scroller addSubview:line];
    
    btn = [self createCellView:CGRectMake(0, line.bottom, viewWidth, 44) title:@"消息推送" tag:TAG_IMAGE_RECODE];
    btn.tag = TAG_IMAGE_RECODE;
    [self.scroller addSubview:btn];
    
    UILabel *cir = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth-30, line.bottom+7, 20, 20)];
    cir.textColor = KWordWhiteColor;
    cir.textAlignment = TEXT_ALIGN_CENTER;
    cir.font = KFontSizeBold24px;
    cir.backgroundColor = [UIColor redColor];
    cir.layer.masksToBounds = YES;
    cir.layer.cornerRadius = 10;
    cir.tag = 0x1001;
    cir.hidden = YES;
    _cirIcon = cir;
    [self.scroller addSubview:cir];
    
    //灰色分割线
    gayView = [self createGayView:CGRectMake(0, btn.bottom, viewWidth, 15)];
    [self.scroller addSubview:gayView];
    
    
    btn = [self createCellView:CGRectMake(0, gayView.bottom, viewWidth, 44) title:@"修改登录密码" tag:TAG_LABLE_PASS];
    [self.scroller addSubview:btn];
    
    //灰色分割线
    line = [self crecteGayLine:CGRectMake(15, btn.bottom, btn.width-15, 1)];
    [self.scroller addSubview:line];
    
    
    btn = [self createCellView:CGRectMake(0, line.bottom, viewWidth, 44) title:@"问题反馈" tag:TAG_LABLE_FEEDBACK];
    [self.scroller addSubview:btn];
    
    //灰色分割线
    line = [self crecteGayLine:CGRectMake(15, btn.bottom, btn.width-15, 1)];
    [self.scroller addSubview:line];
    
    btn = [self createCellView:CGRectMake(0, line.bottom, viewWidth, 44) title:@"设置" tag:0x0010];
    //[self.scroller addSubview:btn];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(15, btn.bottom+25, viewWidth-30, 45);
    logoutBtn.layer.cornerRadius = 3;
    logoutBtn.layer.masksToBounds = YES;
    logoutBtn.backgroundColor = RGBACOLOR(237, 34, 34, 1);
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    logoutBtn.tag = 0x0011;
    [logoutBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scroller addSubview:logoutBtn];
    
    self.scroller.contentSize = CGSizeMake(viewWidth, logoutBtn.bottom+20+64);
    
}
-(void)initData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid=[config objectForKey:kUidKey];
    
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient viewUserInfo:uid];
}
-(void)TestData
{
    
}
-(void)clicked:(UIButton *)sender
{
    switch (sender.tag) {
        case TAG_IMAGE_RECODE://消息推送
        {
            MessagePushViewController *controller = [[MessagePushViewController alloc] init];
            controller.title = @"消息推送";
            controller.dataDelgate = self;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case TAG_LABLE_PASS://修改密码
        {
            PwdViewController *controller = [[PwdViewController alloc] init];
            controller.title = @"修改密码";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case TAG_IMAGE_ICON://个人资料
        {
            MyInfomationViewController *controller = [[MyInfomationViewController alloc] init];
            controller.dataChangedDelegate = self;
            controller.title = @"个人资料";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case TAG_LABLE_HOMEWORK://个人资料
        {
            TimeViewController *controller = [[TimeViewController alloc] init];
            controller.title = @"时间轴";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case TAG_LABLE_FEEDBACK://反馈
        {
            FeedBackViewController *controller = [[FeedBackViewController alloc] init];
            controller.title = @"反馈";
            controller.type = 1;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case TAG_LABLE_HUANCUN://缓存
        {
            CacheViewController *controller = [[CacheViewController alloc] init];
            controller.title = @"缓存";
            controller.type = 1;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case TAG_LABLE_HUANCUN_TEXT://我的收藏
        {
            MyCollectionViewController *controller = [[MyCollectionViewController alloc] init];
            controller.title = @"我的收藏";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 0x0011:
        {
            NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            [httpClient logout];
            
            [config setObject:@"" forKey:kUidKey];
            [config setInteger:0 forKey:KUserStatus];
            [config setObject:@"" forKey:kSessionIdKey];
            [config setObject:@"" forKey:kUserNameKey];
            [config setObject:@"" forKey:KUserInfoExtra];
            [config synchronize];

        }
            break;
        default:
            break;
    }
}
-(void)dataChangedFrom:(id)from widthSource:(id)source byOpt:(int)opt
{
    if(opt==2){
        
        [self initData];
    }
    
}

-(UIButton *)createView:(CGRect)rect title:(NSString *)title count:(NSString *)count tag:(int)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = rect;
    btn.backgroundColor = KWordBlackColor;
    btn.tag = tag;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    btn.alpha = 0.3;
    CGSize size = [ALDUtils captureTextSizeWithText:title textWidth:200 font:kFontSize30px];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x + (rect.size.width-size.width)/2.0,rect.origin.y + 9, size.width, 15)];
    name.font = kFontSize30px;
    name.textColor = KWordWhiteColor;
    name.text = title;
    [self.scroller addSubview:name];
    
    size = [ALDUtils captureTextSizeWithText:count textWidth:200 font:kFontSize28px];
    UILabel *num = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x +(rect.size.width-size.width)/2.0, name.bottom+2, size.width,15)];
    num.font = kFontSize28px;
    num.textColor = KWordWhiteColor;
    num.tag = 000201 + tag;
    num.text = count;
    [self.scroller addSubview:num];
    
    return btn;
}
-(UIView *)crecteLine:(CGRect)rect
{
    UIView *line =[[UIView alloc] initWithFrame:rect];
    line.backgroundColor = KWordWhiteColor;
    line.alpha = 0.3;
    return line;
}
-(UIView *)crecteGayLine:(CGRect)rect
{
    UIView *line =[[UIView alloc] initWithFrame:rect];
    line.backgroundColor = KWordGrayColor;
    line.alpha = 0.3;
    return line;
}
-(UIView *)createGayView:(CGRect)Rect
{
    UIView *view = [[UIView alloc] initWithFrame:Rect];
    view.backgroundColor = KTableViewBackgroundColor;
    return view;
}
-(UIButton *)createCellView:(CGRect)rect title:(NSString *)title tag:(int)tag
{
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.backgroundColor = KWordWhiteColor;
    btn.tag = tag;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, rect.size.width-15, rect.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBACOLOR(51, 51, 51, 1);
    label.textAlignment = TEXT_ALIGN_LEFT;
    label.font = kFontSize34px;
    label.text = title;
    [btn addSubview:label];
    
    return btn;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForUploadFile){
        [ALDUtils addWaitingView:self.view withText:@"头像上传中，请稍候..."];
    }else if(requestPath==HttpRequestPathForModifyUserInfo){
        [ALDUtils addWaitingView:self.view withText:@"正在提交,请稍候..."];
    }
    else if(requestPath==HttpRequestPathForUserInfo){
        [ALDUtils addWaitingView:self.view withText:@"数据加载中,请稍候..."];
    }
    
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForUserInfo){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                
                _ub=(UserBean *)obj;
                HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
                [httpClient getUnReadUserNewsCount];
                //[self initUI];
            }
        }
        else
        {
            [ALDUtils showToast:result.errorMsg];
            [self initUI];
        }
    }else if(requestPath == HttpRequestPathForUserNewsUnread)
    {
        [self initUI];
       if(code == KOK)
       {
           UILabel *icon = _cirIcon;
            int count = [result.obj intValue];
            if(count>0)
            {
                icon.text = [NSString stringWithFormat:@"%i",count];
                icon.hidden = NO;
            }
            else
            {
                icon.hidden = YES;
            }
       }
    }
    else if(requestPath == HttpRequestPathForLogout)
    {
        if(code==KOK){
            
            UIWindow *win = [UIApplication sharedApplication].keyWindow;
            
            StartViewController *controller=[[StartViewController alloc] init];
            controller.title=ALDLocalizedString(@"User login", @"用户登录");
            UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:controller];
            win.rootViewController=navController;
        }
    }
    [ALDUtils removeWaitingView:self.view];
}


@end
