//
//  AppDelegate.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/1.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import <RennSDK/RennSDK.h>
#import "WXApi.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain,nonatomic) NSString *dbConfPath;
@property (retain,nonatomic) NSString *dbCommonPath;

/**
 * 获取引导页面图片，子类可以根据情况重写该方法
 **/
-(NSArray*) getWelcomeImages;

/**
 * 退出登录
 **/
-(void)loginOut;
/**
 * 应用启动方法，子类可以重写
 **/
-(void)startApp;

/**
 * 显示登录界面，子类可以重写
 **/
-(void)showLogin;

/**
 * 跳转到主界面，子类可以重写
 **/
-(void) forwardToMainView;

- (FMDatabase *) getDatabase;

-(FMDatabase *) getCommonDatabase;

-(NSLock*) getLock;

- (BOOL)resetDatabase:(NSString*) confid;
@end
