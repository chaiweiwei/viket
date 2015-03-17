//
//  CheckViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "CheckViewController.h"
#import "HttpClient.h"
#import "UserBean.h"
#import "MyInfoViewController.h"
#import "BasicsUserInfoViewController.h"

@interface CheckViewController()
{
    UITextField *checkNum;
    UIButton *timeBtn;
    UILabel *checkTimer;
    NSTimer *timer;
    int count;
    NSString *tokenValue;
}
@end
@implementation CheckViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 70, 40);
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(theNext:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self initUI];
    
    count = 60;
    timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(changeCheck) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
    
}
-(void)sendCheckNum
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient sendVerifyCode:_phoneNum withType:1];
}
-(void)initUI
{
    CGFloat startX = 0;
    CGFloat starty = 10;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 15)];
    label.text = @"我们已发送验证码短信到这个手机号";
    label.textAlignment = TEXT_ALIGN_CENTER;
    label.font = kFontSize30px;
    label.textColor = KWordGrayColor;
    [self.view addSubview:label];
    
    starty += 30;
    label = [[UILabel alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 15)];
    label.text = [NSString stringWithFormat:@"+86 %@",_phoneNum];
    label.textAlignment = TEXT_ALIGN_CENTER;
    label.font = KFontSizeBold32px;
    label.textColor = KWordBlackColor;
    [self.view addSubview:label];
    
    starty += 30;
    checkNum = [[UITextField alloc] initWithFrame:CGRectMake((viewWidth-160)/2.0, starty, 160, 50)];
    checkNum.keyboardType = UIKeyboardTypeNumberPad;
    checkNum.textAlignment = TEXT_ALIGN_CENTER;
    checkNum.font = KFontSizeBold32px;
    checkNum.layer.cornerRadius = 3;
    checkNum.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
    checkNum.layer.borderWidth = 0.5;
    checkNum.backgroundColor = KWordWhiteColor;
    checkNum.placeholder = @"验证码";
    [checkNum becomeFirstResponder];
    [self.view addSubview:checkNum];
    
    starty += 80;
    timeBtn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-300)/2.0,starty, 300, 53)];
    [timeBtn setBackgroundColor:RGBACOLOR(244, 124, 40, 1)];
    timeBtn.layer.masksToBounds = YES;
    timeBtn.layer.cornerRadius = 5;
    timeBtn.titleLabel.font = KFontSizeBold32px;
    timeBtn.tag = 1;
    timeBtn.enabled = NO;
    [timeBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    checkTimer  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 53)];
    checkTimer.backgroundColor = [UIColor clearColor];
    checkTimer.textAlignment = TEXT_ALIGN_CENTER;
    checkTimer.textColor =  KWordWhiteColor;
    checkTimer.font = KFontSizeBold32px;
    checkTimer.text = @"60秒后可重新获取";
    [timeBtn addSubview:checkTimer];
    
    [self.view addSubview:timeBtn];
}
-(void)changeCheck
{
    checkTimer.text = [NSString stringWithFormat:@"%i秒后可重新获取",count];
    
    [timeBtn setBackgroundColor:RGBACOLOR(242, 182, 140, 1)];
    if(count<=0 && [timer isValid])
    {
        [timer invalidate];
        [timeBtn setBackgroundColor:RGBACOLOR(244, 124, 40, 1)];
        checkTimer.text = @"点击重新获取";
        timeBtn.enabled = YES;
    }
    count--;
}
-(void)clicked:(UIButton *)sender
{
    count = 60;
    //重新发送验证码
    [timeBtn setBackgroundColor:RGBACOLOR(244, 124, 40, 1)];
    timeBtn.enabled = NO;
    
    [self sendCheckNum];
    
    if(![timer isValid])
    {
        timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(changeCheck) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [timer fire];
    }
}
-(void)theNext:(UIButton *)sender
{
    if (checkNum.text == nil || checkNum.text.length<=0) {
        [ALDUtils showToast:@"请输入验证码，完成注册"];
        return;
    }
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient verifyCode:_phoneNum type:self.type + 1 code:checkNum.text];
}
#pragma mark -  http
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if(requestPath == HttpRequestPathForSendVerifyCode){
        [ALDUtils hiddenTips:self.view];
    }
    else if (requestPath==HttpRequestPathForVerifyCode){
        [ALDUtils addWaitingView:self.view withText:@"正在验证，请稍候..."];
    }
    else if (requestPath==HttpRequestPathForResetPassword){
        [ALDUtils addWaitingView:self.view withText:@"正在验证，请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if (requestPath==HttpRequestPathForSendVerifyCode) {
        if(code==KOK){
            [ALDUtils showToast:@"验证码已发送到你的手机"];
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"获取验证码失败,请稍候再试!";
            }
            [ALDUtils showToast:errMsg];
        }
        self.view.userInteractionEnabled=YES;
    }else if (requestPath==HttpRequestPathForVerifyCode){ //验证验证码
        NSString *errorMsg=result.errorMsg;
        if (code==KOK) {
            NSString *token=result.obj;
            tokenValue=token;
            if(self.type == 0)
            {
                //注册
                BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                [httpClient registerWithUser:_phoneNum pwd:_passWord type:1 token:token invitationCode:nil];
            }
            else if(self.type == 1)
            {
                //重置
                HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
                [httpClient resetPassword:_phoneNum pwd:_passWord token:token];
            }
            return;
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else if (code==kNO_RESULT){
            [ALDUtils showToast:@"验证码输入错误，请重输!"];
            [checkNum becomeFirstResponder];
        }else{
            if (!errorMsg || [errorMsg isEqualToString:@""]) {
                errorMsg=@"验证码验证失败，请稍候再试!";
            }
            [ALDUtils showToast:errorMsg];
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
    }else if (requestPath==HttpRequestPathForRegister){
        if (code==KOK) {
            UserBean *bean=result.obj;
            NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
            [config setObject:bean.uid forKey:kUidKey];
            [config setObject:bean.sessionKey forKey:kSessionIdKey];
            NSString *text=bean.userInfo.nickname;
            if(text && ![text isEqualToString:@""]){
                [config setObject:text forKey:KNickNameKey];
            }
            
            text=bean.userInfo.avatar;
            if(text && ![text isEqualToString:@""]){
                [config setObject:text forKey:kHeadUrlKey];
            }
            
            if(_phoneNum && ![_phoneNum isEqualToString:@""]){
                [config setObject:_phoneNum forKey:kUserNameKey];
            }
            int status=[bean.status intValue];
            [config setInteger:status forKey:KUserStatus];
            [config synchronize];
            
            if (status ==1 ) {
                [self gotoUserInfo:YES]; //跳转到完善信息
            }else{
                [self gotoUserInfo:NO]; //跳转到完善信息
            }
            
            self.view.userInteractionEnabled=YES;
            [ALDUtils removeWaitingView:self.view];
            return;
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else if (code==kNO_RESULT){
            NSString *errorMsg=result.errorMsg;
            if (!errorMsg || [errorMsg isEqualToString:@""]) {
                errorMsg=@"验证码错误或已失效，请重输!";
            }
            [ALDUtils showToast:errorMsg];
        }else{
            NSString *errorMsg=result.errorMsg;
            if (!errorMsg || [errorMsg isEqualToString:@""]) {
                errorMsg=@"注册失败，请稍候再试!";
            }
            [ALDUtils showToast:errorMsg];
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
    }
    else if (requestPath == HttpRequestPathForResetPassword)
    {
        if (code==KOK) {
            [ALDUtils showToast:@"密码重置成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    [ALDUtils removeWaitingView:self.view];
}
-(void)gotoUserInfo:(BOOL) cannotToNext
{
    MyInfoViewController *controller = [[MyInfoViewController alloc] init];
    controller.title = @"完善资料";
    controller.phoneNum = _phoneNum;
    controller.userName = _userName;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
