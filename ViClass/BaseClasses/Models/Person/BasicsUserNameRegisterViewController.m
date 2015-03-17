//
//  UserNameRegisterViewController.m
//  Basics
//  用户名+密码注册
//  Created by alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsUserNameRegisterViewController.h"
#import "ALDButton.h"
#import "NSDictionaryAdditions.h"
#import "BasicsUserInfoViewController.h"
#import "UserBean.h"

@interface BasicsUserNameRegisterViewController ()<UITextFieldDelegate>

@property (nonatomic,retain) UITextField *userNameField; //用户名
@property (nonatomic,retain) UITextField *pwdField; //密码
@property (nonatomic,retain) UITextField *okPwdField; //确认密码

@end

@implementation BasicsUserNameRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

-(void)initUI
{
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat heigh=44.f;
    CGFloat startX=0;
    CGFloat startY=10;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    
    //用户名
    UIView *line=[self createLine:CGRectMake(0, startY, viewWidth, 0.5f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    UITextField *textField=[self createTextfield:CGRectMake(0, startY, viewWidth, heigh) title:@"  用户名" placeholder:@"6~12位字母加数字"];
    textField.secureTextEntry=NO;
    textField.inputAccessoryView=topView;
    textField.returnKeyType=UIReturnKeyNext;
    [self.view addSubview:textField];
    self.userNameField=textField;
    startY+=heigh;
    
    //密码
    line=[self createLine:CGRectMake(0, startY, viewWidth, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    textField=[self createTextfield:CGRectMake(0, startY, viewWidth, heigh) title:@"  密码" placeholder:@"请输入密码"];
    textField.inputAccessoryView=topView;
    textField.returnKeyType=UIReturnKeyNext;
    [self.view addSubview:textField];
    self.pwdField=textField;
    startY+=heigh;
    
    //确认密码
    line=[self createLine:CGRectMake(0, startY, viewWidth, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    textField=[self createTextfield:CGRectMake(0, startY, viewWidth, heigh) title:@"  确认密码" placeholder:@"请再次输入密码"];
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.okPwdField=textField;
    startY+=heigh;
    
    line=[self createLine:CGRectMake(0, startY,viewWidth, 1.0f)];
    [self.view addSubview:line];
    startY+=11;
    
    startX=10;
    ALDButton *btn=[self createBtn:CGRectMake(startX, startY, 15, 15) textColor:KWordBlackColor textFont:[UIFont systemFontOfSize:10]];
    //btn.selected=YES;
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_check_normal"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_check_selected"] forState:UIControlStateSelected];
    btn.tag=0x11;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    NSString *text=@"我已阅读并同意";
    CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:(viewWidth-2*startX) font:kFontSize26px];
    size.width+=5;
    UILabel *label=[self createLabel:CGRectMake(startX+15, startY, size.width, 15) textColor:KWordBlackColor textFont:kFontSize26px];
    label.text=text;
    [self.view addSubview:label];
    
    startX=startX+size.width;
    text=[NSString stringWithFormat:@"《%@服务条款》",kSoftwareName];
    size=[ALDUtils captureTextSizeWithText:text textWidth:(viewWidth-2*startX) font:kFontSize26px];
    size.width+=30;
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
    btn.backgroundColor=[UIColor greenColor];
    btn.tag=0x13;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //同意协议
            sender.selected=!sender.selected;
        }
            break;
            
        case 0x12:{ //用户协议
//            HelpViewController *controller=[[HelpViewController alloc] init];
//            controller.title=@"用户协议";
//            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
//            self.navigationItem.backBarButtonItem=backItem;
//            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        case 0x13:{ //下一步
            NSString *name=self.userNameField.text;
            if(!name || [name isEqualToString:@""]){
                [self.userNameField becomeFirstResponder];
                [ALDUtils showToast:@"请输入用户名!"];
                return;
            }
            
            NSString *pwd=self.pwdField.text;
            if(!pwd || [pwd isEqualToString:@""]){
                [self.pwdField becomeFirstResponder];
                [ALDUtils showToast:@"请输入密码!"];
                return;
            }
            
            NSString *okPwd=self.okPwdField.text;
            if(!okPwd || [okPwd isEqualToString:@""]){
                [self.okPwdField becomeFirstResponder];
                [ALDUtils showToast:@"请确定密码!"];
                return;
            }
            
            if(![pwd isEqualToString:okPwd]){
                [self.okPwdField becomeFirstResponder];
                [ALDUtils showToast:@"两次输入的密码不一致!"];
                return;
            }
            
            ALDButton *btn=(ALDButton *)[self.view viewWithTag:0x11];
            if (!btn.selected) {
                [ALDUtils showToast:@"请先阅读并同意用户协议！"];
                return;
            }
            
            self.view.userInteractionEnabled=NO;
            [self hiddenKeyBorad];
            //先验证用户名是否被占用
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            [httpClient userDataVerify:name mobile:nil email:nil];
        }
            break;
            
        default:
            break;
    }
}

-(void)hiddenKeyBorad
{
    [self.userNameField resignFirstResponder];
    [self.pwdField resignFirstResponder];
    [self.okPwdField resignFirstResponder];
}

-(UIView *)createLine:(CGRect )frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
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

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder{
    /*
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];*/
    
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
    textfield.leftView=labletitle;
    textfield.leftViewMode=UITextFieldViewModeAlways;
    
    return textfield;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if (requestPath==HttpRequestPathForUserDataVerify) {
        [ALDUtils addWaitingView:self.view withText:@"请求处理中，请稍候..."];
    }else if (requestPath==HttpRequestPathForRegister){
        [ALDUtils addWaitingView:self.view withText:@"请求处理中，请稍候..."];
    }
}

-(void) dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if (requestPath==HttpRequestPathForUserDataVerify) {
        if (code==KOK) {
            NSDictionary *dic=result.obj;
            int nameexist=[[dic objectForKey_NONULL:@"username"] intValue];
            if (nameexist==1) {
                BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
                [httpClient registerWithUser:_userNameField.text pwd:_pwdField.text type:2 token:nil invitationCode:nil];
                return;
            }else if (nameexist==0){
                [ALDUtils showToast:@"注册失败，用户名已被占用！"];
            }else{
                [ALDUtils showToast:@"注册失败，用户名格式错误!"];
            }
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:@"注册失败，网络异常！"];
        }else{
            [ALDUtils showToast:@"注册失败，请稍候再试!"];
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
    }else if (requestPath==HttpRequestPathForRegister) {
        NSString *errorMsg=result.errorMsg;
        if (code==KOK) {
            UserBean *bean=result.obj;
            NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
            [config setObject:bean.uid forKey:kUidKey];
            [config setObject:bean.sessionKey forKey:kSessionIdKey];
            [config synchronize];
            
            BasicsUserInfoViewController *controller=[[BasicsUserInfoViewController alloc] init];
            controller.title=@"完善资料";
            controller.isEditInfo=NO;
            controller.loginDelegate=self.delegate;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem=backItem;
            [self.navigationController pushViewController:controller animated:YES];
            
            self.view.userInteractionEnabled=YES;
            [ALDUtils removeWaitingView:self.view];
            return;
        }else if (code==kNET_ERROR || code==kNET_TIMEOUT){
            errorMsg=@"注册失败，网络异常！";
        }else if (code==kNO_RESULT){
            if (!errorMsg || [errorMsg isEqualToString:@""]) {
                errorMsg=@"注册失败，用户名已被占用！";
            }
        }else if (code==2){
            if (!errorMsg || [errorMsg isEqualToString:@""]) {
                errorMsg=@"注册失败，验证码不对或已失效！";
            }
        }else{
            if (!errorMsg || [errorMsg isEqualToString:@""]) {
                errorMsg=@"注册失败，请稍候再试！";
            }
        }
        self.view.userInteractionEnabled=YES;
        [ALDUtils removeWaitingView:self.view];
        [ALDUtils showToast:errorMsg];
    }
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
