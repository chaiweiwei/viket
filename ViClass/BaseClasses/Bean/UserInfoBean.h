//
//  UserInfoBean.h
//  Basics
//
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoBean : NSObject

/** 用户扩展信息ID **/
@property (retain,nonatomic) NSString *sid;

/** 用户id **/
@property (retain,nonatomic) NSString *uid;
/** 手机号码 **/
@property (retain,nonatomic) NSString *mobile;
/** 邮箱 **/
@property (retain,nonatomic) NSString *email;

/** 真实姓名 **/
@property (retain,nonatomic) NSString *realname;
/** 昵称 **/
@property (retain,nonatomic) NSString *nickname;
/** 性别 **/
@property (retain,nonatomic) NSString *gender;
/** 头像url **/
@property (retain,nonatomic) NSString *avatar;
/** 拼音 **/
@property (retain,nonatomic) NSString *pinyin;
/** 生日 **/
@property (retain,nonatomic) NSString *birthday;
/** 证件号码 **/
@property (retain,nonatomic) NSString *idcard;
/** 固定电话 **/
@property (retain,nonatomic) NSString *telephone;
/** 邮编 **/
@property (retain,nonatomic) NSString *zipcode;
/** 年收入 **/
@property (retain,nonatomic) NSString *revenue;
/** 地址 **/
@property (retain,nonatomic) NSString *address;
/** 公司 **/
@property (retain,nonatomic) NSString *company;
/** 职业 **/
@property (retain,nonatomic) NSString *occupation;
/** 职位 **/
@property (retain,nonatomic) NSString *position;
/** QQ号 **/
@property (retain,nonatomic) NSString *qq;
/** 微信号 **/
@property (retain,nonatomic) NSString *weixin;
/** 微博号 **/
@property (retain,nonatomic) NSString *weibo;
/** 支付宝帐号 **/
@property (retain,nonatomic) NSString *alipay;
/** 阿里旺旺 **/
@property (retain,nonatomic) NSString *taobao;
/** 自我介绍 **/
@property (retain,nonatomic) NSString *intro;
/** 个人主页 **/
@property (retain,nonatomic) NSString *site;
/** 个人标签 **/
@property (retain,nonatomic) NSString *tag;
/** VIP级别 **/
@property (retain,nonatomic) NSString *vip;
/** 血型 **/
@property (retain,nonatomic) NSString *bloodtype;
/** 星座 **/
@property (retain,nonatomic) NSString *constellation;
/** 生肖 **/
@property (retain,nonatomic) NSString *zodiac;
/** 班级 **/
@property (retain,nonatomic) NSString *grade;
/** 学号 **/
@property (retain,nonatomic) NSString *studentid;
/** 国籍 **/
@property (retain,nonatomic) NSString *nationality;
/** 居住地址 **/
@property (retain,nonatomic) NSString *resideprovince;
/** 毕业学校 **/
@property (retain,nonatomic) NSString *graduateschool;
/** 学历 **/
@property (retain,nonatomic) NSString *education;
/** 兴趣爱好 **/
@property (retain,nonatomic) NSString *interest;
/** 情感状态 **/
@property (retain,nonatomic) NSString *affectivestatus;
/** 交友目的 **/
@property (retain,nonatomic) NSString *lookingfor;

/** 请求加好友时候是否需要验证0:是1:否 当获取他人信息时才有(bool) **/
@property (retain,nonatomic) NSNumber *verifyFriend;
/** 是否允许关注0：是，1：否(bool) **/
@property (retain,nonatomic) NSNumber *allowFollow;

/** 是否已经关注,1:是，其他否 当获取他人信息时才有(bool) **/
@property (retain,nonatomic) NSNumber *following;
/** 是否已读,1;是，其他否,当获取我的粉丝时才有(bool) **/
@property (retain,nonatomic) NSNumber *read;

/** 备注名 **/
@property (retain,nonatomic) NSString *noteName;
/** 是否好友请求，需要验证，1：是，其他否(bool) **/
@property (retain,nonatomic) NSNumber *needReply;

/** 扩展用户信息，具体见业务需求 **/
@property(retain,nonatomic) NSDictionary *extra;

/**
 * 将用户信息对象转换成NSDictionary对象
 * @return
 */
-(NSDictionary*) toDictionary;

@end
