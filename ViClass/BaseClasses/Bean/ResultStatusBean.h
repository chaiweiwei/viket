//
//  ResultStatusBean.h
//  Basics
//  返回处理状态bean
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultStatusBean : NSObject

/** 源数据id **/
@property(retain,nonatomic) NSString *sid;
/** 处理结果状态，1：处理成功； 0:该数据不存在或已被删除；其他(int) **/
@property(retain,nonatomic) NSNumber *status;
/** 错误描述 **/
@property(retain,nonatomic) NSString *msg;

@end
