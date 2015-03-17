//
//  NetworkTest.m
//  ZYClub
//  网络状态测试类
//  Created by chen yulong on 14-3-7.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "NetworkTest.h"
#import <Reachability.h>

@implementation NetworkTest
/**
 * 判断是否已经连接到wifi网络
 **/
+(BOOL) isConnectedToWifi{
    return [Reachability reachabilityForLocalWiFi].currentReachabilityStatus!=NotReachable;
}


/**
 * 判断是否已经连接到gprs网络
 **/
+(BOOL) isConnectedToGprs{
    return [[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!=NotReachable;
}

/**
 * 判断是否已经联网
 **/
+ (BOOL) connectedToNetwork{
    return [NetworkTest isConnectedToGprs] || [NetworkTest isConnectedToWifi];
}

@end
