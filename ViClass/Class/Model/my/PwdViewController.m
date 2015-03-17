//
//  PwdViewController.m
//  WeTalk
//
//  Created by chaiweiwei on 14/12/7.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "PwdViewController.h"
#import "HttpClient.h"

@interface PwdViewController()

@property(nonatomic,strong)UITextField *oldPass;
@property(nonatomic,strong)UITextField *newedPass;
@property(nonatomic,strong)UITextField *checkPass;
@end
@implementation PwdViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(clicked:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self initUI];
}
-(void)initUI
{
    self.view.backgroundColor = KTableViewBackgroundColor;
    CGFloat viewWidth = self.view.frame.size.width;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 15)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    UIView *line = [[UILabel alloc] initWithFrame:CGRectMake(0, view.bottom, viewWidth, 1)];
    line.backgroundColor = RGBACOLOR(215, 215, 215, 1);
    [self.view addSubview:line];
    
    self.oldPass = [self createText:CGRectMake(0, line.bottom, viewWidth, 44) title1:@"原密码" title2:@"请输入原密码"];
    
    [self.view addSubview:self.oldPass];
    
    line = [[UILabel alloc] initWithFrame:CGRectMake(15, self.oldPass.bottom, viewWidth, 1)];
    line.backgroundColor = RGBACOLOR(215, 215, 215, 1);
    [self.view addSubview:line];
    
    self.newedPass = [self createText:CGRectMake(0, line.bottom, viewWidth, 44) title1:@"新密码" title2:@"请输入新密码"];
     self.newedPass.secureTextEntry = YES;
    [self.view addSubview:self.newedPass];
    
    line = [[UILabel alloc] initWithFrame:CGRectMake(15,  self.newedPass.bottom, viewWidth, 1)];
    line.backgroundColor = RGBACOLOR(215, 215, 215, 1);
    [self.view addSubview:line];
    
    self.checkPass = [self createText:CGRectMake(0, line.bottom, viewWidth, 44) title1:@"确认密码" title2:@"请再次输入"];
    self.checkPass.secureTextEntry = YES;
    [self.view addSubview:self.checkPass];
    
    line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.checkPass.bottom, viewWidth, 1)];
    line.backgroundColor = RGBACOLOR(215, 215, 215, 1);
    [self.view addSubview:line];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, line.bottom +10, viewWidth, 15)];
    label.text = @"密码由6-16位数字和英文字母组成";
    label.textColor = KWordGrayColor;
    label.font = kFontSize34px;
    [self.view addSubview:label];
}
-(UITextField *)createText:(CGRect)rect title1:(NSString *)title1 title2:(NSString *)title2
{
    CGSize size = [ALDUtils captureTextSizeWithText:title1 textWidth:200 font:kFontSize34px];
    
    UITextField *text = [[UITextField alloc] initWithFrame:rect];
    text.backgroundColor = [UIColor whiteColor];
    text.placeholder = title2;
    text.font = kFontSize34px;
    text.textColor = KWordBlackColor;
    
    UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width+30, 44)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, size.width, 44)];
    title.text = title1;
    title.textColor = KWordBlackColor;
    title.font = kFontSize34px;
    [left addSubview:title];
    
    text.leftView = left;
    text.leftViewMode = UITextFieldViewModeAlways;
    return text;
}
-(void)clicked:(UIButton *)sender
{
    if(![self.checkPass.text isEqualToString:self.newedPass.text])
    {
        [ALDUtils showToast:@"两次输入密码不正确"];
        return;
    }
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient modifyPassword:self.oldPass.text pwd:self.newedPass.text];
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForModifyPassword){
        [ALDUtils addWaitingView:self.view withText:@"信息修改中，请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForModifyPassword){
        if(code==KOK){
            [ALDUtils showToast:@"密码修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    [ALDUtils removeWaitingView:self.view];
}

@end
