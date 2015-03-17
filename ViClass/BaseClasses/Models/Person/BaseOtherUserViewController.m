//
//  OtherUserViewController.m
//  Basics
//  他人的用户信息
//  Created by alidao on 14/12/9.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseOtherUserViewController.h"
#import "ALDButton.h"
#import "ALDImageView.h"

@interface BaseOtherUserViewController ()<UIScrollViewDelegate>

@property (nonatomic,retain) ALDButton *attenteBtn;
@property (nonatomic) int opt; //操作 1.关注 -1.取消关注

@end

@implementation BaseOtherUserViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.hidesBottomBarWhenPushed){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCustomTabBar" object:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 60, 44);
    [btn setTitle:@"关注" forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15.0f];
    btn.backgroundColor=[UIColor clearColor];
    btn.selectBgColor=[UIColor clearColor];
    btn.hidden=YES;
    btn.tag=0x10;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightItem;
    self.attenteBtn=btn;
    
    [self getUserInfo];

    // Do any additional setup after loading the view.
}

//获取会员信息
-(void) getUserInfo
{
    NSString *uid=self.uid;
    if(uid && ![uid isEqualToString:@""]){
        BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
        [httpClient viewUserInfo:uid];
    }
}

-(void)initUI:(UserBean *)bean
{
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh)];
    scrollView.delegate=self;
    scrollView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor=kBackgroudColor;
    [self.view addSubview:scrollView];
    
    self.attenteBtn.hidden=NO;
    BOOL following=[bean.userInfo.following boolValue];
    if(following){
        [self.attenteBtn setTitle:@"已关注" forState:UIControlStateNormal];
        self.opt=-1;
    }else{
        [self.attenteBtn setTitle:@"关注" forState:UIControlStateNormal];
        self.opt=1;
    }
    
    CGFloat startX=10.0f;
    CGFloat startY=0.0f;
    CGFloat labWidth=viewWidth-2*startX;
    //背景图
    //    ALDImageView *imgView=[[ALDImageView alloc] initWithFrame:CGRectMake(0, startY, viewWidth, 90.0f)];
    //    imgView.image=[UIImage imageNamed:@"img_user"];
    //    imgView.backgroundColor=[UIColor clearColor];
    //    [scrollView addSubview:imgView];
    
    CGFloat headY=0;
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, startY, viewWidth, 95)];
    headView.backgroundColor=[UIColor whiteColor];
    [scrollView addSubview:headView];
    //头像
    NSString *text=bean.userInfo.avatar;
    ALDImageView *imgView=[[ALDImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 75)];
    imgView.defaultImage=[UIImage imageNamed:@"user_default"];
    imgView.imageUrl=text;
    imgView.layer.borderWidth=2.f;
    imgView.layer.borderColor=[UIColor whiteColor].CGColor;
    imgView.layer.masksToBounds=YES;
    imgView.layer.cornerRadius=75/2;
    imgView.autoResize=NO;
    imgView.fitImageToSize=NO;
    imgView.backgroundColor=[UIColor clearColor];
    [scrollView addSubview:imgView];
    
    headY+=15.0f;
    
    //名称
    UILabel *label=[self createLabel:CGRectMake(startX+85, headY, 120, 20) textColor:KWordBlackColor textFont:[UIFont systemFontOfSize:18.0f]];
    text=bean.userInfo.nickname;
    text=text==nil?@"":text;
    if([text isEqualToString:@""]){
        text=@"未设置昵称";
    }
    label.text=text;
    [headView addSubview:label];
}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x10:{ //关注操作
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            [httpClient friendsAttention:self.uid opt:self.opt];
        }
            break;
            
        default:
            break;
    }
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if(requestPath==HttpRequestPathForUserInfo){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }else if(requestPath==HttpRequestPathForFriendsAttention){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForUserInfo){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *bean=(UserBean *)obj;
                [self initUI:bean];
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if(code==kNO_RESULT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"用户不存在或已被删除!";
                }
            }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"网络连接失败,请检查网络设置!";
                }
            }else{
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"获取用户信息失败,请稍候再试!";
                }
            }
            [ALDUtils showToast:errMsg];
        }
    }else if(requestPath==HttpRequestPathForFriendsAttention){
        if(code==KOK){
            if(self.opt==1){
                [self.attenteBtn setTitle:@"已关注" forState:UIControlStateNormal];
                self.opt=-1;
            }else if(self.opt==-1){
                [self.attenteBtn setTitle:@"关注" forState:UIControlStateNormal];
                self.opt=1;
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if(code==kNO_RESULT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"用户不存在或已被删除!";
                }
            }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"网络连接失败,请检查网络设置!";
                }
            }else{
                if(!errMsg || [errMsg isEqualToString:@""]){
                    if(self.opt==1){
                        errMsg=@"关注失败!";
                    }else{
                        errMsg=@"取消关注失败!";
                    }
                }
            }
            [ALDUtils showToast:errMsg];
        }
    }
    [ALDUtils removeWaitingView:self.view];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
