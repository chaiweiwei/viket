//
//  LoginViewController.m
//  BFEC
//  登录
//  Created by alidao on 13-6-5.
//  Copyright (c) 2013年 alidao. All rights reserved.
//

#import "BasicsLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BasicsRegisterViewController.h"
#import "AppDelegate.h"
#import "BasicsUserNameRegisterViewController.h"
#import "BasicsUserInfoViewController.h"
@interface BasicsLoginViewController ()<UIScrollViewDelegate>

@end

@implementation BasicsLoginViewController
@synthesize loginView=_loginView;
@synthesize delegate=_delegate;
@synthesize isMode=_isMode;

- (void)dealloc
{
    _loginViewShowed=NO;
    self.loginView=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

+(BOOL) isLoginViewShowing{
    return _loginViewShowed;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.hidesBottomBarWhenPushed){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCustomTabBar" object:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=KTableViewBackgroundColor;
    self.title=@"登录";
    
    if (self.cancelAble) {
        ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, 50, 30);
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        btn.tag=0x11;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem=leftBtnItem;
    }
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openApiResult:) name:KOpenApiResult object:nil];
}

-(void)initUI
{
    _loginViewShowed=YES;
    
    
    CGFloat startY=self.baseStartY;
    CGRect viewFrame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(viewFrame);
    CGFloat viewHeigh=CGRectGetHeight(viewFrame);
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh)];
    scrollView.delegate=self;
    scrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:scrollView];
    
    CGRect frame=CGRectMake(0, startY, CGRectGetWidth(viewFrame), CGRectGetHeight(viewFrame)-startY);
    BasicsLoginView *loginView=[[BasicsLoginView alloc] initWithFrame:frame withRoot:self];
    loginView.type=1;
    loginView.delegate=self;
    loginView.backgroundColor=[UIColor clearColor];
    loginView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [scrollView addSubview:loginView];
    self.loginView=loginView;
    
    startY+=loginView.contentHeight+20;
    //忘记密码
    CGRect btnFrame=CGRectMake(250, startY, 60, 15);
    ALDButton *forgetPwdBtn=[[ALDButton alloc] initWithFrame:btnFrame];
    [forgetPwdBtn setTitle:@"找回密码?" forState:UIControlStateNormal];
    [forgetPwdBtn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
    forgetPwdBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
    forgetPwdBtn.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    forgetPwdBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [forgetPwdBtn setBackgroundColor:[UIColor clearColor]];
    forgetPwdBtn.tag=0x112;
    [forgetPwdBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:forgetPwdBtn];
    CGSize size=[ALDUtils captureTextSizeWithText:[forgetPwdBtn titleForState:UIControlStateNormal] textWidth:2000.f font:forgetPwdBtn.titleLabel.font];
    CGFloat startX=CGRectGetWidth(viewFrame)-10-size.width;
    btnFrame.origin.x=startX;
    btnFrame.size.width=size.width;
    forgetPwdBtn.frame=btnFrame;
    
    startY+=btnFrame.size.height;
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(startX-2, startY, size.width+2, 1)];
    lineView.backgroundColor=KWordBlackColor;
    [scrollView addSubview:lineView];
    startY+=1;
    
    UILabel *label=[self createLabel:CGRectMake(0, startY, viewWidth, 20) textColor:KWordGrayColor textFont:[UIFont systemFontOfSize:12.0f]];
    label.text=@"尚未注册?";
    label.textAlignment=TEXT_ALIGN_CENTER;
    [scrollView addSubview:label];
    startY+=20;
    
    startX=10;
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(startX, startY, viewWidth-2*startX, 44.0f);
    [btn setTitle:@"用户名密码注册" forState:UIControlStateNormal];
    [btn setTitleColor:KWordRedColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.tag=0x12;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    startY+=44.0f;
    
    startX=10;
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(startX, startY, viewWidth-2*startX, 44.0f);
    [btn setTitle:@"手机注册" forState:UIControlStateNormal];
    [btn setTitleColor:KWordRedColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.tag=0x13;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    startY+=44.0f;
    
    startY+=30.0f;
    label=[self createLabel:CGRectMake(0, startY, viewWidth, 20) textColor:KWordGrayColor textFont:[UIFont systemFontOfSize:12.0f]];
    label.text=@"您还可以使用以下方式登录";
    label.textAlignment=TEXT_ALIGN_CENTER;
    [scrollView addSubview:label];
    startY+=30;
    
    CGFloat heigh=160.0f;
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, startY, viewWidth, heigh)];
    shareView.backgroundColor=RGBCOLOR(248, 248, 248);
    shareView.tag = 0x213;
    shareView.userInteractionEnabled = YES;
    shareView.contentMode = self.view.contentMode;
    //    [scrollView addSubview:shareView];
    
    CGFloat y=0;
    
    y+=18;
    /*
     NSArray *shareArray=[NSArray arrayWithObjects:@"bt_wechat",@"bt_penyouquan",@"bt_email", nil];
     NSArray *texts=[NSArray arrayWithObjects:@"QQ",@"微信登录",@"新浪微博", nil];
     int count=shareArray.count;
     CGFloat btnWidth=48.0f;
     CGFloat btnHeigh=70.0f;
     CGFloat xSpace=(viewWidth-count*btnWidth)/(count+1);
     CGFloat x=0;
     
     for(int i=0;i<count;i++){
     x=(i+1)*xSpace+(i*btnWidth);
     UIImage *icon=[UIImage imageNamed:[shareArray objectAtIndex:i]];
     NSString *text=[texts objectAtIndex:i];
     ALDButton *btn=[self createShareBtn:CGRectMake(x, y, btnWidth, btnHeigh) icon:icon text:text tag:1000+i];
     [shareView addSubview:btn];
     }*/
    //第三方登陆
//    NSArray *array=[NSArray arrayWithObjects:[NSNumber numberWithInt:UIActivityTypeQQ],[NSNumber numberWithInt:UIActivityTypeWeiBo],[NSNumber numberWithInt:UIActivityTypeWeiXin], nil];
//    OpenAPILogin *apiLoginView=[[OpenAPILogin alloc] initWithFrame:CGRectMake(0, startY, viewWidth, heigh) loginTypes:array];
//    apiLoginView.backgroundColor=[UIColor redColor];
//    [scrollView addSubview:apiLoginView];
    startY+=160;
    startY+=25;
    
    scrollView.contentSize=CGSizeMake(0, startY);
}


-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //取消登录
            if (self.cancelAble) {
                [self.parentViewController dismissViewControllerAnimated:YES completion:^{
                    _loginViewShowed=NO;
                }];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
            
        case 0x12:{ //用户名密码注册
            BasicsUserNameRegisterViewController *controller=[[BasicsUserNameRegisterViewController alloc] init];
            controller.title=@"用户注册";
            controller.delegate=self.delegate;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem=backItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 0x13:{ //手机号注册
            BasicsRegisterViewController *controller=[[BasicsRegisterViewController alloc] init];
            controller.type=1;
            controller.delegate=self.delegate;
            controller.title=@"手机注册";
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem=backItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
}


-(void)openApiResult:(NSNotification *)notification
{
    NSDictionary *dic=notification.userInfo;
    int openType=[[dic objectForKey:@"openType"] intValue];
    NSString *openId=[dic objectForKey:@"openId"];
    NSString *accessToken=[dic objectForKey:@"accessToken"];
    NSString *nickName=[dic objectForKey:@"nickName"];
    NSString *avatar=[dic objectForKey:@"avatar"];
    NSString *secret=nil;
    self.openType=openType;
    self.nickName=nickName;
    self.avatar=avatar;
    if(openType==1){
        secret=kWeiboAppSecret;
    }else if(openType==4){
        secret=kTecentAppSecret;
    }else if(openType==5){
        secret=kWeixinAppSecret;
    }
    [self openApiLogin:openId openType:openType accessToken:accessToken accessSecret:secret];
}

//第三方登录
-(void)openApiLogin:(NSString *)openId openType:(NSInteger)openType accessToken:(NSString *)accessToken accessSecret:(NSString *)accessSecret
{
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient openUserLogin:openId openType:openType accessToken:accessToken accessSecret:accessSecret];
}

-(void)shareBtnClicked:(ALDButton *)sender
{
//    switch (sender.tag) {
//        case 1000:{ //qq登录
//            BasicsAppDelegate *appDelegate=(BasicsAppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate sendQQRequest];
//        }
//            break;
//            
//        case 1001:{ //微信登录
//            BasicsAppDelegate *appDelegate=(BasicsAppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate sendAuthRequest];
//
//        }
//            break;
//            
//        case 1002:{ //新浪微博登录
//            BasicsAppDelegate *appDelegate=(BasicsAppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate sendWeiboSSORequest];
//
//        }
//            break;
//            
//        default:
//            break;
//    }
}

-(void)btnPressed:(ALDButton *)sender{
    BasicsRegisterViewController *controller=[[BasicsRegisterViewController alloc] init];
    if (sender.tag==0x112) {
        controller.title=@"找回密码";
        controller.type=2;
    }else{
        controller.type=1;
        controller.title=@"注册";
    }
    controller.delegate=self.delegate;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(ALDButton*) createShareBtn:(CGRect)frame icon:(UIImage*) icon text:(NSString*)text tag:(int) tag{
    ALDButton *button=[ALDButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    button.layer.masksToBounds=YES;
    button.layer.cornerRadius=4;
    button.tag=tag;
    [button addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *iconView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    iconView.image=icon;
    button.selectBgColor=[UIColor clearColor];
    [button addSubview:iconView];
    
    button.titleEdgeInsets=UIEdgeInsetsMake(55, 0, 0, 0);
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:KWordBlackColor forState:UIControlStateNormal];
    button.titleLabel.font=[UIFont systemFontOfSize:12.0f];
    
    return button;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loginView:(UIViewController *)loginView doneWithCode:(int)code withUser:(id)user{
    if (code==KOK) {
        NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
        NSString *uid=[config stringForKey:kUidKey];
        if(uid && ![uid isEqualToString:@""]){
            [config setObject:@"true" forKey:kNeedSendTokenKey];
            [config synchronize];
            
            AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
           // [appDelegate registPush];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
            [self.delegate loginView:self doneWithCode:code withUser:user];
        }
    }else if(code==401){
        [self gotoUserInfo];
    }
}

-(void)gotoUserInfo
{
    BasicsUserInfoViewController *controller=[[BasicsUserInfoViewController alloc] init];
    controller.title=@"完善信息";
    controller.loginDelegate=self;
    controller.cannotToNext=NO;
    controller.openApiNickName=self.nickName;
    controller.openApiAvatar=self.avatar;
    controller.hidesBottomBarWhenPushed=YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)gotoOpenApiWel:(NSString *)sid
{
//    BaseOpenApiWelViewController *controller=[[BaseOpenApiWelViewController alloc] init];
//    controller.title=@"欢迎注册";
//    controller.openType=self.openType;
//    controller.nickName=self.nickName;
//    controller.sid=sid;
//    controller.delegate=self;
//    controller.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:controller animated:YES];
}

-(void)getUserInfo
{
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient viewUserInfo:nil];
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForOpenUserLogin){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *user=(UserBean *)result.obj;
                NSString *sid=user.sid;
                if (user) {
                    int isNew=[user.isNew intValue];
                    if(isNew==1){ //新用户
                        [self gotoOpenApiWel:sid];
                    }else{
                        NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
                        [config setObject:user.uid forKey:kUidKey];
                        [config setObject:user.sessionKey forKey:kSessionIdKey];
                        NSInteger status=[user.status integerValue];
                        [config setInteger:status forKey:KUserStatus];
                        
                        NSString *text=user.userInfo.nickname;
                        if(text && ![text isEqualToString:@""]){
                            [config setObject:text forKey:KNickNameKey];
                        }
                        text=user.userInfo.avatar;
                        if(text && ![text isEqualToString:@""]){
                            [config setObject:text forKey:kHeadUrlKey];
                        }
                        [config synchronize];
                        [self getUserInfo];
                    }
                }else{
                    NSString *msg=@"登录失败，请稍侯再试!";
                    [ALDUtils showToast:msg];
                }
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if(code==kNO_RESULT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"用户不存在!";
                }
            }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"网络连接失败,请检查网络设置!";
                }
            }else{
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"登录失败!";
                }
            }
            [ALDUtils showToast:errMsg];
        }
    }else if(requestPath==HttpRequestPathForUserInfo){
        NSString *uid=nil;
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *bean=(UserBean *)obj;
                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
                
                NSString *text=bean.uid;
                if(text && ![text isEqualToString:@""]){
                    [config setObject:text forKey:kUidKey];
                }
                
                text=bean.sessionKey;
                if(text && ![text isEqualToString:@""]){
                    [config setObject:text forKey:kSessionIdKey];
                }
                
                text=bean.userInfo.nickname;
                if(text && ![text isEqualToString:@""]){
                    [config setObject:text forKey:KNickNameKey];
                }
                text=bean.userInfo.avatar;
                if(text && ![text isEqualToString:@""]){
                    [config setObject:text forKey:kHeadUrlKey];
                }
                
                NSDictionary *dic=bean.userInfo.extra;
                [config setObject:dic forKey:KUserInfoExtra];
                [config setInteger:[bean.status integerValue] forKey:KUserStatus];
                [config synchronize];
                
                UserDao *dao=[[UserDao alloc] init];
                [dao addUser:bean];
            }
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"获取用户信息失败,请稍候再试!";
            }
            [ALDUtils showToast:errMsg];
        }
        
        [self loginView:self doneWithCode:KOK withUser:uid];
    }
    [ALDUtils removeWaitingView:self.view];
}


@end
