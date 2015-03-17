//
//  ModifyPwdViewController.m
//  Glory
//  修改密码
//  Created by alidao on 14-8-5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsModifyPwdViewController.h"
#import "BasicsHttpClient.h"
#import "ALDButton.h"

@interface BasicsModifyPwdViewController ()<UITextFieldDelegate,DataLoadStateDelegate>
{
  
}

@property (retain,nonatomic) UITextField *oldPwdText;
@property (retain,nonatomic) UITextField *pwdText;
@property (retain,nonatomic) UITextField *pwdTextNew;

@end

@implementation BasicsModifyPwdViewController

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
        self.title=@"修改密码";
    }
    self.view.backgroundColor=KBgViewColor;
    
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 60, 40);
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.tag=0x11;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightBtnItem;
    
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}

-(void)initUI
{
    CGFloat startX=0.0f;
    CGFloat startY=self.baseStartY+10.0f;
    CGFloat width=CGRectGetWidth(self.view.frame);
    CGFloat heigh=44.0f;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    UIView *line=[self createLine:CGRectMake(0, startY, width, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    UITextField *textField=[self createTextfield:CGRectMake(startX, startY, width, heigh) title:@"  旧密码" placeholder:@"请输入旧密码"];
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.oldPwdText=textField;
    startY+=44.0f;
    
    line=[self createLine:CGRectMake(0, startY, width, 1.0f)];
    [self.view addSubview:line];
    startY+=11.0f;
    
    
    line=[self createLine:CGRectMake(0, startY, width, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    textField=[self createTextfield:CGRectMake(startX, startY, width, heigh) title:@"  新密码" placeholder:@"请输入新密码"];
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.pwdText=textField;
    startY+=44.0f;
    
    line=[self createLine:CGRectMake(0, startY, width, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    textField=[self createTextfield:CGRectMake(startX, startY, width, heigh) title:@"  确认新密码" placeholder:@"请再次输入新密码"];
    textField.inputAccessoryView=topView;
    [self.view addSubview:textField];
    self.pwdTextNew=textField;
    startY+=44.0f;
    
    line=[self createLine:CGRectMake(0, startY, width, 1.0f)];
    [self.view addSubview:line];
    startY+=1.0f;
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(startX, startY, width-2*startX, 20)];
    label.font=[UIFont systemFontOfSize:13];
    label.textColor=RGBCOLOR(130, 130, 130);
    label.text=@"密码6~16位由英文字母和数字组成";
    [self.view addSubview:label];
}

-(void)submitPwd
{
    NSString *text=self.pwdText.text;
    if(!text || [text isEqualToString:@""]){
        [ALDUtils showToast:@"请输入新密码!"];
        [self.pwdText becomeFirstResponder];
        return;
    }else if(text.length<6){
        [ALDUtils showToast:@"请输入六位或以上密码!"];
        [self.pwdText becomeFirstResponder];
        return;
    }
    
    NSString *textStr=self.pwdTextNew.text;
    if(!textStr || [textStr isEqualToString:@""]){
        [ALDUtils showToast:@"请输入确认密码!"];
        [self.pwdTextNew becomeFirstResponder];
        return;
    }else if(text.length<6){
        [ALDUtils showToast:@"请输入六位或以上密码!"];
        [self.pwdTextNew becomeFirstResponder];
        return;
    }
    
    if(![text isEqualToString:textStr]){
        [ALDUtils showToast:@"两次密码输入不一致,请重新输入"];
        self.pwdTextNew.text=@"";
        [self.pwdTextNew becomeFirstResponder];
        return;
    }
    
    NSString *oldPwd=self.oldPwdText.text;
    if([oldPwd isEqualToString:text]){
        [ALDUtils showToast:@"输入的旧密码与新密码相同,请重新输入!"];
        self.pwdText.text=@"";
        self.pwdTextNew.text=@"";
        [self.pwdText becomeFirstResponder];
        return;
    }
    [self hiddenKeyBorad];
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient modifyPassword:oldPwd pwd:text];
}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{
            [self hiddenKeyBorad];
            [self submitPwd];
        }
            break;
            
        default:
            break;
    }
}

-(void)hiddenKeyBorad{
    [self.oldPwdText resignFirstResponder];
    [self.pwdText resignFirstResponder];
    [self.pwdTextNew resignFirstResponder];
}

/** 验证旧密码**/
-(void)checkPwd:(NSString *)pwd
{
//    HttpClient *httpClient=[HttpClient httpClientWithDelegate:self];
//    [httpClient checkPwd:pwd];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField==self.oldPwdText){
        
    }else if(textField==self.pwdText){
        NSString *text=self.oldPwdText.text;
        if(text && ![text isEqualToString:@""]){
            [self checkPwd:text];
        }
    }else if(textField==self.pwdTextNew){
        
    }
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
    if(requestPath==HttpRequestPathForModifyPassword){
        [ALDUtils addWaitingView:self.view withText:@"提交新密码中，请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForModifyPassword){
        if(code==KOK){
            [ALDUtils showToast:@"密码修改成功!"];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(code==kNO_RESULT){
            [ALDUtils showToast:@"旧密码错误!"];
            self.oldPwdText.text=@"";
            [self.oldPwdText becomeFirstResponder];
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:self.view withText:ALDLocalizedString(@"netError", @"网络异常，请确认是否已连接!")];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"提交新密码失败!";
            }
            [ALDUtils showToast:errMsg];

        }
    }
    [ALDUtils removeWaitingView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.oldPwdText=nil;
    self.pwdText=nil;
    self.pwdTextNew=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
