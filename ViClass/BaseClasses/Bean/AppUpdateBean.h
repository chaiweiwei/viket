//
//  AppUpdateBean.h
//  Basics
//  应用更新数据bean
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUpdateBean : NSObject
/** 是否强制更新 true：需要强制更新 false：可更新(Bool) **/
@property(retain,nonatomic) NSNumber *mustUpdate;
/** 下载页面地址 **/
@property(retain,nonatomic) NSString *url;
/** 更新说明 **/
@property(retain,nonatomic) NSString *note;
@end
