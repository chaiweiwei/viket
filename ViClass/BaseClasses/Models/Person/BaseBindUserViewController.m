//
//  BaseBindUserViewController.m
//  carlife
//  绑定已有账号
//  Created by alidao on 15/1/21.
//  Copyright (c) 2015年 chen yulong. All rights reserved.
//

#import "BaseBindUserViewController.h"
#import "ALDButton.h"
#import "AppDelegate.h"
#import "BasicsUserInfoViewController.h"
#import "NSDictionaryAdditions.h"
#import "BasicsRegisterViewController.h"

@interface BaseBindUserViewController ()<UITextFieldDelegate,DataLoadStateDelegate>


@end

@implementation BaseBindUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

-(void)initUI
{
    CGFloat startY=20;
    CGFloat startX=0;
    CGFloat viewWidth=CGRectGetWidth(self.view.frame)-2*startX;
    CGFloat borderWidth=1;
    CGFloat cornerRadius=6;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [topView setItems:buttonsArray];
    
    UIView *myview=[[UIView alloc]initWithFrame:CGRectMake(startX, startY, viewWidth, 89)];
    UIColor *viewBgColor=[UIColor whiteColor];
    myview.backgroundColor = viewBgColor;
    UIColor *color=kLayerBorderColor;
    myview.layer.borderColor =color.CGColor;
    myview.layer.borderWidth =borderWidth;
    myview.layer.cornerRadius =cornerRadius;
    [self.view addSubview:myview];
    
    CGFloat y=0;
    NSString *placeHolder=@"用户名";
    UITextField *userNameText=[self createTextfield:CGRectMake(15,y,viewWidth-30,44) title:placeHolder placeholder:@"用户名/手机号"];
    userNameText.returnKeyType=UIReturnKeyNext;
    userNameText.keyboardType=UIKeyboardTypeEmailAddress;
    userNameText.inputAccessoryView=topView;
    [myview addSubview:userNameText];
    self.nameField=userNameText;
    y+=userNameText.frame.size.height;
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, y, viewWidth, borderWidth)];
    lineView.backgroundColor=color;
    [myview addSubview:lineView];
    y+=borderWidth;
    
    placeHolder=@"密   码";
    UITextField *pwdText=[self createTextfield:CGRectMake(15,y,viewWidth-30,44.0f) title:placeHolder placeholder:@""];
    pwdText.returnKeyType=UIReturnKeyGo;
    pwdText.secureTextEntry = YES; //密码
    pwdText.inputAccessoryView=topView;
    [myview addSubview:pwdText];
    self.pwdField=pwdText;
    y+=pwdText.frame.size.height;
    
    startY+=y+20;
    
    // 创建会员登录按钮
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(startX, startY, viewWidth-2*startX, 44);
    [btn setTitle:@"绑定" forState:UIControlStateNormal];
    btn.layer.masksToBounds=YES;
    btn.layer.cornerRadius=6;
    [btn setBackgroundColor:KBtnLoginBgColor];
    [btn setTitleColor:KBtnTitleColor forState:UIControlStateNormal];
    btn.titleLabel.font=KFontSizeBold36px;
    btn.tag=0x11;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    startY+=btn.frame.size.height;
    
//    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
//    btn.frame=CGRectMake(startX, startY, viewWidth-2*startX, 44.0f);
//    [btn setTitle:@"找回密码" forState:UIControlStateNormal];
//    [btn setTitleColor:KWordRedColor forState:UIControlStateNormal];
//    [btn setBackgroundColor:[UIColor blueColor]];
//    btn.tag=0x12;
//    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:btn];
    
    UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyBorad)];
    tapRecog.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecog];
}

//
-(void)clickBtn:(UIButton *)sender{
    switch (sender.tag) {
        case 0x11:{ //绑定
            NSString *name=self.nameField.text;
            if (!name || [name isEqualToString:@""]) {
                NSString *tips=@"请输入用户名/手机号";
                [ALDUtils showToast:tips];
                [self.nameField becomeFirstResponder];
                return;
            }
            NSString *pwd=self.pwdField.text;
            if (!pwd || [pwd isEqualToString:@""]) {
                NSString *tips=@"请输入密码";
                [ALDUtils showToast:tips];
                [self.pwdField becomeFirstResponder];
                return;
            }
            [self hiddenKeyBorad];
            
            BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
            [httpClient openUserRelevance:self.sid username:name pwd:pwd];
        }
            break;
            
        case 0x12:{ //忘记密码
//            [self gotoForgetPwd];
        }
            break;
            
        default:
            break;
    }
}

-(void)gotoForgetPwd
{
    BasicsRegisterViewController *controller=[[BasicsRegisterViewController alloc] init];
    controller.title=@"找回密码";
    controller.type=4;
    controller.delegate=self;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) loginView:(UIViewController *)loginView doneWithCode:(int)code withUser:(id)user{
    if (code==KOK) {
        NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
        NSString *uid=[config stringForKey:kUidKey];
        if(uid && ![uid isEqualToString:@""]){
            [config setObject:@"true" forKey:kNeedSendTokenKey];
            [config synchronize];
            
            AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
            //[appDelegate registPush];
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
    controller.hidesBottomBarWhenPushed=YES;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backItem;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)hiddenKeyBorad
{
    [self.nameField resignFirstResponder];
    [self.pwdField resignFirstResponder];
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

-(void)getUserInfo
{
    NSString *uid=[[NSUserDefaults standardUserDefaults] stringForKey:kUidKey];
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient viewUserInfo:uid];
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if(requestPath==HttpRequestPathForOpenUserRelevance){
        [ALDUtils addWaitingView:self.view withText:@"绑定中,请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForOpenUserRelevance){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                UserBean *user=(UserBean *)obj;
                NSString *uid=user.uid;
                NSString *sessionKey=user.sessionKey;
                int status=[user.status intValue];
                NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
                [config setObject:uid forKey:kUidKey];
                [config setObject:sessionKey forKey:kSessionIdKey];
                [config setInteger:status forKey:KUserStatus];
                if(status==0){
                    if (_delegate && [_delegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
                        
                        if (!uid) {
                            uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
                        }
                        [_delegate loginView:nil doneWithCode:401 withUser:uid];
                    }
                }else{
                    [self getUserInfo];
                }
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if(code==kNO_RESULT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"用户名或密码错误!";
                }
            }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"网络连接失败,请检查网络设置!";
                }
            }else if(code==2){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"该用户已绑定了该类型的开放平台账户!";
                }
            }else{
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"绑定失败,请稍候再试!";
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
        if (_delegate && [_delegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
            if (!uid) {
                uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
            }
            [_delegate loginView:nil doneWithCode:KOK withUser:uid];
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
