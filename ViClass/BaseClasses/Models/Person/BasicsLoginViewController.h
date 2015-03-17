//
//  LoginViewController.h
//  BFEC
//  登录
//  Created by alidao on 13-6-5.
//  Copyright (c) 2013年 alidao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicsLoginView.h"
#import "BaseViewController.h"
#import "ALDButton.h"

static BOOL _loginViewShowed=NO;

@interface BasicsLoginViewController : BaseViewController<LoginControllerDelegate>{
    BOOL _isLoginOk;
}

@property (retain,nonatomic) BasicsLoginView *loginView;
@property (assign,nonatomic) id<LoginControllerDelegate> delegate;
@property (nonatomic) BOOL isMode;
@property (nonatomic) BOOL cancelAble;

/**
 * 开放平台类型，1：新浪微博 2：腾讯微博  3：网易微博  4：QQ  5:微信  6：淘宝
 **/
@property (nonatomic,assign) int openType;

/**
 * 昵称
 **/
@property (nonatomic,retain) NSString *nickName;

/**
 * 头像
 **/
@property (nonatomic,retain) NSString *avatar;

/**
 * app名称
 **/
@property (nonatomic,retain) NSString *appName;

+(BOOL) isLoginViewShowing;

-(void)clickBtn:(ALDButton *)sender;

@end
