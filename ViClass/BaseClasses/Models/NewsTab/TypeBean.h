//
//  TypeBean.h
//  WhbApp
//  栏目bean
//  Created by chen yulong on 13-9-2.
//  Copyright (c) 2013年 Bibo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeBean : NSObject
/** 栏目id **/
@property (retain,nonatomic) NSString *typeId;
/** 栏目名称 **/
@property (retain,nonatomic) NSString *name;
/** 排序，从小到大 **/
@property (nonatomic) int seq;
/** 数字标示 **/
@property (nonatomic) int bageCount;

/** 状态，1：新增，2：修改，-1：删除 **/
@property (nonatomic) int status;
@end
