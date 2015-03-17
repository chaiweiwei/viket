//
//  CommentBean.h
//  Zenithzone
//
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentBean : NSObject

/** 评论id **/
@property (retain,nonatomic) NSString *sid;
/** 数据类型，1：朋友圈/微博内容；2：活动内容 **/
@property (retain,nonatomic) NSNumber *type;
/** 源数据id **/
@property (retain,nonatomic) NSString *sourceId;
/** 发表评论用户id **/
@property (retain,nonatomic) NSString *uid;
/** 评论者头像 **/
@property (retain,nonatomic) NSString *avatar;
/** 评论者姓名 **/
@property (retain,nonatomic) NSString *name;
/** 互动评论发布时间 **/
@property (retain,nonatomic) NSString *createTime;
/** 评论 **/
@property (retain,nonatomic) NSString *content;
/** 分页标识 **/
@property (retain,nonatomic) NSNumber *pagetag;
/** 评分 **/
@property (retain,nonatomic) NSNumber *score;
/** 是否赞过 **/
@property (retain,nonatomic) NSDictionary *extra;

/** 附件列表 **/
@property (retain,nonatomic) NSArray *attachments;

-(NSString*) getFormatDate;

-(NSDictionary*) toDictionary;

@end
