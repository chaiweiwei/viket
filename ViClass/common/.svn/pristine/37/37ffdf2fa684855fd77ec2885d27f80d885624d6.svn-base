//
//  JSONUtils.h
//  ZYClub
//  JOSN数据与实体bean转换工具
//  Created by chen yulong on 14-3-17.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtils : NSObject

/**
 * JSON 对象数据转换成实体bean对象
 * @param jsonString 为JSONObject格式的数据
 * @param beanClass 实体bean类名
 */
+(NSObject*) jsonToBean:(NSString *)jsonString toBeanClass:(NSString *)beanClass;

/**
 * JSON 数组数据转换成实体bean数组
 * @param jsonString 为JSONOArray格式的数据
 * @param itemClass 数组项实体bean类名
 */
+(NSArray*) jsonToArray:(NSString *)jsonString withItemClass:(NSString *)itemClass;

/**
 * JSON 对象数据转换成实体bean对象
 * @param jsonObject 为JSONObject对象数据
 * @param beanClass 实体bean类名
 */
+(NSObject*) jsonToBeanWithObject:(NSDictionary *)jsonObject toBeanClass:(NSString *)beanClass;

/**
 * JSON 数组数据转换成实体bean数组
 * @param jsonArray 为JSONOArray数组数据
 * @param itemClass 数组项实体bean类名
 */
+(NSArray*) jsonToArrayWithArray:(NSArray *)jsonArray withItemClass:(NSString *)itemClass;
@end
