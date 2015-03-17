//
//  NCBean.h
//  Zenithzone2
//  消息中心bean
//  Created by alidao on 14/11/27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCBean : NSObject

/**
 *  0、单纯的公告、通知
 *  2、@我（sid为朋友圈数据id）
 *  3、评论(sid为朋友圈数据id)
 *  4、赞（支持，朋友圈数据id）
 *  5、新增好友请求(sid为请求用户id)
 */
@property (retain,nonatomic) NSNumber *type;
/** 源数据id **/
@property (retain,nonatomic) NSString *sourceId;
/** 标题 **/
@property (retain,nonatomic) NSString *title;
/** 消息内容(description oc中不能由该属性会冲突，所以用descContent代替) **/
@property (retain,nonatomic) NSString *descContent;
/** 详情链接，可空 **/
@property (retain,nonatomic) NSString *url;
/** 消息提醒的时间（消息产生时间） **/
@property (retain,nonatomic) NSString *createTime;
/** msg的唯一标示**/
@property (retain,nonatomic) NSString *msgId;

@end
