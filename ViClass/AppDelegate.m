//
//  AppDelegate.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/1.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsTabViewController.h"
#import "BasicsHttpClient.h"
#import "StartViewController.h"
#import "MyInfoViewController.h"
#import "HttpClient.h"
#import "UserBean.h"
#import "TimeDao.h"


static int DB_VERSION=4;

@interface AppDelegate ()<DataLoadStateDelegate,LoginControllerDelegate,UIAlertViewDelegate>
{
    BOOL _isLoginOut;
    BOOL _welcomeDone;
    NSLock *_lock;

}
@end

@implementation AppDelegate

-(FMDatabase *) getDatabase{
    if(!_dbConfPath){
        [self initDatabase];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:_dbConfPath];
    if([db open]){
        return db;
    }
    
    return nil;
}
-(FMDatabase *) getCommonDatabase{
    if(!_dbCommonPath){
        [self initCommonDatabase];
    }
    FMDatabase *db = [FMDatabase databaseWithPath:_dbCommonPath];
    if([db open]){
        return db;
    }
    
    return nil;
}

-(NSLock*) getLock{
    if (_lock==nil) {
        _lock=[[NSLock alloc] init];
    }
    return _lock;
}
/**
 * 数据库更新方法实现
 * @param db 数据库操作对象
 * @param oldVersion 先前版本号
 * @param newVersion 新版本号
 **/
-(BOOL) onUpgradeWithDb:(FMDatabase*) db oldVersion:(int) oldVersion newVersion:(int) newVersion{
    return YES;
}

- (BOOL)initDatabase{
    BOOL success=YES;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //数据库路径，在Document中。
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"common.db"];
    //NSLog(@"db path:%@",writableDBPath);
    self.dbConfPath=writableDBPath;
    FMDatabase *db = [FMDatabase databaseWithPath:writableDBPath];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
        id tmp=[config objectForKey:@"dbCurrentVersion"];
        int currentVersion=0;
        if(tmp){
            currentVersion=[tmp intValue];
        }
        if (currentVersion!=DB_VERSION) {
            if ([self onUpgradeWithDb:db oldVersion:currentVersion newVersion:DB_VERSION]) {
                [config setValue:[NSNumber numberWithInt:DB_VERSION] forKey:@"dbCurrentVersion"];
                [config synchronize];
            }
        }
        [db close];
    }else{
        NSLog(@"Failed to open database.");
        success = NO;
    }
    return success;
}

- (BOOL)initCommonDatabase{
    BOOL success=YES;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //数据库路径，在Document中。
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"hyt.db"];
    //NSLog(@"db path:%@",writableDBPath);
    self.dbCommonPath=writableDBPath;
    FMDatabase *db = [FMDatabase databaseWithPath:writableDBPath];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        [db close];
    }else{
        NSLog(@"Failed to open database.");
        success = NO;
    }
    return success;
}

- (BOOL)resetDatabase:(NSString*) confid{
    BOOL success=YES;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //数据库路径，在Document中。
    NSString *dbName=[NSString stringWithFormat:@"hyt_%@.db",confid];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
    //NSLog(@"db path:%@",writableDBPath);
    self.dbConfPath=writableDBPath;
    FMDatabase *db = [FMDatabase databaseWithPath:writableDBPath];
    if ([db open]) {
        [db setShouldCacheStatements:YES];
        NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
        id tmp=[config objectForKey:@"dbCurrentVersion"];
        int currentVersion=0;
        if(tmp){
            currentVersion=[tmp intValue];
        }
        if (currentVersion!=DB_VERSION) {
            if ([self onUpgradeWithDb:db oldVersion:currentVersion newVersion:DB_VERSION]) {
                [config setValue:[NSNumber numberWithInt:DB_VERSION] forKey:@"dbCurrentVersion"];
                [config synchronize];
            }
        }
        [db close];
    }else{
        NSLog(@"Failed to open database.");
        success = NO;
    }
    return success;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ShareSDK registerApp:@"476e78a002bc"];//字符串api20为您的ShareSDK的AppKey
    
    //2. 初始化社交平台
    //2.1 代码初始化社交平台的方法
    [self initializePlat];
    
    //[self getWelcomeImages];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //设置导航栏色系
    UIColor *tintColor = nil;
    if (isIOS7) {
        tintColor = [UIColor whiteColor];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navbarios7"] forBarMetrics:UIBarMetricsDefault];
    }else{
        tintColor = [UIColor blackColor];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_navbarios6"] forBarMetrics:UIBarMetricsDefault];
    }
    [[UINavigationBar appearance] setTintColor:tintColor];
    //设置标题的字体及样式
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                                           NSForegroundColorAttributeName: tintColor}];
    
    [self startApp];
    
    return YES;
    
}
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)initializePlat
{
   // [ShareSDK connectSinaWeiboWithAppKey:@"3899061720"
                              // appSecret:@"b22193eea2b6689feb298014e0376568"
                             //redirectUri:@"http://www.sharesdk.cn"];
    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
    [ShareSDK  connectSinaWeiboWithAppKey:@"3899061720"
                                appSecret:@"b22193eea2b6689feb298014e0376568"
                              redirectUri:@"http://www.sharesdk.cn"
                              weiboSDKCls:[WeiboSDK class]];
    //添加微信应用 注册网址 http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
                           wechatCls:[WXApi class]];
    /*//添加QQ空间应用
    [ShareSDK connectQZoneWithAppKey:@"1104272888"
                           appSecret:@"803XMuPwNQhFeNTN"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    //导入QQ互联和QQ好友分享需要的外部库类型，如果不需要QQ空间SSO和QQ好友分享可以不调用此方法
    [ShareSDK importQQClass:[QQApiInterface class]
            tencentOAuthCls:[TencentOAuth class]];*/
}

//程序初始化
-(void) startApp{
    NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
    NSString *appid=[config objectForKey:kAppidKey];
    if (!appid || [appid isEqualToString:@""]) {
        BasicsHttpClient *http=[BasicsHttpClient httpClientWithDelegate:self];
        [http registAppId];
    }else {
        NSString *uid=[config objectForKey:kUidKey];
        int status=[[config objectForKey:KUserStatus] intValue];
        if (!uid || [uid isEqualToString:@""] || status !=1 ) {
            [self showLogin];
        }else{
            
            HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
            [httpClient viewUserInfo:uid];

//            HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
//            [httpClient updateLastTime];
            
            [self forwardToMainView]; //转到主界面
        }
    }
}
/**
 * 获取引导页面图片
 **/
-(NSArray*) getWelcomeImages{
    return [NSArray arrayWithObjects:@"leadInterface1",@"leadInterface2",@"leadInterface3", nil];
}
//登录
-(void) showLogin{
    StartViewController *controller=[[StartViewController alloc] init];
    controller.title=ALDLocalizedString(@"User login", @"用户登录");
    UINavigationController *navController=[[UINavigationController alloc] initWithRootViewController:controller];
    _window.rootViewController=navController;
}
/**
 * 退出登录
 **/
-(void) loginOut
{
    NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient logout];
    
    [config setObject:@"" forKey:kUidKey];
    [config setInteger:0 forKey:KUserStatus];
    [config setObject:@"" forKey:kSessionIdKey];
    [config setObject:@"" forKey:kUserNameKey];
    [config setObject:@"" forKey:KUserInfoExtra];
    [config synchronize];
    
    [self showLogin];
}

-(void) forwardToMainView{
    
    NewsTabViewController *controller=[[NewsTabViewController alloc] init];
    UINavigationController *nav    = [[UINavigationController alloc] initWithRootViewController:controller];
    controller.title=@"微课堂";
    self.window.rootViewController=nav;
    
    [self.window makeKeyAndVisible];
}
-(void) dataStartLoad:(ALDHttpClient*)httpClient requestPath:(HttpRequestPath) requestPath
{
    if(requestPath==HttpRequestPathForAppid){
        [ALDUtils addWaitingView:self.window withText:@"应用初始化中，请稍侯..."];
    }
}
-(void) dataLoadDone:(ALDHttpClient*)httpClient requestPath:(HttpRequestPath) requestPath withCode:(NSInteger) code withObj:(ALDResult*) result
{
    if (requestPath==HttpRequestPathForAppid) {
        [ALDUtils removeWaitingView:self.window];
        if (code==kNET_ERROR || code==kNET_TIMEOUT) {
            //网络连接失败
            [ALDUtils showAlert:ALDLocalizedString(@"msgTitle", @"温馨提示") strForMsg:@"应用初始化失败，网络异常，是否重试？" withTag:0x1001 withDelegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重试"];
        }else if (code!=KOK) {
            NSString *appid=[[NSUserDefaults standardUserDefaults] objectForKey:kAppidKey];
            if (!appid) {
                [ALDUtils showAlert:ALDLocalizedString(@"msgTitle", @"温馨提示") strForMsg:@"应用初始化失败,是否重试？" withTag:0x1001 withDelegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重试"];
            }else{
                [self startApp];
            }
        }else {
            [self startApp];
        }
    }else if(requestPath==HttpRequestPathForPush){ //发送push到后台
        NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
        if (code==KOK) {
            [config setObject:@"false" forKey:kNeedSendTokenKey];
        }else{
            [config setObject:@"true" forKey:kNeedSendTokenKey];
        }
        [config synchronize];
    }else if(requestPath==HttpRequestPathForLastTime){ //发送push到后台
        if (code==KOK) {
            
        }
    }if(requestPath==HttpRequestPathForUserInfo){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
            
                UserBean *bean=(UserBean *)obj;
                NSDictionary *exera = bean.extra;
                
                NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
                [config setObject:bean.userInfo.avatar forKey:KIconKey];
                [config setObject:bean.userInfo.nickname forKey:KNickNameKey];
                
                if(![[exera objectForKey:@"thelast"] isEqualToString:@""])
                {
                    TimeDao *timeDao = [[TimeDao alloc] init];
                    [timeDao addTimeData:[exera objectForKey:@"thelast"]];
                }
                
                HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
                [httpClient updateLastTime];

                
            }
        }
    }
    [ALDUtils removeWaitingView:self.window];
}

@end
