//
//  ALDResult.h
//  why
//
//  Created by yulong chen on 12-4-7.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALDResult : NSObject

@property (nonatomic) BOOL success;
@property (nonatomic) NSInteger code;
@property (nonatomic,retain) id obj;
@property (nonatomic,retain) NSString *lastTime;

/** 请求是否需要登录,YES:需要 **/
@property (nonatomic) BOOL isNeedLogin;

/** 是否有更多 **/
@property(nonatomic,assign) int hasNext;
@property(nonatomic,assign) int page;
/** 分页标识 **/
@property (retain,nonatomic) NSString *pagetag;
@property(nonatomic,assign) int pagesize;
@property(nonatomic,assign) int totalCount;
@property(nonatomic,retain)NSString *pageInfo;
/** 错误说明 **/
@property(nonatomic,retain) NSString *errorMsg;

/** 记录 **/
@property(nonatomic,retain) NSDictionary *userInfo;

/** 是否从缓存加载的 **/
@property (nonatomic) BOOL isLoadFromCache;

-(BOOL) captureHasNext;
@end
