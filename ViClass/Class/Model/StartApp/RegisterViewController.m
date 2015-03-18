//
//  RegisterViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "RegisterViewController.h"
#import "CheckViewController.h"
#import "HttpClient.h"

@interface RegisterViewController()
{
    UITextField *phoneNum;
    UITextField *passWord;
    UITextField *userName;
    UITextField *checkNum;
}
@end
@implementation RegisterViewController
-(void)viewDidLoad
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
}
-(void)initUI
{
    CGFloat startX = 0;
    CGFloat starty = 10;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    phoneNum = [[UITextField alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 45)];
    phoneNum.keyboardType = UIKeyboardTypeNumberPad;
    phoneNum.layer.borderWidth = 0.5;
    phoneNum.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
    phoneNum.backgroundColor = KWordWhiteColor;
    
    CGSize size = [ALDUtils captureTextSizeWithText:@"  手机号" textWidth:200 font:kFontSize34px];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width+10, 45)];
    label.text = @"  手机号";
    label.textColor = KWordGrayColor;
    label.font = kFontSize34px;
    label.backgroundColor = [UIColor clearColor];
    phoneNum.leftView = label;
    phoneNum.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:phoneNum];
    [phoneNum becomeFirstResponder];
    
    starty += 50;
    passWord = [[UITextField alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 45)];
    passWord.secureTextEntry = YES;
    passWord.layer.borderWidth = 0.5;
    passWord.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
    passWord.backgroundColor = KWordWhiteColor;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width+10, 45)];
    label.text = @"  密  码";
    label.textColor = KWordGrayColor;
    label.backgroundColor = [UIColor clearColor];
    label.font = kFontSize34px;
    passWord.leftView = label;
    passWord.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:passWord];
    
    if(self.type)
    {
        starty += 50;
        checkNum = [[UITextField alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 45)];
        checkNum.secureTextEntry = YES;
        checkNum.layer.borderWidth = 0.5;
        checkNum.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
        checkNum.backgroundColor = KWordWhiteColor;
        
        size = [ALDUtils captureTextSizeWithText:@"  确认密码" textWidth:200 font:kFontSize34px];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width+10, 45)];
        label.text = @"  确认密码";
        label.textColor = KWordGrayColor;
        label.backgroundColor = [UIColor clearColor];
        label.font = kFontSize34px;
        checkNum.leftView = label;
        checkNum.leftViewMode = UITextFieldViewModeAlways;
        [self.view addSubview:checkNum];
    }
    else{
        starty += 65;
        userName = [[UITextField alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 45)];
        userName.placeholder = @"佚名";
        userName.layer.borderWidth = 0.5;
        userName.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
        userName.backgroundColor = KWordWhiteColor;
        
        size = [ALDUtils captureTextSizeWithText:@"  登陆用户名" textWidth:200 font:kFontSize32px];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width + 10, 45)];
        label.text = @"  登陆用户名";
        label.textColor = KWordGrayColor;
        label.font = kFontSize34px;
        label.backgroundColor = [UIColor clearColor];
        userName.leftView = label;
        userName.leftViewMode = UITextFieldViewModeAlways;
        [self.view addSubview:userName];
    }

}
-(void)sendCheckNum
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient sendVerifyCode:phoneNum.text withType:self.type + 1];
}
-(void)theNext:(UIButton *)sender
{
    if(phoneNum.text == nil || phoneNum.text.length <= 0)
    {
        [ALDUtils showToast:@"手机号不能为空"];
        return;
    }
    else
    {
        BOOL isPhone = [ALDUtils isValidateMobile:phoneNum.text];
        if(!isPhone)
        {
            [ALDUtils showToast:@"手机号码格式不正确"];
            return;
        }
    }
    if(passWord.text == nil || passWord.text.length <= 0)
    {
        [ALDUtils showToast:@"密码不能为空"];
        return;
    }else if (passWord.text.length<6)
    {
        [ALDUtils showToast:@"密码长度6位以上"];
        return;
    }
    if(self.type)
    {
        //重置密码
        if(![checkNum.text isEqualToString:passWord.text])
        {
            [ALDUtils showToast:@"确认密码不正确"];
            return;
        }
    }
    [self sendCheckNum];
    
}
-(void)gotoCheckVC
{
    CheckViewController *conteoller = [[CheckViewController alloc] init];
    conteoller.title = @"验证码";
    conteoller.phoneNum = phoneNum.text;
    conteoller.passWord = passWord.text;
    if(userName.text == nil || userName.text.length<=0)
        userName.text = @"佚名";
    conteoller.userName = userName.text;
    conteoller.type = self.type;
    [self.navigationController pushViewController:conteoller animated:YES];
}
#pragma mark -  http
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if(requestPath == HttpRequestPathForSendVerifyCode){
        [ALDUtils hiddenTips:self.view];
        [ALDUtils addWaitingView:self.view withText:@"验证码发送中"];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if (requestPath==HttpRequestPathForSendVerifyCode) {
        if(code==KOK){
            [ALDUtils showToast:@"验证码已发送到你的手机"];
            [self gotoCheckVC];
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
    }
    [ALDUtils removeWaitingView:self.view];

}



@end
