//
//  NetworkTest.h
//  ZYClub
//  网络状态测试类
//  Created by chen yulong on 14-3-7.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkTest : NSObject
/**
 * 判断是否已经连接到wifi网络
 **/
+(BOOL) isConnectedToWifi;

/**
 * 判断是否已经连接到gprs网络
 **/
+(BOOL) isConnectedToGprs;

/**
 * 判断是否已经联网
 **/
+ (BOOL) connectedToNetwork;

@end
