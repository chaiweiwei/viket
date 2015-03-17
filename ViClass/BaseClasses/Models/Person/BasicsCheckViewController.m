//
//  CheckViewController.m
//  Glory
//  验证码
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsCheckViewController.h"
#import "BasicsPwdViewController.h"
#import "ALDUtils.h"
#import "BasicsUserInfoViewController.h"
#import "UserDao.h"

@interface BasicsCheckViewController ()<UITextFieldDelegate>
{
    int _waitTime;
}

@end

@implementation BasicsCheckViewController

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
    
    self.view.backgroundColor=KBgViewColor;
    
    if(!self.title || [self.title isEqualToString:@""]){
        self.title=@"填写验证码";
    }
    self.view.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
//    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
//    btn.frame=CGRectMake(0, 0, 60, 40);
//    [btn setTitle:@"下一步" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btn.tag=0x13;
//    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem=rightBtnItem;
    
    [self initUI];
    
    if (_hasVerifyCode) {
        self.verifyBtn.enabled=NO;
        if(self.timer){
            [self.timer invalidate];
            self.timer=nil;
        }
        _waitTime=0;
        self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
        [self.timer fire];
    }else{
        [self getCheckCode];
    }
}

-(void)initUI
{
    CGFloat startX=10.0f;
    CGFloat startY=self.baseStartY+15.0f;
    CGFloat viewWidth=CGRectGetWidth(self.view.frame);
    CGFloat width=viewWidth-20;
    CGFloat heigh=15.0f;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    //提示
    OHAttributedLabel *label=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(startX, startY, width, heigh)];
    NSString *text=@"我们将发送验证码短信到这个手机号";
    if (_hasVerifyCode) {
        text=@"我们已发送验证码短信到这个手机号";
    }
    self.tipsLabel=label;
    label.textAlignment=TEXT_ALIGN_CENTER;
    label.backgroundColor=[UIColor clearColor];
    NSMutableAttributedString *mutaString = [[NSMutableAttributedString alloc] initWithString:text];
    [mutaString setFont:[UIFont boldSystemFontOfSize:15.0]];
    [mutaString setTextColor:RGBCOLOR(130, 130, 130)];
    
    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle.textAlignment = kCTTextAlignmentCenter;
    [mutaString setParagraphStyle:paragraphStyle];
    
    NSRange range;
    NSInteger start=0;
    
    range=[text rangeOfString:@"验证码短信"];
    NSInteger location=range.location;
    if (location!=NSNotFound) {
        start=location;
        range.location=start;
        range.length=location;
        [mutaString setTextColor:RGBCOLOR(158, 0, 0) range:range];
        
    }
    label.attributedText=mutaString;
    [self.view addSubview:label];
    startY+=(heigh+10.0f);
    
    //电话号码
    UILabel *lab=[self createLabel:CGRectMake(startX, startY, width, 20.0f) textColor:KWordBlackColor textFont:[UIFont systemFontOfSize:14.0f]];
    lab.textAlignment=TEXT_ALIGN_CENTER;
    lab.text=[NSString stringWithFormat:@"+86  %@",self.phone];
    [self.view addSubview:lab];
    startY+=25.0f;
    
    //验证码
    UITextField *textField=[self createTextfield:CGRectMake(startX, startY, viewWidth-120-2*startX, 44.0f) title:@"验证码" placeholder:@"请输入收到的验证码"];//[self createTextField:CGRectMake(80.0f, startY, 160.0f, 55.0f) textColor:KWordBlackColor textFont:[UIFont boldSystemFontOfSize:25.0f]];
    textField.font=kFontSize30px;
    textField.layer.borderWidth=0.5;
    textField.layer.borderColor=KWordGrayColor.CGColor;
    textField.textAlignment=TEXT_ALIGN_Right;
    textField.keyboardType=UIKeyboardTypeNumberPad;
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.checkCodeText=textField;
    
    //获取验证码
    ALDButton *btn=[[ALDButton alloc] initWithFrame:CGRectMake(viewWidth-110, startY, 100, 44)];
    [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
    btn.layer.masksToBounds=YES;
    btn.layer.cornerRadius=6;
    [btn setBackgroundColor:KBtnBgColor];
    [btn setTitleColor:RGBCOLOR(255, 255, 255) forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont boldSystemFontOfSize:15];
    btn.tag=0x12;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.verifyBtn=btn;
    startY+=50.0f;
    
    //登录密码
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 40, 44);
    [btn setTitle:@"明文" forState:UIControlStateNormal];
    [btn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:12.0f];
    btn.tag=0x14;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor=[UIColor clearColor];
    
    textField=[self createTextfield:CGRectMake(startX, startY, viewWidth-2*startX, 44.0f) title:@"密  码" placeholder:@"请输入密码"];
    textField.rightViewMode=UITextFieldViewModeAlways;
    textField.rightView=btn;
    textField.secureTextEntry=YES;
    textField.layer.borderWidth=0.5;
    textField.layer.borderColor=KWordGrayColor.CGColor;
    textField.textAlignment=TEXT_ALIGN_Right;
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.pwdField=textField;
    startY+=50;
    
    textField=[self createTextfield:CGRectMake(startX, startY, viewWidth-2*startX, 44.0f) title:@"确认密码" placeholder:@"请确认密码"];
    textField.layer.borderWidth=0.5;
    textField.layer.borderColor=KWordGrayColor.CGColor;
    textField.textAlignment=TEXT_ALIGN_Right;
    textField.inputAccessoryView=topView;
    textField.secureTextEntry=YES;
    [self.view addSubview:textField];
    self.reEnterPwdField=textField;
    startY+=60;
    
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(startX, startY, viewWidth-2*startX, 44);
    [btn setTitle:@"完成注册" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:15.0f];
    btn.backgroundColor=[UIColor blueColor];
    btn.tag=0x13;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //取消
//            [self dismissViewControllerAnimated:YES completion:^{}];
        }
            break;
            
        case 0x12:{ //重发
            [self getCheckCode];
        }
            break;
            
        case 0x13:{ //提交，下一步
            NSString *code=self.checkCodeText.text;
            if(!code || [code isEqualToString:@""]){
                [ALDUtils showToast:@"请输入验证码!"];
                return;
            }
            
            NSString *pwd=self.pwdField.text;
            if (pwd==nil || [pwd isEqualToString:@""]) {
                [ALDUtils showToast:@"请输入密码"];
                [self.pwdField becomeFirstResponder];
                return;
            }
            NSString *reEnterPwd=self.reEnterPwdField.text;
            if (reEnterPwd==nil || [reEnterPwd isEqualToString:@""]) {
                [ALDUtils showToast:@"请确认密码"];
                [self.reEnterPwdField becomeFirstResponder];
                return;
            }else if (![reEnterPwd isEqualToString:pwd]){
                [ALDUtils showToast:@"两次输入的密码不一致，请确认！"];
                [self.reEnterPwdField becomeFirstResponder];
                return;
            }
            self.view.userInteractionEnabled=NO;
            [self hiddenKeyBorad];
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            if (self.token && ![self.token isEqualToString:@""]
                && self.preCode && [self.preCode isEqualToString:code]) {
                if (self.type==1) { //注册
                    [httpClient registerWithUser:self.phone pwd:pwd type:1 token:self.token invitationCode:nil];
                }else if(self.type==2){ //找回密码
                    [httpClient resetPassword:self.phone pwd:pwd token:self.token];
                }else if (self.type==3){ //设置支付密码
                    [httpClient modifyPayPassword:self.phone token:self.token payPassword:pwd];
                }
            }else{
                self.preCode=code;
                [httpClient verifyCode:self.phone type:self.type code:code];
            }
        }
            break;
            
        case 0x14:{ //明文/密文
            NSString *title=[sender titleForState:UIControlStateNormal];
            if([title isEqualToString:@"明文"]){
                title=@"密文";
                self.pwdField.secureTextEntry=NO;
                self.reEnterPwdField.secureTextEntry=NO;
            }else{
                self.pwdField.secureTextEntry=YES;
                self.reEnterPwdField.secureTextEntry=YES;
                title=@"明文";
            }
            [sender setTitle:title forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}

-(void) checkTime{
    if (_waitTime>=59) { //超时60秒
        [_verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        _verifyBtn.enabled=YES;
        [_timer invalidate];
        self.timer=nil;
        return;
    }
    _waitTime+=1;
    int time=60-_waitTime;
    [_verifyBtn setTitle:[ALDUtils formatLocalizedString:@"重新发送(%d)" key:@"regetInterval",time] forState:UIControlStateDisabled];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)gotoPwd:(NSString*) token{
    BasicsPwdViewController *controller=[[BasicsPwdViewController alloc] init];
    controller.title=@"设置登录密码";
    controller.type=self.type;
    controller.phone=self.phone;
    controller.token=token;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    
    [self.navigationController pushViewController:controller animated:YES];

//    ALDAppDelegate *appDelegate=(ALDAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.rootView pushViewController:controller animated:YES];
    
}

-(void)gotoUserInfo:(BOOL) cannotToNext
{
    BasicsUserInfoViewController *controller=[[BasicsUserInfoViewController alloc] init];
    controller.title=@"完善资料";
    controller.isEditInfo=NO;
    controller.loginDelegate=self.delegate;
    controller.cannotToNext=cannotToNext;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)hiddenKeyBorad{
    [self.checkCodeText resignFirstResponder];
    [self.pwdField resignFirstResponder];
    [self.reEnterPwdField resignFirstResponder];
    
}

-(void)getCheckCode{
    BasicsHttpClient *http=[BasicsHttpClient httpClientWithDelegate:self];
    http.needTipsNetError=YES;
    [http sendVerifyCode:self.phone withType:self.type];
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
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:frame];
    [textfield setBorderStyle:UITextBorderStyleNone]; //外框类型
    textfield.placeholder = placeholder; //默认显示的字
    textfield.textAlignment=TEXT_ALIGN_Right;
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

    if(title && ![title isEqualToString:@""]){
        CGSize size=[ALDUtils captureTextSizeWithText:title textWidth:100 font:kFontSize30px];
        UILabel *labletitle=[[UILabel alloc]initWithFrame:CGRectMake(0,0,size.width,frame.size.height)];
        labletitle.font=kFontSize30px;
        labletitle.text=title;
        labletitle.textAlignment=TEXT_ALIGN_LEFT;
        labletitle.numberOfLines=1;
        labletitle.adjustsFontSizeToFitWidth=YES;
        labletitle.textColor=KWordBlackColor;
        labletitle.backgroundColor=[UIColor clearColor];
        textfield.leftView=labletitle;
        textfield.leftViewMode=UITextFieldViewModeAlways;
    }
    
    return textfield;
}

-(UITextField *)createTextField:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UITextField *textField=[[UITextField alloc] initWithFrame:frame];
    textField.textColor=textColor;
    textField.font=textFont;
    textField.delegate=self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textField.layer.borderWidth=0.5f;
    textField.layer.borderColor=kLineColor.CGColor;
    textField.layer.masksToBounds=YES;
    textField.layer.cornerRadius=5.0f;
    textField.backgroundColor=[UIColor whiteColor];
    
    return textField;
}

-(void) dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if (requestPath==HttpRequestPathForSendVerifyCode) {
//        [self addWaitView:@"正在获取验证码,请稍候..."];
        [ALDUtils addWaitingView:self.view withText:@"正在获取验证码,请稍候..."];
    }else if (requestPath==HttpRequestPathForVerifyCode){
        [ALDUtils addWaitingView:self.view withText:@"请求处理中，请稍候..."];
    }else if (requestPath==HttpRequestPathForRegister){
        [ALDUtils addWaitingView:self.view withText:@"请求处理中，请稍候..."];
    }else if (requestPath==HttpRequestPathForResetPassword){
        [ALDUtils addWaitingView:self.view withText:@"请求处理中，请稍候..."];
    }else if(requestPath==HttpRequestPathForModifyPayPassword){
        [ALDUtils addWaitingView:self.view withText:@"请求处理中，请稍候..."];
    }
}

-(void) dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if (requestPath==HttpRequestPathForSendVerifyCode) {
        if(code==KOK){
            [ALDUtils showToast:@"验证码已发送到你的手机，请输入！"];
            if(self.timer){
                [self.timer invalidate];
                self.timer=nil;
            }
            self.verifyBtn.enabled=NO;
            _waitTime=0;
            self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
            [self.timer fire];
            
            NSString *text=@"我们已发送验证码短信到这个手机号";
            NSMutableAttributedString *mutaString = [[NSMutableAttributedString alloc] initWithString:text];
            [mutaString setFont:[UIFont boldSystemFontOfSize:15.0]];
            [mutaString setTextColor:RGBCOLOR(130, 130, 130)];
            
            OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
            paragraphStyle.textAlignment = kCTTextAlignmentCenter;
            [mutaString setParagraphStyle:paragraphStyle];
            
            NSRange range;
            NSInteger start=0;
            
            range=[text rangeOfString:@"验证码短信"];
            NSInteger location=range.location;
            if (location!=NSNotFound) {
                start=location;
                range.location=start;
                range.length=location;
                [mutaString setTextColor:RGBCOLOR(158, 0, 0) range:range];
            }
            self.tipsLabel.attributedText=mutaString;
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"获取验证码失败,请稍候再试!";
            }
            [ALDUtils showToast:errMsg];
        }
        [ALDUtils removeWaitingView:self.view];
    }else if (requestPath==HttpRequestPathForVerifyCode){ //验证验证码
        NSString *errorMsg=result.errorMsg;
        if (code==KOK) {
            NSString *token=result.obj;
            self.token=token;
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            if (self.type==1) { //注册
                [httpClient registerWithUser:_phone pwd:_pwdField.text type:1 token:token invitationCode:nil];
            }else if(self.type==2){ //找回密码
                [httpClient resetPassword:self.phone pwd:_pwdField.text token:token];
            }else if (self.type==3){ //设置支付密码
                [httpClient modifyPayPassword:self.phone token:self.token payPassword:_pwdField.text];
            }else{
                self.view.userInteractionEnabled=YES;
            }
            return;
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else if (code==kNO_RESULT){
            [ALDUtils showToast:@"验证码输入错误，请重输!"];
            [self.checkCodeText becomeFirstResponder];
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
            
            if(self.phone && ![self.phone isEqualToString:@""]){
                [config setObject:self.phone forKey:kUserNameKey];
            }
            int status=[bean.status integerValue];
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
    }else if (requestPath==HttpRequestPathForResetPassword){ //重置密码
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
            int status=[bean.status integerValue];
            [config setInteger:status forKey:KUserStatus];
            [config synchronize];
            
            if (status !=1 ) {
                [self gotoUserInfo:NO]; //跳转到完善信息
                return;
            }
            
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            [httpClient viewUserInfo:bean.uid];
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
                errorMsg=@"密码重置失败，请稍候再试!";
            }
            [ALDUtils showToast:errorMsg];
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
    }else if(requestPath==HttpRequestPathForModifyPayPassword){ //修改支付密码
        if (code==KOK) {
            [ALDUtils showToast:@"设置支付密码成功!"];
            self.view.userInteractionEnabled=YES;
            [ALDUtils removeWaitingView:self.view];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
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
                errorMsg=@"设置支付密码失败，请稍候再试!";
            }
            [ALDUtils showToast:errorMsg];
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
    }else if(requestPath==HttpRequestPathForUserInfo){
        NSString *uid=nil;
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *bean=(UserBean *)obj;
                bean.username=_phone;
                
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
        [ALDUtils removeWaitingView:self.view];
        if (_delegate && [_delegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
            if (!uid) {
                uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
            }
            [_delegate loginView:self doneWithCode:KOK withUser:uid];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidUnload{
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer=nil;
    self.checkCodeText=nil;
    [super viewDidUnload];
}

-(void)dealloc{
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer=nil;
    self.tipsLabel=nil;
    self.verifyBtn=nil;
    self.checkCodeText=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
