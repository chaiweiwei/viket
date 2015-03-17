//
//  UserBehaviourBean.h
//  Basics
//
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBehaviourBean : NSObject
/** 用户行为ID **/
@property (retain,nonatomic) NSString* sid;
/** 用户id **/
@property (retain,nonatomic) NSString* uid;
/** 积分数(int) **/
@property (retain,nonatomic)  NSNumber* integralCount;
/** 活动报名数 (int) **/
@property (retain,nonatomic)  NSNumber* applyCount;
/** 活动签到数(int) **/
@property (retain,nonatomic)  NSNumber* signinCount;
/** 赞数(int) **/
@property (retain,nonatomic)  NSNumber* praiseCount;
/** 收藏数(int) **/
@property (retain,nonatomic)  NSNumber* favoriteCount;
/** 转发数(int) **/
@property (retain,nonatomic)  NSNumber* forwardCount;
/** 评论数(int) **/
@property (retain,nonatomic)  NSNumber* commentCount;
/** 被屏蔽的评论数(int) **/
@property (retain,nonatomic)  NSNumber* blockCommentCount;
/** 被删除的评论数(int) **/
@property (retain,nonatomic)  NSNumber* losedCommentCount;

/** 关注数(int) **/
@property (retain,nonatomic)  NSNumber* followCount;
/** 粉丝数(int) **/
@property (retain,nonatomic)  NSNumber* fansCount;
/** 好友数(int) **/
@property (retain,nonatomic)  NSNumber* friendCount;
@end
