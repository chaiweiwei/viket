//
//  RegisterViewController.m
//  Glory
//  手机号验证码注册
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsRegisterViewController.h"
#import "BasicsCheckViewController.h"
#import "NSDictionaryAdditions.h"

@interface BasicsRegisterViewController ()<UITextFieldDelegate>

@end

@implementation BasicsRegisterViewController

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
    
    if(!self.title || [self.title isEqualToString:@""]){
        self.title=@"注册";
    }
    
    //下一步
    if(self.type==2){
        ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, 60.0f, 44.0f);
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        [btn setTitleColor:KOrangeColor forState:UIControlStateNormal];
        btn.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        btn.backgroundColor=[UIColor clearColor];
        btn.selectBgColor=[UIColor clearColor];
        btn.tag=0x15;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem=rightBtnItem;
    }
    
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}

-(void)initUI
{
    CGFloat startX=10.0f;
    CGFloat startY=self.baseStartY+15.0f;
    CGRect viewFrame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(viewFrame);
    CGFloat width=viewWidth-2*startX;
    CGFloat heigh=15.0f;
    UIFont *textFont=[UIFont systemFontOfSize:15.0f];
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    UILabel *label=[self createLabel:CGRectMake(startX, startY, width, 20) textColor:KRegisterTipColor textFont:KRegisterTipFont];
    label.textAlignment=TEXT_ALIGN_CENTER;
    label.text=KRegisterTip;
    [self.view addSubview:label];
    startY+=(heigh+20.0f);
    
    //国家和地区
    UITextField *textField=[self createTextField:CGRectMake(startX, startY, width, 44.0f) textColor:KWordBlackColor textFont:[UIFont boldSystemFontOfSize:17.0f]];
    textField.text=@"中国";
    textField.userInteractionEnabled=NO;
    textField.textAlignment=TEXT_ALIGN_Right;
    [self.view addSubview:textField];
    UILabel *leftView=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44.0f)];
    leftView.textColor=KRegisterTipColor;
    leftView.text=@"  国家和地区";
    leftView.font=KRegisterTipFont;
    leftView.backgroundColor=[UIColor clearColor];
    textField.leftViewMode=UITextFieldViewModeAlways;
    textField.leftView=leftView;
    UIView *rightView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 44.0f)];
    rightView.backgroundColor=[UIColor clearColor];
    textField.rightViewMode=UITextFieldViewModeAlways;
    textField.rightView=rightView;
    
    
    //国家
//    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
//    btn.frame=CGRectMake(260, startY, 40, 44.0f);
//    [btn setTitle:@"中国" forState:UIControlStateNormal];
//    btn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
//    [btn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
//    btn.backgroundColor=[UIColor clearColor];
//    btn.selectBgColor=[UIColor clearColor];
//    [self.view addSubview:btn];
    
    startY+=54.0f;
    textFont=[UIFont boldSystemFontOfSize:17.0f];
    //区号
    textField=[self createTextField:CGRectMake(startX, startY, 80.0f, 44.0f) textColor:KRegisterTipColor textFont:textFont];
    textField.textAlignment=TEXT_ALIGN_CENTER;
    textField.text=@"+86";
    textField.userInteractionEnabled=NO;
    [self.view addSubview:textField];
    
    //电话号码
    leftView=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 44.0f)];
    textField=[self createTextField:CGRectMake(startX+85.0f, startY, width-85.0f, 44.0f) textColor:KWordBlackColor textFont:textFont];
    textField.textAlignment=TEXT_ALIGN_Right;
    textField.leftViewMode=UITextFieldViewModeAlways;
    textField.leftView=leftView;
    textField.placeholder=@"请输入手机号码";
    textField.inputAccessoryView=topView;
    textField.keyboardType=UIKeyboardTypeNumberPad;
    [self.view addSubview:textField];
    self.phoneText=textField;
    startY+=50.0f;
    
    if(self.type==1){
        //用户协议
        /*
        NSString *text=@"点击下一步表示同意";
        CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:width font:[UIFont systemFontOfSize:14.0f]];
        label=[[UILabel alloc] initWithFrame:CGRectMake(startX, startY, size.width, 20.0f)];
        label.font=[UIFont systemFontOfSize:14.0f];
        label.text=text;
        label.textColor=KWordGrayColor;
        label.backgroundColor=[UIColor clearColor];
        [self.view addSubview:label];
        
        ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(startX+size.width, startY, 60, 20);
        [btn setTitle:@"用户协议" forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [btn setTitleColor:RGBCOLOR(255, 154, 80) forState:UIControlStateNormal];
        btn.tag=0x13;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor=[UIColor clearColor];
        [self.view addSubview:btn];
        
        UIView *line=[[UIView alloc] initWithFrame:CGRectMake(startX+size.width, startY+18, 60.0f, 1.0f)];
        line.backgroundColor=RGBCOLOR(255, 154, 80);
        [self.view addSubview:line];
         */
        ALDButton *btn=[self createBtn:CGRectMake(startX, startY, 15, 15) textColor:KWordBlackColor textFont:[UIFont systemFontOfSize:10]];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_check_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_check_selected"] forState:UIControlStateSelected];
        btn.selected=isSelect;
        btn.tag=0x11;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        NSString *text=@"我已阅读并同意";
        CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:(viewWidth-2*startX) font:kFontSize26px];
        size.width+=5;
        UILabel *label=[self createLabel:CGRectMake(startX+15, startY, size.width, 15) textColor:KWordBlackColor textFont:kFontSize26px];
        label.text=text;
        [self.view addSubview:label];
        
        startX=startX+size.width+10;
        text=[NSString stringWithFormat:@"《%@服务条款》",kSoftwareName];
        size=[ALDUtils captureTextSizeWithText:text textWidth:(viewWidth-2*startX) font:kFontSize26px];
        size.width+=60;
        btn=[self createBtn:CGRectMake(startX, startY, size.width, 15) textColor:[UIColor blueColor] textFont:kFontSize26px];
        [btn setTitle:text forState:UIControlStateNormal];
        btn.tag=0x12;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        startY+=15;
        
        startX=10;
        text=@"您的手机号码仅用户接受验证码,我们不会在任何地方泄露您的手机号码!";
        size=[ALDUtils captureTextSizeWithText:text textWidth:(viewWidth-2*startX) font:kFontSize24px];
        label=[self createLabel:CGRectMake(startX, startY, viewWidth-2*startX, size.height) textColor:KWordGrayColor textFont:kFontSize24px];
        label.numberOfLines=0;
        label.text=text;
        [self.view addSubview:label];
        startY+=size.height;
        
        startY+=10;
        btn=[self createBtn:CGRectMake(startX, startY, viewWidth-2*startX, 44.f) textColor:KWordWhiteColor textFont:kFontSize32px];
        [btn setTitle:@"下一步" forState:UIControlStateNormal];
        btn.backgroundColor=KBtnBgColor;
        btn.tag=0x13;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    //底部部分
    textFont=[UIFont systemFontOfSize:16.0f];
    startY=CGRectGetHeight(viewFrame)-60-25-20;
    label=[self createLabel:CGRectMake(startX, startY, width, 25) textColor:KWordBlackColor textFont:textFont];
    label.textAlignment=TEXT_ALIGN_CENTER;
    label.text=@"如需帮助请致电";
    [self.view addSubview:label];
    label.hidden=self.hiddenBottom;
    startY+=label.frame.size.height;
    
    UIColor *color=RGBCOLOR(255, 136, 34);
    CGRect btnFrame=CGRectMake(startX, startY, 60, 20);
    ALDButton *btn=[[ALDButton alloc] initWithFrame:btnFrame];
    [btn setTitle:kServiceNumber forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.titleLabel.font=textFont;
    btn.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    btn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [btn setBackgroundColor:[UIColor clearColor]];
    btn.tag=0x14;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    CGSize size=[ALDUtils captureTextSizeWithText:[btn titleForState:UIControlStateNormal] textWidth:2000.f font:btn.titleLabel.font];
    startX=(CGRectGetWidth(viewFrame)-size.width)/2.f;
    btnFrame.origin.x=startX;
    btnFrame.size.width=size.width;
    btn.frame=btnFrame;
    btn.hidden=self.hiddenBottom;
    
    startY+=btnFrame.size.height;
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(startX-2, startY, size.width+2, 1)];
    lineView.backgroundColor=color;
    lineView.hidden=self.hiddenBottom;
    [self.view addSubview:lineView];
}

-(void)hiddenKeyBorad{
    [self.phoneText resignFirstResponder];
}

-(void)gotoCheckVC:(NSString *)phone hasVerifyCode:(BOOL) sendedCode{
    BasicsCheckViewController *controller=[[BasicsCheckViewController alloc] init];
    controller.phone=phone;
    controller.title=@"填写验证码";
    controller.type=self.type;
    controller.delegate=self.delegate;
    controller.hasVerifyCode=sendedCode;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)gotoUserDelegate
{
//    HelpViewController *controller=[[HelpViewController alloc] init];
//    controller.title=@"用户协议";
//    controller.urlStr=[kServerUrl stringByAppendingString:@"res/agree.jsp"];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
//    self.navigationItem.backBarButtonItem=backItem;
//    [self.navigationController pushViewController:controller animated:YES];
}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //下一步
            sender.selected=!sender.selected;
        }
            break;
        case 0x12:{ //用户协议
            [self gotoUserDelegate];
        }
            break;
            
        case 0x13:{ //下一步
            [self hiddenKeyBorad];
            
            NSString *phone=self.phoneText.text;
            if (!phone || [phone isEqualToString:@""]) {
                NSString *tips=@"请输入手机号码!";
                [ALDUtils showToast:tips];
                [self.phoneText becomeFirstResponder];
                return;
            }else if(![ALDUtils isValidateMobile:phone]){
                [ALDUtils showToast:@"请输入合法的手机号码!"];
                [self.phoneText becomeFirstResponder];
                return;
            }else{
                ALDButton *btn=(ALDButton *)[self.view viewWithTag:0x11];
                if (!btn.selected) {
                    [ALDUtils showToast:@"请先阅读并同意用户协议！"];
                    return;
                }
                self.view.userInteractionEnabled=NO;
                [self hiddenKeyBorad];
                
                BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                [httpClient userDataVerify:nil mobile:phone email:nil];
            }

        }
            break;
            
        case 0x14:{ //致电客服热线
            NSString *url=[NSString stringWithFormat:@"tel:%@",kServiceNumber];
            if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]) {
                [ALDUtils showToast:@"抱歉你的设备不支持电话功能!"];
            }
        }
            break;
            
        case 0x15:{
            NSString *phone=self.phoneText.text;
            if (!phone || [phone isEqualToString:@""]) {
                NSString *tips=@"请输入手机号码!";
                [ALDUtils showToast:tips];
                [self.phoneText becomeFirstResponder];
                return;
            }else if(![ALDUtils isValidateMobile:phone]){
                [ALDUtils showToast:@"请输入合法的手机号码!"];
                [self.phoneText becomeFirstResponder];
                return;
            }
            self.view.userInteractionEnabled=NO;
            [self hiddenKeyBorad];
            
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            [httpClient userDataVerify:nil mobile:phone email:nil];
        }
            break;
            
        default:
            break;
    }
}

-(ALDButton *)createBtn:(CGRect)frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=frame;
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    btn.titleLabel.font=textFont;
    btn.backgroundColor=[UIColor clearColor];
    
    return btn;
}

-(UILabel *)createLabel:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}

-(UITextField *)createTextField:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UITextField *textField=[[UITextField alloc] initWithFrame:frame];
    textField.textColor=textColor;
    textField.font=textFont;
    textField.delegate=self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textField.backgroundColor=[UIColor whiteColor];
    textField.layer.borderColor =kLayerBorderColor.CGColor;
    textField.layer.borderWidth =1;
    textField.layer.cornerRadius =5;
    textField.layer.masksToBounds=YES;
    
    return textField;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if (requestPath==HttpRequestPathForUserDataVerify) {
        [ALDUtils addWaitingView:self.view withText:@"正在获取验证码,请稍候..."];
    }else if (requestPath==HttpRequestPathForSendVerifyCode) {
        [ALDUtils addWaitingView:self.view withText:@"正在获取验证码,请稍候..."];
    }
}

-(void) dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if (requestPath==HttpRequestPathForUserDataVerify) {
        if (code==KOK) {
            NSDictionary *dic=result.obj;
            int nameexist=[[dic objectForKey_NONULL:@"mobile"] intValue];
            if (nameexist==1) {
                if (self.type==1) { //注册
                    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                    [httpClient sendVerifyCode:_phoneText.text withType:1];
                    return;
                }else{
                    //找回密码
                    [ALDUtils showToast:@"获取验证码失败，该手机号尚未注册!"];
                }
            }else if (nameexist==0){
                if (self.type==1) {
                    [ALDUtils showToast:@"获取验证码失败，该手机号已注册！"];
                }else{ //找回密码
                    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                    [httpClient sendVerifyCode:_phoneText.text withType:2];
                    return;
                }
            }else{
                [ALDUtils showToast:@"获取验证码失败，用户名格式错误!"];
            }
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"获取验证码失败，网络异常！"];
        }else{
            [ALDUtils showToast:@"获取验证码失败，请稍候再试!"];
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
    }else if (requestPath==HttpRequestPathForSendVerifyCode) {
        if(code==KOK){
            [ALDUtils showToast:@"验证码已发送到你的手机，请输入！"];
            [self gotoCheckVC:_phoneText.text hasVerifyCode:YES];
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"获取验证码失败,请稍候再试!";
            }
            [ALDUtils showToast:errMsg];
        }
        self.navigationItem.rightBarButtonItem.enabled=YES;
        self.view.userInteractionEnabled=YES;
    }
    [ALDUtils removeWaitingView:self.view];
}

-(void)dealloc{
    self.phoneText=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
