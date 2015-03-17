//
//  ChatBean.h
//  Basics
//  对话消息数据bean
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatBean : NSObject
/** 数据id **/
@property (retain,nonatomic) NSString *sid;
/** 发送者用户id **/
@property (retain,nonatomic) NSString *fromUid;
/** 发送者名称 **/
@property (retain,nonatomic) NSString *fromName;

/** 发送者头像 **/
@property (retain,nonatomic) NSString *fromHeadImage;
/** 接收者用户id **/
@property (retain,nonatomic) NSString *toUid;
/** 接收者名称 **/
@property (retain,nonatomic) NSString *toName;
/** 接收者头像 **/
@property (retain,nonatomic) NSString *toHeadImage;
/** 发布时间yyyy-MM-dd HH:mm:ss **/
@property (retain,nonatomic) NSString *createTime;
/** 分页标识(long) **/
@property (retain,nonatomic) NSNumber *pagetag;
/** 文本内容 **/
@property (retain,nonatomic) NSString *content;
/** 附件列表，(AttachmentsBean) **/
@property (retain,nonatomic) NSArray *attachments;

@end
