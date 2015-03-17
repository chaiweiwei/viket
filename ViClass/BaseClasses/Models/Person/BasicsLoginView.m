//
//  LoginView.m
//  BFEC
//
//  Created by alidao on 13-6-5.
//  Copyright (c) 2013年 alidao. All rights reserved.
//

#import "BasicsLoginView.h"
#import <QuartzCore/QuartzCore.h>
//#import "WBSinaEngine.h"
#import "ALDButton.h"
#import "BasicsRegisterViewController.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "UserDao.h"

@interface BasicsLoginView (){
    
}

@end

@implementation BasicsLoginView
@synthesize userNameText   = _userNameText;
@synthesize pwdText        = _pwdText;
@synthesize delegate       = _delegate;
@synthesize rootController = _rootController;

- (void)dealloc
{
    self.userNameText=nil;
    self.pwdText=nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
//        _hasVerify=NO;

        [self initUI:frame];

    }
    return self;
}

-(void)initUI:(CGRect)frame
{
    _realFrame=frame;
    CGFloat startY=20;
    CGFloat startX=0;
    CGFloat viewW=CGRectGetWidth(frame)-2*startX;
    CGFloat borderWidth=1;
    CGFloat cornerRadius=6;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    
    UIView *myview=[[UIView alloc]initWithFrame:CGRectMake(startX, startY, viewW, 89)];
    UIColor *viewBgColor=[UIColor whiteColor];
    myview.backgroundColor = viewBgColor;
    UIColor *color=kLayerBorderColor;
    myview.layer.borderColor =color.CGColor;
    myview.layer.borderWidth =borderWidth;
    myview.layer.cornerRadius =cornerRadius;
    [self addSubview:myview];
    
    CGFloat y=0;
    NSString *placeHolder=@"用户名";
    self.userNameText=[self createTextfield:CGRectMake(15,y,viewW-30,44) title:placeHolder placeholder:@"用户名/手机号"];
    _userNameText.returnKeyType=UIReturnKeyNext;
    _userNameText.keyboardType=UIKeyboardTypeEmailAddress;
    _userNameText.inputAccessoryView=topView;
    [myview addSubview:_userNameText];
    y+=_userNameText.frame.size.height;
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, y, viewW, borderWidth)];
    lineView.backgroundColor=color;
    [myview addSubview:lineView];
    y+=borderWidth;
    
    placeHolder=@"密   码";
    self.pwdText=[self createTextfield:CGRectMake(15,y,viewW-30,44.0f) title:placeHolder placeholder:@""];
    _pwdText.returnKeyType=UIReturnKeyGo;
    _pwdText.secureTextEntry = YES; //密码
    _pwdText.inputAccessoryView=topView;
    [myview addSubview:_pwdText];
    y+=_pwdText.frame.size.height;
    
    startY+=y+20;
    
    // 创建会员登录按钮
    ALDButton *logBt=[ALDButton buttonWithType:UIButtonTypeCustom];
    logBt.frame=CGRectMake(startX, startY, viewW-2*startX, 44);
    [logBt setTitle:@"登录" forState:UIControlStateNormal];
    logBt.layer.masksToBounds=YES;
    logBt.layer.cornerRadius=6;
    [logBt setBackgroundColor:KBtnLoginBgColor];
    [logBt setTitleColor:KBtnTitleColor forState:UIControlStateNormal];
    logBt.titleLabel.font=[UIFont boldSystemFontOfSize:18];
    logBt.tag=0x11;
    [logBt addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:logBt];
    startY+=logBt.frame.size.height;
    self.contentHeight=startY;
    
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBorad)];
    tapRecog.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapRecog];
}

- (id)initWithFrame:(CGRect)frame withRoot:(UIViewController*)root{
    self = [self initWithFrame:frame];
    if (self) {
        self.rootController=root;
    }
    return self;
}

-(void)getUserInfo{
    NSString *uid=[[NSUserDefaults standardUserDefaults] stringForKey:kUidKey];
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient viewUserInfo:uid];
}

-(void) hiddenKeyBorad{
    [_userNameText resignFirstResponder];
    [_pwdText resignFirstResponder];
}

-(void) requestFocus:(UITextField *) textField{
    [textField becomeFirstResponder];
}

//登录
-(void)btnPressed:(UIButton *)sender{
    switch (sender.tag) {
        case 0x11:{ //登录
            [self onLoginClicked];//判断登录信息是否正确
        }
            break;
            
        case 0x12:{ //忘记密码

        }
            break;
            
        default:
            break;
    }
}

-(void) onLoginClicked{
    NSString *username=_userNameText.text;
    if (!username || [username isEqualToString:@""]) {
        NSString *tips=@"请输入用户名/手机号";
        [ALDUtils showToast:tips];
        [_userNameText becomeFirstResponder];
        return;
    }
    NSString *codePass=_pwdText.text;
    if (!codePass || [codePass isEqualToString:@""]) {
        NSString *tips=@"请输入密码";
        [ALDUtils showToast:tips];
        [_pwdText becomeFirstResponder];
        return;
    }
    [self hiddenKeyBorad];

    BasicsHttpClient *http=[BasicsHttpClient httpClientWithDelegate:self];
    http.needTipsNetError=YES;
    [http loginWithUser:username pwd:codePass];
}

// 键盘右下角按钮相应处理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_userNameText) {
        [_pwdText becomeFirstResponder];//密码框获得焦点
    }else if (textField==_pwdText){
        [self onLoginClicked];//判断登录信息是否正确
    }
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(_realFrame.origin.x,_realFrame.origin.y, self.bounds.size.width, self.bounds.size.height);
    self.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 120 - (self.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.frame = rect;
    }
    [UIView commitAnimations];
}

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder{
    UILabel *labletitle=[[UILabel alloc]initWithFrame:CGRectMake(0,0,60,frame.size.height)];
    labletitle.font=kListTitleFont;
    labletitle.text=title;
    labletitle.textAlignment=TEXT_ALIGN_LEFT;
    labletitle.numberOfLines=1;
    labletitle.adjustsFontSizeToFitWidth=YES;
    labletitle.textColor=kLayerBorderColor;
    labletitle.backgroundColor=[UIColor clearColor];
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:frame];
    [textfield setBorderStyle:UITextBorderStyleNone]; //外框类型
    textfield.placeholder = placeholder; //默认显示的字
    textfield.textAlignment=TEXT_ALIGN_LEFT;
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textfield.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    textfield.font=[UIFont boldSystemFontOfSize:17];
    textfield.keyboardType=UIKeyboardTypeDefault;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    textfield.delegate = self;
    textfield.backgroundColor=RGBCOLOR(255, 255, 255);
    textfield.leftView=labletitle;
    textfield.leftViewMode=UITextFieldViewModeAlways;

    return textfield;
}

-(void) dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if (requestPath==HttpRequestPathForLogin) {
        [ALDUtils addWaitingView:self withText:@"登录中,请稍候..."];
    }else if (requestPath==HttpRequestPathForAppid){
        [ALDUtils addWaitingView:self withText:@"登录中,请稍候..."];
    }else if(requestPath==HttpRequestPathForUserInfo){
        [ALDUtils addWaitingView:self withText:@"加载中,请稍候..."];
    }
}

-(void) dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if (requestPath==HttpRequestPathForAppid) {
        if (code==KOK) {
            BasicsHttpClient *http=[BasicsHttpClient httpClientWithDelegate:self];
            http.needTipsNetError=YES;
            [http loginWithUser:_userNameText.text pwd:_pwdText.text];
        }else if (code!=kNET_ERROR && code!=kNET_TIMEOUT){
            [ALDUtils removeWaitingView:self];
            [ALDUtils showToast:@"获取验证码失败，请稍侯再试!"];
        }
    }else if(requestPath==HttpRequestPathForLogin){
        [ALDUtils removeWaitingView:self];
        NSString *msg=result.errorMsg;
        if (code==KOK) {
            UserBean *user=(UserBean *)result.obj;
            if (user) {
                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
                [config setObject:user.uid forKey:kUidKey];
                [config setObject:user.sessionKey forKey:kSessionIdKey];
                [config setObject:_userNameText.text forKey:kUserNameKey];
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
                
                if(status==1){
                    [self getUserInfo];
                    return;
                }else{
                    if (_delegate && [_delegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
                        [_delegate loginView:_rootController doneWithCode:401 withUser:nil];
                    }
                }
            }else{
                msg=@"登录失败，请稍侯再试!";
            }
        }else if (code==kNO_RESULT){
            if (!msg || [msg isEqualToString:@""]) {
                msg=@"登录失败，请确认用户名或密码是否正确!";
            }
            
        }else if (code!=kNET_ERROR && code!=kNET_TIMEOUT){
            if (!msg || [msg isEqualToString:@""]) {
                msg=@"登录失败，请稍侯再试!";
            }
        }else{
            msg=@"网络异常，请确认是否已连接!";
        }
        [ALDUtils showToast:msg];
    }else if(requestPath==HttpRequestPathForUserInfo){
        NSString *uid=nil;
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *bean=(UserBean *)obj;
                bean.username=_userNameText.text;
                
                NSString *text=bean.userInfo.nickname;
                
                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
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
        [ALDUtils removeWaitingView:self];
        if (_delegate && [_delegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
            if (!uid) {
                uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
            }
            [_delegate loginView:_rootController doneWithCode:KOK withUser:uid];
        }
    }
    [ALDUtils removeWaitingView:self];
}

@end
