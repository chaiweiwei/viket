//
//  BageBean.h
//  Zenithzone2
//  消息中心bageBean
//  Created by alidao on 14/11/27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BageBean : NSObject<NSCoding>

/** 未读消息中心通知数 **/
@property (nonatomic) int NCBageCount;
/** 未读消息中心@我数 **/
@property (nonatomic) int AtBageCount;
/** 未读消息中心评论数 **/
@property (nonatomic) int commentBageCount;
/** 未读消息中心赞数 **/
@property (nonatomic) int praiseBageCount;

@end
