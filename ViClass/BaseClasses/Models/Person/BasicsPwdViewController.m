//
//  PwdViewController.m
//  Glory
//  设置密码/修改密码
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsPwdViewController.h"
#import "ALDButton.h"
#import "ALDUtils.h"
#import "BasicsUserInfoViewController.h"
#import "AppDelegate.h"
#import "BasicsHttpClient.h"
#import "UserDao.h"

@interface BasicsPwdViewController ()<UITextFieldDelegate,DataLoadStateDelegate>

@property (retain,nonatomic) UITextField *pwdText;
@property (retain,nonatomic) UITextField *okPwdText;

@end

@implementation BasicsPwdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame=self.view.bounds;
    UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    bgView.backgroundColor=KBgViewColor;
    [self.view addSubview:bgView];
    
    if(!self.title || [self.title isEqualToString:@""]){
        self.title=@"设置密码";
    }
    
    NSString *title=@"完成";
//    if(self.type==1){
//        title=@"下一步";
//    }
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 60, 40);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor clearColor];
    btn.selectBgColor=[UIColor clearColor];
    btn.tag=0x11;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightBtnItem;
    
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}

-(void)initUI
{
    CGFloat startX=10.0f;
    CGFloat startY=self.baseStartY+10.0f;
    CGFloat heigh=44.0f;
    
    CGRect viewFrame=self.view.frame;
    CGFloat width=CGRectGetWidth(viewFrame);
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(viewFrame), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    
    //密码
    UIView *line=[self createLine:CGRectMake(0, startY, width, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    UITextField *textField=[self createTextfield:CGRectMake(0, startY, width, heigh) title:@"  密码" placeholder:@"请输入密码"];
    textField.inputAccessoryView=topView;
    textField.returnKeyType=UIReturnKeyNext;
    [self.view addSubview:textField];
    self.pwdText=textField;
    startY+=heigh;
    
    //确认密码
    line=[self createLine:CGRectMake(0, startY, CGRectGetWidth(viewFrame), 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    textField=[self createTextfield:CGRectMake(0, startY, width, heigh) title:@"  确认密码" placeholder:@"请再次输入密码"];
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.okPwdText=textField;
    startY+=heigh;
    
    line=[self createLine:CGRectMake(0, startY, CGRectGetWidth(viewFrame), 1.0f)];
    [self.view addSubview:line];
    startY+=11;
    
    UILabel *label=[self createLabel:CGRectMake(startX, startY, width-2*startX, 20) textColor:RGBCOLOR(130, 130, 130) textFont:[UIFont systemFontOfSize:13]];
    label.text=@"密码6~16位由英文字母和数字组成";
    [self.view addSubview:label];
    
}
//跳至完善信息界面
-(void)gotoUserInfo:(NSString *)pwd{
    BasicsUserInfoViewController *controller=[[BasicsUserInfoViewController alloc] init];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //完成
            [self submit];
        }
            break;
        default:
            break;
    }
}

-(void)submit
{
    NSString *text=self.pwdText.text;
    if(!text || [text isEqualToString:@""]){
        [ALDUtils showToast:@"请输入密码!"];
        [self.pwdText becomeFirstResponder];
        return;
    }else if(text.length<6){
        [ALDUtils showToast:@"请输入6位或以上密码!"];
        [self.pwdText becomeFirstResponder];
        return;
    }else if (text.length>16){
        [ALDUtils showToast:@"密码长度不能超过16位!"];
        [self.pwdText becomeFirstResponder];
        return;
    }
    
    NSString *textStr=self.okPwdText.text;
    if(!textStr || [textStr isEqualToString:@""]){
        [ALDUtils showToast:@"请确认密码!"];
        [self.okPwdText becomeFirstResponder];
        return;
    }else if(![text isEqualToString:textStr]){
        [ALDUtils showToast:@"两次密码输入不一致,请重新输入"];
        [self.okPwdText becomeFirstResponder];
        return;
    }
    [self hiddenKeyBorad];
    
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    if (self.type==1) { //注册
        [httpClient registerWithUser:self.phone pwd:text type:1 token:self.token invitationCode:nil];
    }else if (self.type==2){ //重置密码
        [httpClient resetPassword:self.phone pwd:text token:self.token];
    }
}

-(void)hiddenKeyBorad{
    [self.pwdText resignFirstResponder];
    [self.okPwdText resignFirstResponder];
}

-(UILabel *)createLabel:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder{
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    UILabel *labletitle=[[UILabel alloc]initWithFrame:CGRectMake(0,0,80,frame.size.height)];
    labletitle.font=[UIFont systemFontOfSize:15.0f];
    labletitle.text=title;
    labletitle.textAlignment=TEXT_ALIGN_LEFT;
    labletitle.numberOfLines=1;
    labletitle.adjustsFontSizeToFitWidth=YES;
    labletitle.textColor=KWordBlackColor;
    labletitle.backgroundColor=[UIColor clearColor];
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:frame];
    [textfield setBorderStyle:UITextBorderStyleNone]; //外框类型
    textfield.placeholder = placeholder; //默认显示的字
    textfield.textAlignment=TEXT_ALIGN_LEFT;
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textfield.textColor=KWordBlackColor;
    textfield.secureTextEntry=YES;
    textfield.font=[UIFont boldSystemFontOfSize:17.0f];
    textfield.keyboardType=UIKeyboardTypeDefault;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    textfield.delegate = self;
    textfield.backgroundColor=[UIColor whiteColor];
    textfield.leftView=labletitle;
    textfield.leftViewMode=UITextFieldViewModeAlways;
    
    return textfield;
}

-(UIView *)createLine:(CGRect )frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if(requestPath==HttpRequestPathForRegister){
        [ALDUtils addWaitingView:self.view withText:@"请求中，请稍候..."];
    }else if (requestPath==HttpRequestPathForResetPassword){
        [ALDUtils addWaitingView:self.view withText:@"请求中，请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForRegister){
        NSString *msg=result.errorMsg;
        if(code==KOK){
            UserBean *user=(UserBean *)result.obj;
            if (user) {
                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
                [config setObject:user.uid forKey:kUidKey];
                [config setObject:user.sessionKey forKey:kSessionIdKey];
                [config setObject:self.phone forKey:kUserNameKey];
                [config synchronize];
                
                BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                [httpClient viewUserInfo:nil];
                return;
            }else{
                msg=@"注册失败，请稍侯再试!";
                [ALDUtils showToast:msg];
            }
        } else if (code==kNO_RESULT){ //验证码错误
            if (!msg || [msg isEqualToString:@""]) {
                msg=@"验证码输入错误，请重输!";
            }
            [ALDUtils showToast:msg];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        } else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:ALDLocalizedString(@"net error", @"网络异常，请确认是否已连接!")];
        } else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"注册失败，请稍候再试!";
            }
            [ALDUtils showToast:errMsg];
        }
        [ALDUtils removeWaitingView:self.view];
    }else if(requestPath==HttpRequestPathForResetPassword){
        NSString *msg=result.errorMsg;
        if(code==KOK){
            UserBean *user=(UserBean *)result.obj;
            if (user) {
//                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
//                [config setObject:user.uid forKey:kUidKey];
//                [config setObject:user.sessionKey forKey:kSessionIdKey];
//                [config setObject:self.phone forKey:kUserNameKey];
//                [config synchronize];
                
                if(self.type==2){ //如果是找回密码则需要重新登录
                    NSArray *viewControllers=self.navigationController.viewControllers;
                    NSInteger count=viewControllers.count;
                    if(count>=4){
                        [self.navigationController popToViewController:[viewControllers objectAtIndex:count-4] animated:YES];
                    }
                }else{
                    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                    [httpClient viewUserInfo:user.uid];
                }
                return;
            }else{
                msg=@"重置密码失败，请稍侯再试!";
                [ALDUtils showToast:msg];
            }
        } else if (code==kNO_RESULT){ //验证码错误
            if (!msg || [msg isEqualToString:@""]) {
                msg=@"验证码输入错误，请重输!";
            }
            [ALDUtils showToast:msg];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        } else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:ALDLocalizedString(@"net error", @"网络异常，请确认是否已连接!")];
        } else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"重置密码失败，请稍候再试!";
            }
            [ALDUtils showToast:errMsg];
        }
        [ALDUtils removeWaitingView:self.view];
    }else if(requestPath==HttpRequestPathForUserInfo){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *bean=(UserBean *)obj;
                bean.mobile=self.phone;
                UserDao *dao=[[UserDao alloc] init];
                [dao addUser:bean];
            }
        }
        [ALDUtils removeWaitingView:self.view];

        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    self.pwdText=nil;
    self.okPwdText=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
