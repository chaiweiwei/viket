//
//  LoginViewController.m
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/20.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "LoginViewController.h"
#import "UserBean.h"
#import "HttpClient.h"
#import "MyInfoViewController.h"
#import "NewsTabViewController.h"
#import "RegisterViewController.h"

@interface LoginViewController()
{
    UITextField *passWord;
    UITextField *userName;
}
@end
@implementation LoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self initUI];
}
-(void)initUI
{
    CGFloat startX = 0;
    CGFloat starty = 10;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 45)];
    textField.placeholder = @"用户名";
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
    textField.backgroundColor = KWordWhiteColor;
    userName = textField;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
    view.backgroundColor = [UIColor clearColor];
    textField.leftView = view;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:textField];
     [textField becomeFirstResponder];
    
    starty += 50;
    textField = [[UITextField alloc] initWithFrame:CGRectMake(startX, starty, viewWidth, 45)];
    textField.placeholder = @"密  码";
    textField.secureTextEntry = YES;
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
    textField.backgroundColor = KWordWhiteColor;
    passWord = textField;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 45)];
    view.backgroundColor = [UIColor clearColor];
    textField.leftView = view;
    textField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:textField];
    
    starty += 65;
    CGSize size = [ALDUtils captureTextSizeWithText:@"忘记密码？" textWidth:200 font:KFontSizeBold32px];
    
    UIButton *forget = [UIButton buttonWithType:UIButtonTypeCustom];
    forget.frame = CGRectMake(viewWidth-15-size.width, starty, size.width, 15);
    [forget setBackgroundColor:[UIColor clearColor]];
    [forget setTitle:@"忘记密码？"forState:UIControlStateNormal];
    forget.titleLabel.font = KFontSizeBold32px;
    [forget setTitleColor:KWordBlackColor
                 forState:UIControlStateNormal];
    forget.titleLabel.textAlignment = TEXT_ALIGN_Right;
    [forget addTarget:self action:@selector(changePass) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forget];
}
-(void)changePass
{
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    controller.title = @"重置密码";
    controller.type = 1;
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)submit:(UIButton *)sender
{
    if(userName.text.length<=0)
    {
        [ALDUtils showToast:@"用户名为空"];
        return;
    }
    if(passWord.text.length<=0)
    {
         [ALDUtils showToast:@"密码为空"];
        return;
    }
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient loginWithUser:userName.text pwd:passWord.text];
}
-(void)gotoUserInfo
{
    MyInfoViewController *controller = [[MyInfoViewController alloc] init];
    controller.title = @"完善资料";
    controller.phoneNum = userName.text;
    [self.navigationController pushViewController:controller animated:YES];
}
-(void) forwardToMainView{
    
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    NewsTabViewController *controller=[[NewsTabViewController alloc] init];
    UINavigationController *nav    = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.title=@"微课堂";
    win.rootViewController=nav;
    
    [win makeKeyAndVisible];
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if (requestPath==HttpRequestPathForLogin) {
        [ALDUtils addWaitingView:self.view withText:@"登录中,请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForLogin){
        [ALDUtils removeWaitingView:self.view];
        NSString *msg=result.errorMsg;
        if (code==KOK) {
            UserBean *user=(UserBean *)result.obj;
            if (user) {
                

                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
                [config setObject:user.uid forKey:kUidKey];
                [config setObject:user.sessionKey forKey:kSessionIdKey];
                [config setObject:userName.text forKey:kUserNameKey];
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
                
                if(status==0){
                    [self gotoUserInfo];
                    return;
                }else{
                    [self forwardToMainView];
                }
            }else{
                msg=@"登录失败，请稍侯再试!";
            }
        }
        else
        {
            [ALDUtils showToast:msg];
        }
    }
}
@end
