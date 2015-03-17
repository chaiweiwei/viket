//
//  ActivityBean.h
//  Zenithzone
//  活动Bean
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HostBean.h"
#import "TagsBean.h"

@interface ActivityBean : NSObject
/** 数据id */
@property(retain,nonatomic) NSString *sid;
/** 活动名称 **/
@property(retain,nonatomic) NSString *name;
/** 活动简介 **/
@property(retain,nonatomic) NSString *summary;
/** 活动logo **/
@property(retain,nonatomic) NSString *logo;
/** 活动开始时间yyyy-MM-dd HH:mm:ss **/
@property(retain,nonatomic) NSString *startTime;
/** 活动结束时间 yyyy-MM-dd HH:mm:ss **/
@property(retain,nonatomic) NSString *endTime;
/** 报名开始时间 yyyy-MM-dd HH:mm:ss **/
@property(retain,nonatomic) NSString *applyStartTime;
/** 报名截止时间 yyyy-MM-dd HH:mm:ss **/
@property(retain,nonatomic) NSString *applyEndTime;
/** 已处理的显示的活动时间 **/
@property(retain,nonatomic) NSString *time;
/** 已处理的显示的报名时间 **/
@property(retain,nonatomic) NSString *applyTime;
/** 活动地址 **/
@property(retain,nonatomic) NSString *address;
/** 活动报名状态：<br/> 1、未开始<br/>
 * 			   2、进行中<br/>
 * 			   3、已暂停（暂不考虑）<br/>
 * 			   4、报名人数已满<br/>
 * 			   5、已结束
 * **/
@property(retain,nonatomic) NSNumber *applyStatus;

/** 是否置顶(Bool) **/
@property(retain,nonatomic) NSNumber *top;
/** 是否推荐(Bool) **/
@property(retain,nonatomic) NSNumber *hot;
/** 已报名人数(int) **/
@property(retain,nonatomic) NSNumber *applyCount;
/** 报名人数上限(int) **/
@property(retain,nonatomic) NSNumber *applyLimit;
/** 活动评论数(int) **/
@property(retain,nonatomic) NSNumber *commentCount;
/** 活动收藏数(int) **/
@property(retain,nonatomic) NSString *favoriteCount;
/** 活动类型 **/
@property(retain,nonatomic) NSString *type;
/** 活动主办方 **/
@property(retain,nonatomic) NSString *host;
/** 活动标签 **/
@property(retain,nonatomic) NSString *tags;
/** 扩展字段 **/
@property(retain,nonatomic) NSDictionary *extra;

/** 活动分享描述内容 **/
@property(retain,nonatomic) NSString *shareContent;
/** 活动详情链接 **/
@property(retain,nonatomic) NSString *detailsUrl;
/** 是否已报名,1:是，其他否	登录用户才返回(Bool) **/
@property(retain,nonatomic) NSNumber *applied;
/** 是否已收藏,1:是，其他否	登录用户才返回(Bool) **/
@property(retain,nonatomic) NSNumber *favorited;


@end
