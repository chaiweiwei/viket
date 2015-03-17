//
//  TypesBean.h
//  TZAPP
//
//  分类标签Bean
//
//  Created by chen yulong on 14-8-28.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypesBean : NSObject
/** 分类标签id(int) **/
@property (retain,nonatomic) NSNumber *sid;
/** 分类标签名 **/
@property (retain,nonatomic) NSString *name;
/** 标记数量(int) **/
@property (retain,nonatomic) NSNumber *badgeCount;
/** 是否默认显示项，如果多行设置值为true，只取最前一项，其他无效(Bool) **/
@property (retain,nonatomic) NSNumber *defaultDisplay;

@end
