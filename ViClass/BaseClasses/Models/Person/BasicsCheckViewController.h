//
//  CheckViewController.h
//  Glory
//  验证码
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "OHAttributedLabel.h"
#import "ALDButton.h"

@interface BasicsCheckViewController : BaseViewController

@property (retain,nonatomic) UITextField *checkCodeText; //验证码
@property (retain,nonatomic) UITextField *pwdField; //密码
@property (retain,nonatomic) UITextField *reEnterPwdField; //确认密码

@property (weak,nonatomic) OHAttributedLabel *tipsLabel;

@property (retain,nonatomic) ALDButton *verifyBtn;

@property (retain,nonatomic) NSString *token; //验证码验证交换回来的token
@property (retain,nonatomic) NSString *preCode;

@property (retain,nonatomic) NSTimer *timer;

@property (retain,nonatomic) NSString *phone;

/** 类型，1.注册 2.找回密码 3.创建/修改支付密码 4.第三方开放平台绑定时找回密码**/
@property (nonatomic) int type;
@property (assign,nonatomic) id<LoginControllerDelegate> delegate;

@property (assign,nonatomic) BOOL hasVerifyCode;

-(void)hiddenKeyBorad;
-(void)clickBtn:(ALDButton *)sender;
-(void)getCheckCode; //发送验证码

/** 跳转到完善信息界面 **/
-(void)gotoUserInfo:(BOOL) cannotToNext;

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder;

@end
