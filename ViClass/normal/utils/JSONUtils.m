//
//  JSONUtils.m
//  ZYClub
//  JOSN数据与实体bean转换工具
//  Created by chen yulong on 14-3-17.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "JSONUtils.h"
#import "SBJson.h"
#import "NSDictionaryAdditions.h"
#import "ALDUtils.h"

@implementation JSONUtils

/**
 * JSON 对象数据转换成实体bean对象
 * @param jsonString 为JSONObject格式的数据
 * @param beanClass 实体bean类名
 */
+(NSObject*) jsonToBean:(NSString *)jsonString toBeanClass:(NSString *)beanClass{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id repr = [parser objectWithString:jsonString];
    if (!repr){
        NSLog(@"jsonToBean:-JSONValue failed. Error is: %@", parser.error);
        return nil;
    } else{
        if ([repr isKindOfClass:[NSDictionary class]]) {
            NSObject *obj=[[NSClassFromString(beanClass) alloc] init];
            NSDictionary *dic=repr;
            NSArray *allKeys=[dic allKeys];
            for (NSString *key in allKeys) {
                @try {
                    if ([key isEqualToString:@"id"]) { //如果是id属性，则使用sid
                        [obj setValue:[dic objectForKey_NONULL:key] forKey:@"sid"];
                    }else if ([key isEqualToString:@"description"]){
                        [obj setValue:[dic objectForKey_NONULL:key] forKey:@"descContent"];
                    }else{
                        [obj setValue:[dic objectForKey_NONULL:key] forKey:key];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"jsonToBean: %@",[exception description]);
                }
                
            }
            return ALDReturnAutoreleased(obj);
        }else{
            NSLog(@"jsonToBean:-JSONValue failed. JSONValue isn't a JSONObject!");
        }
    }
    return nil;
}

/**
 * JSON 数组数据转换成实体bean数组
 * @param jsonString 为JSONOArray格式的数据
 * @param itemClass 数组项实体bean类名
 */
+(NSArray*) jsonToArray:(NSString *)jsonString withItemClass:(NSString *)itemClass{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id repr = [parser objectWithString:jsonString];
    if (!repr){
        NSLog(@"jsonToArray:-JSONValue failed. Error is: %@", parser.error);
        return nil;
    } else{
        if ([repr isKindOfClass:[NSArray class]]) {
            NSArray *array=repr;
            NSMutableArray *list=[NSMutableArray array];
            for (NSDictionary *dic in array) {
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    NSObject *obj=[[NSClassFromString(itemClass) alloc] init];
                    NSArray *allKeys=[dic allKeys];
                    for (NSString *key in allKeys) {
                        @try {
                            if ([key isEqualToString:@"id"]) { //如果是id属性，则使用sid
                                [obj setValue:[dic objectForKey_NONULL:key] forKey:@"sid"];
                            }else{
                                [obj setValue:[dic objectForKey_NONULL:key] forKey:key];
                            }
                        }
                        @catch (NSException *exception) {
                            NSLog(@"jsonToBean: %@",[exception description]);
                        }
                        
                    }
                    [list addObject:obj];
                    ALDRelease(obj);
                }else{
                    NSLog(@"jsonToArray:-JSONValue failed. JSONArray Item isn't a JSONObject!");
                }
            }
            return list;
        }else{
            NSLog(@"jsonToArray:-JSONValue failed. JSONValue isn't a JSONArray!");
        }
        return nil;
    }
}

/**
 * JSON 对象数据转换成实体bean对象
 * @param jsonObject 为JSONObject对象数据
 * @param beanClass 实体bean类名
 */
+(NSObject*) jsonToBeanWithObject:(NSDictionary *)jsonObject toBeanClass:(NSString *)beanClass{
    if (!jsonObject){
        NSLog(@"jsonToBean:-JSONValue failed. Error:null point with jsonObject");
        return nil;
    } else{
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            NSObject *obj=[[NSClassFromString(beanClass) alloc] init];
            NSDictionary *dic=jsonObject;
            NSArray *allKeys=[dic allKeys];
            for (NSString *key in allKeys) {
                @try {
                    if ([key isEqualToString:@"id"]) { //如果是id属性，则使用sid
                        [obj setValue:[dic objectForKey_NONULL:key] forKey:@"sid"];
                    }else{
                        [obj setValue:[dic objectForKey_NONULL:key] forKey:key];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"jsonToBean: %@",[exception description]);
                }
                
            }
            return ALDReturnAutoreleased(obj);
        }else{
            NSLog(@"jsonToBean:-JSONValue failed. JSONValue isn't a JSONObject!");
        }
    }
    return nil;
}

/**
 * JSON 数组数据转换成实体bean数组
 * @param jsonArray 为JSONOArray数组数据
 * @param itemClass 数组项实体bean类名
 */
+(NSArray*) jsonToArrayWithArray:(NSArray *)jsonArray withItemClass:(NSString *)itemClass{
    if (!jsonArray){
        NSLog(@"jsonToArray:-JSONValue failed. Error is: null point with jsonArray");
        return nil;
    } else{
        if ([jsonArray isKindOfClass:[NSArray class]]) {
            NSArray *array=jsonArray;
            NSMutableArray *list=[NSMutableArray array];
            for (NSDictionary *dic in array) {
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    NSObject *obj=[[NSClassFromString(itemClass) alloc] init];
                    NSArray *allKeys=[dic allKeys];
                    for (NSString *key in allKeys) {
                        @try {
                            if ([key isEqualToString:@"id"]) { //如果是id属性，则使用sid
                                [obj setValue:[dic objectForKey_NONULL:key] forKey:@"sid"];
                            }else{
                                [obj setValue:[dic objectForKey_NONULL:key] forKey:key];
                            }
                        }
                        @catch (NSException *exception) {
                            NSLog(@"jsonToBean: key=%@, exception=%@",key,[exception description]);
                        }
                        
                    }
                    [list addObject:obj];
                    ALDRelease(obj);
                }else{
                    NSLog(@"jsonToArray:-JSONValue failed. JSONArray Item isn't a JSONObject!");
                }
            }
            return list;
        }else{
            NSLog(@"jsonToArray:-JSONValue failed. JSONValue isn't a JSONArray!");
        }
        return nil;
    }
}

@end
