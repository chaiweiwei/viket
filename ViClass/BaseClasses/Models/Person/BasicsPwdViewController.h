//
//  PwdViewController.h
//  Glory
//  设置密码
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"

@interface BasicsPwdViewController : BaseViewController

/** 1.注册 2.找回密码 3.创建/修改支付密码 **/
@property (nonatomic) int type;
/** 手机号 **/
@property (retain,nonatomic) NSString *phone;
/** 验证码交换令牌 **/
@property (retain,nonatomic) NSString *token;

@property (assign,nonatomic) id<LoginControllerDelegate> delegate;
@end
