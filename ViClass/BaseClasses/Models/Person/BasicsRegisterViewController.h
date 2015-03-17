//
//  RegisterViewController.h
//  Glory
//  手机号验证码注册
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDButton.h"

@interface BasicsRegisterViewController : BaseViewController
{
    BOOL isSelect;
}

@property (retain,nonatomic) UITextField *phoneText;

/** 类型，1.注册 2.找回密码 4.第三方开放平台绑定时找回密码 **/
@property (assign,nonatomic) int type;
@property (assign,nonatomic) id<LoginControllerDelegate> delegate;

@property (assign,nonatomic) BOOL hiddenBottom;

-(void)hiddenKeyBorad;
-(void)clickBtn:(ALDButton *)sender;

@end
