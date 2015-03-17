//
//  UserBean.h
//  FunCat
//  用户Bean
//  Created by alidao on 14-9-29.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressBean.h"
#import "UserInfoBean.h"
#import "UserBehaviourBean.h"

@interface UserBean : NSObject
/**用户id*/
@property(retain,nonatomic) NSString *uid;
/** 登录会话id **/
@property(retain,nonatomic) NSString *sessionKey;
/** 第三方用户数据表id **/
@property(retain,nonatomic) NSString *sid;
/** 是否新用户，1：是，其他否,第三方用户登录时返回(int) **/
@property(retain,nonatomic) NSNumber *isNew;
/** 用户名 **/
@property(retain,nonatomic) NSString *username;
/** 手机 **/
@property(retain,nonatomic) NSString *mobile;
/** 邮箱 **/
@property(retain,nonatomic) NSString *email;
/** 状态	0:未激活，1.使用中，2.已禁用(int) **/
@property(retain,nonatomic) NSNumber *status;
/** 用户来源	1.APP，2.WX，3.WAP，4.WEB，5.分配 **/
@property(retain,nonatomic) NSNumber *source;
/** 备注名，获取他人信息时才有 **/
@property(retain,nonatomic) NSString *noteName;

/** 用户信息数据 **/
@property(retain,nonatomic) UserInfoBean *userInfo;

/** 用户行为数据,如果是获取当前登录用户信息才有返回 **/
@property(retain,nonatomic) UserBehaviourBean *userBehaviour;
/** 是否已设置支付密码,如果是获取当前登录用户信息才有返回(bool) **/
@property(retain,nonatomic) NSNumber *haspayPassword;
/** 邀请好友注册默认内容,如果是获取当前登录用户信息才有返回 **/
@property(retain,nonatomic) NSString *inviteRegister;

/** 扩展用户信息，具体见业务需求 **/
@property(retain,nonatomic) NSDictionary *extra;

/**
 * @param 获取状态值
 * @return status
 */
-(NSString*) getStringStatus;

/**
 * @param 获取用户来源
 * @return source
 */
-(NSString*) getStringSource;

/**
 * 获取分享的链接地址
 **/
-(NSString*) getShareUrl;

/**
 * 获取分享的内容
 * @param type 1:需要url,2:不需要url
 **/
-(NSString*) getInviteContent:(int) type;

@end
