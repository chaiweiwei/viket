//
//  FriendsCircleBean.h
//  WhbApp
//  朋友圈bean
//  Created by Bibo on 13-9-2.
//  Copyright (c) 2013年 Bibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsCircleBean : NSObject
/** 数据id **/
@property (retain,nonatomic) NSString *sid;
/** 模块id **/
@property (retain,nonatomic) NSNumber *moduleId;
/** 文本内容 **/
@property (retain,nonatomic) NSString *text;
/** 发布者id **/
@property (retain,nonatomic) NSString *uid;
/** 头像地址 **/
@property (retain,nonatomic) NSString *avatar;
/** 名称**/
@property (retain,nonatomic) NSString *name;
/** 标题（可空） **/
@property (retain,nonatomic) NSString *title;
/* 纬度 **/
@property (retain,nonatomic) NSString *lat;
/** 经度 **/
@property (retain,nonatomic) NSString *lng;
/** 地址 **/
@property (retain,nonatomic) NSString *address;
/** 标签，多个用”,”分隔 **/
@property (retain,nonatomic) NSString *tags;
/** 发布时间yyyy-MM-dd HH:mm:ss **/
@property (retain,nonatomic) NSString *createTime;
/** “赞”的数量 **/
@property (nonatomic) NSNumber *praiseCount;
/** 评论数 **/
@property (nonatomic) NSNumber *commentCount;
/** 转发数 **/
@property (nonatomic) NSNumber *forwardCount;
/** 收藏数 **/
@property (nonatomic) NSNumber *favoriteCount;
/** 浏览量 **/
@property (nonatomic) NSNumber *browseCount;
/** 是否可赞，具体由后台决定（Bool） **/
@property (retain,nonatomic) NSNumber *praiseFlag;
/** 是否已收藏(Bool) **/
@property (retain,nonatomic) NSNumber *favoriteFlag;
/** 分页标示(long) **/
@property (retain,nonatomic) NSNumber *pagetag;


/** 附件列表(AttachmentsBean数组) **/
@property (retain,nonatomic) NSArray *attachments;
/** 扩展字段 **/
@property (retain,nonatomic) NSDictionary *extra;


/** 可见范围，1：所有人可见，2：仅自己可见(int) **/
@property (retain,nonatomic) NSNumber *visible;

/** 微信分享标题 **/
@property (nonatomic,retain) NSString *weTitle;
/** 微信分享描述 **/
@property (nonatomic,retain) NSString *weDescription;
/** 微信分享地址 **/
@property (nonatomic,retain) NSString *weUrl;
/** 是否正在播放音频 **/
@property (nonatomic,assign) BOOL isPlaying;

/*
 * 得到格式化的时间
 **/
-(NSString*) getFormatDate;

/**
 * 转换成NSDictionary
 **/
-(NSDictionary*) toDictionary;

+(FriendsCircleBean *)initFriendCircle:(FriendsCircleBean *)bean;

@end
