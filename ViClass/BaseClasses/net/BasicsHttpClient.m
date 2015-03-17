//
//  HttpClient.m
//  FunCat
//
//  Created by alidao on 14-9-29.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsHttpClient.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSDictionaryAdditions.h"
#import "StringUtil.h"
#import "NetworkTest.h"
#import "JSONUtils.h"
#import "AppDelegate.h"
#import "AddressBean.h"
#import "ASIDownloadCache.h"
#import "AttachmentBean.h"

@implementation BasicsHttpClient

/**
 * 组装请求参数
 * @param params 参数组合，params为NSDictionary或NSArray
 **/
-(NSDictionary*) packageParams:(id) params{
    NSMutableDictionary *postParams=[NSMutableDictionary dictionary];
    NSString *bodyString=@"{}";
    if (params) {
        bodyString=[ALDUtils getJSONStringFromObj:params];
    }
    
    NSMutableDictionary *heads=[NSMutableDictionary dictionary];
    NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
    NSString *appid=[config objectForKey:kAppidKey];
    if (appid && ![appid isEqualToString:@""]) {
        [heads setObject:appid forKey:@"appid"];
    }
    NSString *uid=[config objectForKey:kUidKey];
    if (uid && ![uid isEqualToString:@""]) {
        [heads setObject:uid forKey:@"uid"];
        NSString *sessionId=[config objectForKey:kSessionIdKey];
        if (sessionId) {
            [heads setObject:sessionId forKey:@"sessionKey"];
        }
    }
    NSNumber *timestamp=[NSNumber numberWithLongLong:(long long)(1000*[[NSDate date] timeIntervalSince1970])];
    
    [heads setObject:timestamp forKey:@"timestamp"];
    [heads setObject:@"IOS" forKey:@"system"];
    NSString *sign=nil;
    
    NSString *signText=nil;
    if (appid && ![appid isEqualToString:@""]) {
        signText=[NSString stringWithFormat:@"%@%@%@%@",appid,kSignSecretKey,timestamp,bodyString];
    }else{
        signText=[NSString stringWithFormat:@"%@%@%@",kSignSecretKey,timestamp,bodyString];
    }
    sign=[BasicsHttpClient MD5:signText];
    [heads setObject:sign forKey:@"sign"];
    [postParams setObject:heads forKey:@"head"];
    if (params) {
        [postParams setObject:params forKey:@"body"];
    }else{
        [postParams setObject:[NSDictionary dictionary] forKey:@"body"];
    }
    
    if ([ALDHttpClient isDebug]) {
        NSLog(@"postParams:%@",postParams);
    }
    
    return postParams;
}

-(void) requestWithParams:(NSDictionary*) params actionName:(NSString*) actionName requestPath:(HttpRequestPath) requestPath needCache:(BOOL) needCache{
    [self requestWithParams:params actionName:actionName requestPath:requestPath needCache:needCache userInfo:nil];
}

-(void) requestWithParams:(NSDictionary*) params actionName:(NSString*) actionName requestPath:(HttpRequestPath) requestPath
                needCache:(BOOL) needCache userInfo:(NSMutableDictionary*) userInfo{
    NSDictionary *postParams=[self packageParams:params];
    NSString *url=[kServerUrl stringByAppendingFormat:@"%@",actionName];
    //    [self httpPostJSONWithParams:postParams withUrl:url requestPath:requestPath needCache:needCache];
    
    NSString *jsonString=[ALDUtils getJSONStringFromObj:postParams];
    NSDictionary *requestParams=[NSDictionary dictionaryWithObject:jsonString forKey:@"msg"];
    [self httpPostWithParams:requestParams withUrl:url requestPath:requestPath needCache:needCache userInfo:userInfo];
}

-(void) returnParamsError:(HttpRequestPath) requestPath{
    if([self.delegate respondsToSelector:@selector(dataLoadDone:requestPath:withCode:withObj:)]){
        ALDResult *result=[[ALDResult alloc] init];
        result.code=kPARAM_ERROR;
        result.errorMsg=@"传入参数错误";
        [self.delegate dataLoadDone:self requestPath:requestPath withCode:kPARAM_ERROR withObj:nil];
    }
}

/**
 * 申请appid
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态，若成功obj为appid
 */
-(void)registAppId{
    NSString *appId = [[NSUserDefaults standardUserDefaults] objectForKey:kAppidKey];
    if (appId && ![appId isEqualToString:@""]) {
        if([self.delegate respondsToSelector:@selector(dataLoadDone:requestPath:withCode:withObj:)]){
            ALDResult *result=[[ALDResult alloc] init];
            result.obj=appId;
            result.code=KOK;
            [self.delegate dataLoadDone:self requestPath:HttpRequestPathForAppid withCode:KOK withObj:result];
        }
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:kSoftwareName forKey:@"softwareName"];
    [params setObject:kSoftwareVersion forKey:@"softwareVersion"];
    [params setObject:kPublishChannel forKey:@"publishChannel"];
    CGRect bounds=[[UIScreen mainScreen] bounds];
    NSString *resolution=[NSString stringWithFormat:@"%.0f*%.0f",bounds.size.width,bounds.size.height];
    [params setObject:resolution forKey:@"mobileResolution"];
    [params setObject:kIsTouch forKey:@"isTouch"];
    [params setObject:kMobileBrandModel forKey:@"mobileBrandModel"];
    [params setObject:kSdkVersion forKey:@"sdkVersion"];
    [params setObject:kKernelVersion forKey:@"kernelVersion"];
    [params setObject:kBuilderNumber forKey:@"builderNumber"];
    [params setObject:kFirmwareConfiguationVersion forKey:@"firmwareConfiguationVersion"];
    [params setObject:kSupportNetwork forKey:@"supportNetwork"];
    [params setObject:kBrowserKernel forKey:@"browserKernel"];
    
    [self requestWithParams:params actionName:@"app/init" requestPath:HttpRequestPathForAppid needCache:NO];
}

/**
 * 将获取到的push token传送到后台
 * @param appid 应用初始化申请的appid
 * @param deviceToken 获取到的设备push token
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) registPush:(NSString *)appid withDeviceToken:(NSString*) deviceToken{
    if (!appid || [appid isEqualToString:@""]) {
        [self returnParamsError:HttpRequestPathForPush];
        return;
    }
    if (deviceToken==nil) {
        deviceToken=@"";
    }
    NSDictionary *params=[NSDictionary dictionaryWithObject:deviceToken forKey:@"deviceToken"];
    [self requestWithParams:params actionName:@"app/deviceToken" requestPath:HttpRequestPathForPush needCache:NO];
}

/**
 * 检查软件更新
 * @param appid 应用程序初始化时，服务端分配给应用程序的id
 **/
-(void)checkAppUpdate:(NSString *)appid{
    if (!appid || [appid isEqualToString:@""]) {
        [self returnParamsError:HttpRequestPathForCheckAppUpdate];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:kSoftwareName forKey:@"softwareName"];
    [params setObject:kSoftwareVersion forKey:@"softVersion"];
    [params setObject:kIdentifier forKey:@"identify"];
    [self requestWithParams:params actionName:@"app/checkUpdate" requestPath:HttpRequestPathForCheckAppUpdate needCache:NO];
}

/**
 * 用户账户登录
 * @param userName 用户名或手机号
 * @param pwd 密码
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为uid
 *   对code说明: 1：登录成功
 *              0：账号或密码错误
 *              2：账号因冻结等其他原因导致无法登录
 **/
-(void) loginWithUser:(NSString*)userName pwd:(NSString*) pwd{
    if (!userName || [userName isEqualToString:@""] || !pwd || pwd.length<1) {
        [self returnParamsError:HttpRequestPathForLogin];
        return;
    }
    pwd=[BasicsHttpClient MD5:pwd];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:userName forKey:@"username"];
    [params setObject:pwd forKey:@"password"];
    [self requestWithParams:params actionName:@"app/user/login" requestPath:HttpRequestPathForLogin needCache:NO];
}

/**
 * 用户数据验证接口
 * @param username 检查用户名是否存在
 * @param mobile 检查手机号是否存在
 * @param email 检查邮箱是否存在
 */
-(void) userDataVerify:(NSString*) username mobile:(NSString*) mobile email:(NSString*) email {
    if ([NSString isEmpty:username] && [NSString isEmpty:mobile] && [NSString isEmpty:email]) {
        [self returnParamsError:HttpRequestPathForUserDataVerify];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    if (![NSString isEmpty:username]) {
        [params setObject:username forKey:@"username"];
    }
    if (![NSString isEmpty:mobile]) {
        [params setObject:mobile forKey:@"mobile"];
    }
    if (![NSString isEmpty:email]) {
        [params setObject:email forKey:@"email"];
    }
    [self requestWithParams:params actionName:@"app/user/verify" requestPath:HttpRequestPathForUserDataVerify needCache:NO];
    
}

/**
 * 发送手机验证码
 * @param mobile 手机号
 * @param type 类型，1：注册，2：找回密码,3:创建/修改支付密码 4:绑定/重绑定手机
 **/
-(void) sendVerifyCode:(NSString*)mobile withType:(int) type{
    if ([NSString isEmpty:mobile] || ![ALDUtils isValidateMobile:mobile]) {
        [self returnParamsError:HttpRequestPathForSendVerifyCode];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:mobile forKey:@"mobile"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [self requestWithParams:params actionName:@"app/verifyCode/request" requestPath:HttpRequestPathForSendVerifyCode needCache:NO];
}

/**
 * 验证手机验证码
 * @param mobile 手机号
 * @param type 类型，1：注册，2：找回密码，3：创建/修改支付密码 4:绑定/重绑定手机
 * @param code 验证码
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,code=1则返回result.obj为交换的token
 */
-(void) verifyCode:(NSString*) mobile type:(NSInteger) type code:(NSString*) code {
    if ([NSString isEmpty:mobile] || [NSString isEmpty:code] || type<1) {
        [self returnParamsError:HttpRequestPathForVerifyCode];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:mobile forKey:@"mobile"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
    [params setObject:code forKey:@"verifyCode"];
    [self requestWithParams:params actionName:@"app/verifyCode/verify" requestPath:HttpRequestPathForVerifyCode needCache:NO];
}

/**
 * 注册接口，支持手机注册和用户名密码注册
 * @param username 注册用户名或手机号,如果type=1则为手机号
 * @param password 设置密码 大于等于6小于16个字符
 * @param type 注册类型，1：手机号注册，2：用户名密码注册
 * @param token 验证验证码成功后交换的token 手机注册时必须传
 * @param invitationCode 注册邀请码,用于好友邀请注册
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) registerWithUser:(NSString*) username pwd:(NSString*) pwd type:(NSInteger) type token:(NSString*)token invitationCode:(NSString*) invitationCode{
    HttpRequestPath requestPath=HttpRequestPathForRegister;
    if ([NSString isEmpty:username] || !pwd || pwd.length<6 || type<1) {
        [self returnParamsError:requestPath];
        return;
    }
    if (type==1 && [NSString isEmpty:token]) { //手机注册必须有token
        [self returnParamsError:requestPath];
        return;
    }
    pwd=[BasicsHttpClient MD5:pwd];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:username forKey:@"username"];
    [params setObject:pwd forKey:@"password"];
    [params setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
    if (![NSString isEmpty:token]) {
        [params setObject:token forKey:@"token"];
    }
    if (invitationCode) {
        [params setObject:invitationCode forKey:@"invitationCode"];
    }
    [self requestWithParams:params actionName:@"app/user/register" requestPath:requestPath needCache:NO];
}

/**
 * 第三方平台用户登录接口
 * @param openid 开放平台id
 * @param openType 开放平台类型，1：新浪微博 2：腾讯微博  3：网易微博  4：QQ  5:微信  6：淘宝
 * @param accessToken 开放平台授权令牌
 * @param accessSecret 开发平台授权secret	可能为空
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,result.obj为UserBean对象
 */
-(void) openUserLogin:(NSString*) openid openType:(NSInteger) openType
          accessToken:(NSString*) accessToken accessSecret:(NSString*) accessSecret {
    HttpRequestPath requestPath=HttpRequestPathForOpenUserLogin;
    if ([NSString isEmpty:openid] || openType<1 || [NSString isEmpty:accessToken]) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:openid forKey:@"openid"];
    [params setObject:[NSNumber numberWithInteger:openType] forKey:@"openType"];
    [params setObject:accessToken forKey:@"accessToken"];
    if (![NSString isEmpty:accessSecret]) {
        [params setObject:accessSecret forKey:@"accessSecret"];
    }
    [self requestWithParams:params actionName:@"app/openUser/login" requestPath:requestPath needCache:NO];
}

/**
 * 当第三方用户登录后，返回的isNew=1时(新用户)，无论用户绑定或不绑定系统用户都需要调用该接口，以在后台建立关联关系
 * @param id 第三方用户数据表id
 * @param username 用户名 可空
 * @param password 用户密码，MD5加密后的字符 可空
 * @return
 */
-(void) openUserRelevance:(NSString*) sid username:(NSString*) username pwd:(NSString*) password{
    HttpRequestPath requestPath=HttpRequestPathForOpenUserRelevance;
    if ([NSString isEmpty:sid]) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"id"];
    if (![NSString isEmpty:username]) {
        [params setObject:username forKey:@"username"];
    }
    if (![NSString isEmpty:password]) {
        [params setObject:[ALDHttpClient MD5:password] forKey:@"password"];
    }
    [self requestWithParams:params actionName:@"app/openUser/relevance" requestPath:requestPath needCache:NO];
}

/**
 * 用户登录后绑定第三方平台账户接口
 * @param openid 开放平台id
 * @param openType 开放平台类型，1：新浪微博 2：腾讯微博  3：网易微博  4：QQ  5:微信  6：淘宝
 * @param accessToken 开放平台授权令牌
 * @param accessSecret 开发平台授权secret	可能为空
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态
 */
-(void) openUserBind:(NSString*) openid openType:(NSInteger) openType
         accessToken:(NSString*) accessToken accessSecret:(NSString*) accessSecret {
    HttpRequestPath requestPath=HttpRequestPathForOpenUserBind;
    if ([NSString isEmpty:openid] || openType<1 || [NSString isEmpty:accessToken]) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:openid forKey:@"openid"];
    [params setObject:[NSNumber numberWithInteger:openType] forKey:@"openType"];
    [params setObject:accessToken forKey:@"accessToken"];
    if (![NSString isEmpty:accessSecret]) {
        [params setObject:accessSecret forKey:@"accessSecret"];
    }
    [self requestWithParams:params actionName:@"app/openUser/bind" requestPath:requestPath needCache:NO];
}


/**
 * 用户密码修改接口
 * @param oldPwd 旧密码	跳过修改时只传该参数
 * @param pwd 新密码,大于等于6个字符
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyPassword:(NSString*) oldPwd pwd:(NSString*) pwd {
    if ([NSString isEmpty:oldPwd] || [NSString isEmpty:pwd] || [pwd length]<6) {
        [self returnParamsError:HttpRequestPathForModifyPassword];
        return;
    }
    oldPwd=[BasicsHttpClient MD5:oldPwd];
    pwd=[BasicsHttpClient MD5:pwd];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:oldPwd forKey:@"oldPassword"];
    [params setObject:pwd forKey:@"password"];
    [self requestWithParams:params actionName:@"app/user/modifyPassword" requestPath:HttpRequestPathForModifyPassword needCache:NO];
}

/**
 * 密码重置接口
 * @param mobile 手机号(即用户名)
 * @param pwd 设置密码 大于等于6个字符
 * @param token 验证验证码成功后交换的token
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) resetPassword:(NSString*) mobile pwd:(NSString*) pwd token:(NSString*)token{
    if (!mobile || [mobile isEqualToString:@""] || !pwd || pwd.length<6 || !token || [token isEqualToString:@""]) {
        [self returnParamsError:HttpRequestPathForResetPassword];
        return;
    }
    pwd=[BasicsHttpClient MD5:pwd];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:mobile forKey:@"mobile"];
    [params setObject:pwd forKey:@"password"];
    [params setObject:token forKey:@"token"];
    [self requestWithParams:params actionName:@"app/user/resetPassword" requestPath:HttpRequestPathForResetPassword needCache:NO];
}

/**
 * 创建或修改支付密码接口
 * @param mobile 手机号
 * @param token 验证验证码成功后交换的token
 * @param payPassword 新密码,等于6个字符
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyPayPassword:(NSString*) mobile token:(NSString*) token payPassword:(NSString*) payPassword {
    if ([NSString isEmpty:mobile] || [NSString isEmpty:token] || [payPassword length]!=6) {
        [self returnParamsError:HttpRequestPathForModifyPayPassword];
        return;
    }
    payPassword=[BasicsHttpClient MD5:payPassword];
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:mobile forKey:@"mobile"];
    [params setObject:token forKey:@"token"];
    [params setObject:payPassword forKey:@"payPassword"];
    [self requestWithParams:params actionName:@"app/user/modifyPayPassword" requestPath:HttpRequestPathForModifyPayPassword needCache:NO];
}

/**
 * 获取用户信息
 * @param uid 用户id，如果为空则为查询当前登录用户信息
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) viewUserInfo:(NSString*) uid{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    NSString *url=nil;
    if (![NSString isEmpty:uid]) {
        [params setObject:uid forKey:@"uid"];
        url=@"app/user/info";
    }else{
        url=@"app/user/userInfo";
    }
    [self requestWithParams:params actionName:url requestPath:HttpRequestPathForUserInfo needCache:YES];
}

/**
 * 修改用户信息 如果只修改头像，则只传头像到后台
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyUserInfo:(UserInfoBean*) userInfo username:(NSString*) username email:(NSString*) email extra:(NSDictionary*) extra {
    HttpRequestPath requestPath=HttpRequestPathForModifyUserInfo;
    if (userInfo==nil && [NSString isEmpty:username] && [NSString isEmpty:email] && extra==nil) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    if (![NSString isEmpty:username]) {
        [params setObject:username forKey:@"username"];
    }
    if (![NSString isEmpty:email]) {
        [params setObject:email forKey:@"email"];
    }
    if (userInfo!=nil) {
        NSDictionary *dicUserInfo=[userInfo toDictionary];
        [params setObject:dicUserInfo forKey:@"userInfo"];
    }
    if (extra!=nil) {
        [params setObject:extra forKey:@"extra"];
    }
    
    [self requestWithParams:params actionName:@"app/user/modifyUserInfo" requestPath:requestPath needCache:NO];
}

/**
 * 用户退出登录
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) logout {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [self requestWithParams:params actionName:@"app/user/logout" requestPath:HttpRequestPathForLogout needCache:NO];
}

/**
 * 获取我的积分记录
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为IntegralRecordsBean数组
 **/
-(void) queryIntegralRecords:(int) page pageCount:(int) pageCount{
    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    [self requestWithParams:params actionName:@"app/user/integralRecords" requestPath:HttpRequestPathForIntegralRecords needCache:YES];
}

/**
 * 获取我的关注
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserInfoBean数组
 **/
-(void) queryMyAttentions:(int) page pageCount:(int) pageCount {
    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    [self requestWithParams:params actionName:@"app/user/myAttentions" requestPath:HttpRequestPathForMyAttentions needCache:YES];
}

/**
 * 获取我的粉丝
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserInfoBean数组
 **/
-(void) queryMyFans:(int) page pageCount:(int) pageCount {
    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    [self requestWithParams:params actionName:@"app/user/myFans" requestPath:HttpRequestPathForMyFans needCache:YES];
}

/**
 * 获取我的玩友
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @param needReply	获取需要应答的好友请求数据时使用 1：是，其他否,不使用该参数则传null
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserBean数组
 **/
-(void) queryMyFriends:(int) page pageCount:(int) pageCount needReply:(NSNumber*) needReply{
    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    if (needReply) {
        [params setObject:needReply forKey:@"needReply"];
    }
    
    [self requestWithParams:params actionName:@"app/user/myFriends" requestPath:HttpRequestPathForMyFriends needCache:YES];
}

/**
 * 获取消息中心数据接口
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为MessageBean对象
 **/
-(void) queryMessages:(NSString*) seq{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    if (![NSString isEmpty:seq]) {
        [params setObject:seq forKey:@"seq"];
    }
    
    [self requestWithParams:params actionName:@"app/messages" requestPath:HttpRequestPathForMessages needCache:NO];
}

/**
 * 发送到朋友圈/微博信息
 * @param bean 朋友圈/微博数据bean
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) friendsCircleSend:(FriendsCircleBean*) bean {
    HttpRequestPath requestPath=HttpRequestPathForFriendsCircleSend;
    if (bean==nil || !bean.moduleId || [bean.moduleId integerValue]<1
        || ([NSString isEmpty:bean.text] && (bean.attachments==nil || bean.attachments.count<1))) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSDictionary *params=[bean toDictionary];
    [self requestWithParams:params actionName:@"app/friendsCircle/send" requestPath:requestPath needCache:NO];
}

/**
 * 获取朋友圈/微博内容列表
 * @param pagetag 分页标识，如果不传则为刷新或第一次获取数据(long)
 * @param pageCount 每页最大返回数，默认20
 * @param keyword 搜索关键字 搜索时用
 * @param moduleId 模块ID 通过模块id查找时用(int)
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean列表
 */
-(void) friendsCircleTimelines:(NSNumber*) pagetag pageCount:(int)pageCount keyword:(NSString*) keyword moduleId:(NSNumber*)moduleId hot:(BOOL)hot{
    if (pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    if (pagetag) {
        [params setObject:pagetag forKey:@"pagetag"];
    }
    if (![NSString isEmpty:keyword]) {
        [params setObject:keyword forKey:@"keyword"];
    }
    if (moduleId) {
        [params setObject:moduleId forKey:@"moduleId"];
    }
    
    if(hot){
        [params setObject:[NSNumber numberWithBool:hot] forKey:@"hot"];
    }
    
    [self requestWithParams:params actionName:@"app/friendsCircle/timelines" requestPath:HttpRequestPathForFriendsCircleTimelines needCache:YES];
}

/**
 * 获取朋友圈/微博内容详情
 * @param id 数据id
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean对象
 */
-(void) friendsCircleDetails:(NSString*) sid {
    HttpRequestPath requestPath=HttpRequestPathForFriendsCircleDetails;
    if ([NSString isEmpty:sid]) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"id"];
    [self requestWithParams:params actionName:@"app/friendsCircle/details" requestPath:requestPath needCache:YES];
}

/**
 * 对话模式发送信息
 * @param bean 对话数据bean
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) chatSend:(ChatBean*) bean {
    HttpRequestPath requestPath = HttpRequestPathForChatSend;
    if (bean==nil || [NSString isEmpty:bean.toUid] || ([NSString isEmpty:bean.content]
                                                        && (bean.attachments==nil || bean.attachments.count<1))) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:bean.toUid forKey:@"toUid"];
    if (![NSString isEmpty:bean.content]) {
        [params setObject:bean.content forKey:@"content"];
    }
    NSArray *attachments=bean.attachments;
    if (attachments==nil || attachments.count>0) {
        NSMutableArray *array=[NSMutableArray array];
        for (AttachmentBean *attach in attachments) {
            [array addObject:[attach toDictionary]];
        }
        [params setObject:array forKey:@"attachments"];
    }
    
    [self requestWithParams:params actionName:@"app/chat/send" requestPath:requestPath needCache:NO];
}

/**
 * 获取最新对话消息或聊天记录接口
 * @param pagetag 分页标识,不传则取最新的未读消息
 * @param pageCount 每页最大返回数，默认20
 * @param 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ChatBean数组
 * @return @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ChatBean列表
 **/
-(void) chatMessages:(NSNumber*) pagetag pageCount:(int) pageCount{
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    if (pagetag) {
        [params setObject:pagetag forKey:@"pagetag"];
    }
    
    [self requestWithParams:params actionName:@"app/chat/messages" requestPath:HttpRequestPathForChatMessages needCache:false];
}

/**
 * 对话消息处理反馈接口
 * @param pagetag 分页标识
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) chatFeedback:(NSNumber*) pagetag {
    HttpRequestPath requestPath=HttpRequestPathForChatFeedback;
    if (pagetag==nil || [pagetag longValue]<1) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:pagetag forKey:@"pagetag"];
    [self requestWithParams:params actionName:@"app/chat/feedback" requestPath:requestPath needCache:false];
}

/**
 * 发表评论接口
 * @param type 评论类型，1：朋友圈/微博内容；2：活动内容
 * @param sourceId 源数据id
 * @param content 评论内容，如果为语音则为语音url
 * @param contentType 评论内容类型：1.文本，2.语音，暂时只做文本评论，默认为文本
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) commentSend:(int) type sourceId:(NSString*) sourceId content:(NSString*) content contentType:(int) contentType {
    HttpRequestPath requestPath=HttpRequestPathForCommentSend;
    if (type<1 || [NSString isEmpty:sourceId] || [NSString isEmpty:content]) {
        [self returnParamsError:requestPath ];
        return;
    }
    if (contentType<1) {
        contentType=1;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:sourceId forKey:@"sourceId"];
    [params setObject:content forKey:@"content"];
    [params setObject:[NSNumber numberWithInt:contentType] forKey:@"contentType"];
    [self requestWithParams:params actionName:@"app/comment/send" requestPath:requestPath needCache:false];
}

/**
 * 发表评论接口(type=1朋友圈/微博内容； type=2活动内容 评论)
 * @param bean 评论数据bean,评论内容和附件不能同时为空
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) commentSend:(CommentBean*) bean{
    HttpRequestPath requestPath=HttpRequestPathForCommentSend;
    if (bean==nil || [NSString isEmpty:bean.sourceId] || ([NSString isEmpty:bean.content] && bean.attachments.count<1)) {
        [self returnParamsError:requestPath ];
        return;
    }
    NSDictionary *params=[bean toDictionary];
    [self requestWithParams:params actionName:@"app/comment/send" requestPath:requestPath needCache:false];
}

/**
 * 获取评论数据列表
 * @param type 数据类型，1：朋友圈/微博内容；2：活动内容
 * @param sourceId 源数据id
 * @param pagetag 分页标识，为空则为刷新或第一次获取
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为CommentBean列表
 */
-(void) commentList:(int) type sourceId:(NSString*) sourceId pagetag:(NSNumber*) pagetag pageCount:(int) pageCount {
    HttpRequestPath requestPath=HttpRequestPathForCommentList;
    if (type<1 || !sourceId || [sourceId isEqualToString:@""]) {
        [self returnParamsError:requestPath];
        return;
    }
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:sourceId forKey:@"sourceId"];
    if (pagetag) {
        [params setObject:pagetag forKey:@"pagetag"];
    }
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    [self requestWithParams:params actionName:@"app/comment/list" requestPath:requestPath needCache:YES];
}

/**
 * 获取活动列表接口
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @param keyword 搜索关键字	可空
 * @param type 活动类型 可空
 * @param tag 活动标签  可空
 * @param orderBy 排序字段(字段名 asc/desc),支持多个,逗号分隔,规则同sql排序	如applyEndTime desc
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ActivityBean列表
 */
-(void) eventList:(int) page pageCount:(int) pageCount keyword:(NSString*) keyword type:(NSString*) type tag:(NSString*) tag orderBy:(NSString*) orderBy {
    if(page<1) page=1;
    if (pageCount<1) pageCount=20;
    HttpRequestPath requestPath=HttpRequestPathForEventList;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    if (![NSString isEmpty:keyword]) {
        [params setObject:keyword forKey:@"keyword"];
    }
    if (![NSString isEmpty:type]) {
        [params setObject:type forKey:@"type"];
    }
    if (![NSString isEmpty:tag]) {
        [params setObject:tag forKey:@"tag"];
    }
    if (![NSString isEmpty:tag]) {
        [params setObject:orderBy forKey:@"orderBy"];
    }
    [self requestWithParams:params actionName:@"app/event/list" requestPath:requestPath needCache:YES];
}

/**
 * 获取活动详情信息接口，如果要展示活动详情，需要使用EventBean.detailsUrl的Html页面
 * @param eventId 活动id
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ActivityBean对象
 **/
-(void) viewEventDetails:(NSString*) eventId {
    HttpRequestPath requestPath=HttpRequestPathForEventDetails;
    if ([NSString isEmpty:eventId]){
        
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:eventId forKey:@"eventId"];
    [self requestWithParams:params actionName:@"app/event/details" requestPath:requestPath needCache:YES];
}

/**
 * 获取活动下的报名人员
 * @param sid活动id
 * @param page 页码
 * @param pageCount 最大分页数
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) queryApplyMembers:(NSString *)eventId page:(int) page pageCount:(int) pageCount
{
    HttpRequestPath requestPath=HttpRequestPathForApplyMembers;
    if(!eventId || [eventId isEqualToString:@""]){
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:eventId forKey:@"eventId"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    [self requestWithParams:params actionName:@"app/eventApply/list" requestPath:requestPath needCache:YES];
}

/**
 * 删除数据接口,朋友圈/微博、朋友圈/微博评论或活动评论删除时调用接口
 * @param idList 源数据id(String数组)列表
 * @param type 数据类型 1：朋友圈/微博、2：朋友圈/微博评论、3：活动评论 4.贴吧回帖 5.帖子
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ResultStatusBean列表
 */
-(void) dataDelete:(NSArray*) idList type:(int) type {
    HttpRequestPath requestPath=HttpRequestPathForDataDelete;
    if (idList==nil || idList.count<1 || type<1) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:idList forKey:@"ids"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [self requestWithParams:params actionName:@"app/data/delete" requestPath:requestPath needCache:false];
}

/**
 * 数据收藏/取消收藏接口 朋友圈/微博内容或活动等收藏/取消收藏操作接口
 * @param idList 源数据id列表
 * @param type 数据类型 1:朋友圈/微博、2：活动
 * @param opt 1:收藏，-1：取消收藏
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ResultStatusBean列表
 */
-(void) dataFavoriteOpt:(NSArray*) idList type:(int) type opt:(int) opt{
    HttpRequestPath requestPath=HttpRequestPathForDataFavorite;
    if (idList==nil || idList.count<1 || type<1) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:idList forKey:@"ids"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:[NSNumber numberWithInt:opt] forKey:@"opt"];
    [self requestWithParams:params actionName:@"app/data/favorite" requestPath:requestPath needCache:false];
}

/**
 * 查询我的收藏数据
 * @param type 数据类型 1:朋友圈/微博 2:活动
 * @param page 页面 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean或ActivityBean列表
 */
-(void) queryMyFavorites:(int) type page:(int) page paeCount:(int) pageCount {
    HttpRequestPath requestPath=HttpRequestPathForMyFavorites;
    if (type<1) {
        [self returnParamsError:requestPath];
        return;
    }
    if(page<1) page=1;
    if(pageCount<1) pageCount=1;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [self requestWithParams:params actionName:@"app/favorite/mine" requestPath:requestPath needCache:YES userInfo:userInfo];
}

/**
 * 查询我发送的朋友圈数据
 * @param page 页面 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean列表
 */
-(void) queryMyFriendsCircle:(int) page pageCount:(int) pageCount {
    if(page<1) page=1;
    if(pageCount<1) pageCount=1;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    [self requestWithParams:params actionName:@"app/friendsCircle/mine" requestPath:HttpRequestPathForMyFriendsCircle needCache:YES];
}

/**
 * 活动报名接口
 * @param eventid 活动id
 * @param num 报名人数
 * @param linkman 联系人
 * @param contacts 联系电话
 * @param email 联系邮箱
 * @param extra 扩展字段
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) eventApply:(NSString*) eventid num:(int) num linkman:(NSString*) linkman
          contacts:(NSString*) contacts email:(NSString*) email extra:(NSDictionary*) extra {
    HttpRequestPath requestPath=HttpRequestPathForEventApply;
    if ([NSString isEmpty:eventid]) {
        [self returnParamsError:requestPath];
        return;
    }
    if(num<1) num=1;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:eventid forKey:@"eventId"];
    [params setObject:[NSNumber numberWithInt:num] forKey:@"num"];
    if (![NSString isEmpty:linkman]) {
        [params setObject:linkman forKey:@"linkman"];
    }
    if (![NSString isEmpty:contacts]) {
        [params setObject:contacts forKey:@"contacts"];
    }
    if (![NSString isEmpty:email]) {
        [params setObject:email forKey:@"email"];
    }
    if (extra) {
        [params setObject:extra forKey:@"extra"];
    }
    
    [self requestWithParams:params actionName:@"app/event/apply" requestPath:requestPath needCache:NO];
}

/**
 * 点赞操作接口
 * @param id 源数据id
 * @param type 数据类型 1.朋友圈，2.其他
 * @param opt 操作，1：赞，-1：取消赞
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为JSONObject对象
 * 	内含 praiseNum 属性(当前已赞数)和praiseAble属性(是否还可赞，1：可赞，其他否)
 */
-(void) dataPraise:(NSString*) sid type:(int) type opt:(int) opt{
    HttpRequestPath requestPath=HttpRequestPathForDataPraise;
    if ([NSString isEmpty:sid]) {
        [self returnParamsError:requestPath];
        return;
    }

    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"id"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:[NSNumber numberWithInt:opt] forKey:@"opt"];
    
    [self requestWithParams:params actionName:@"app/data/praise" requestPath:requestPath needCache:NO];
}

/**
 * 数据转发(转发到微信、微博等)成功通知后台
 * @param id 源数据id
 * @param type 1.朋友圈，2.其他
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) dataForwardResult:(NSString*) sid type:(int) type {
    HttpRequestPath requestPath=HttpRequestPathForDataForwardResult;
    if ([NSString isEmpty:sid]) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"id"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    [self requestWithParams:params actionName:@"app/data/forward" requestPath:requestPath needCache:NO];
}

/**
 * 关注/取消关注操作
 * @param uid 待关注的用户id
 * @param opt 操作，1：关注，-1：取消关注
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsAttention:(NSString*) uid opt:(int) opt {
    HttpRequestPath requestPath=HttpRequestPathForFriendsAttention;
    if ([NSString isEmpty:uid]) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"uid"];
    [params setObject:[NSNumber numberWithInt:opt] forKey:@"opt"];
    
    [self requestWithParams:params actionName:@"app/friends/attention" requestPath:requestPath needCache:NO];
}

/**
 * 请求添加好友接口
 * @param uid 待添加的用户id
 * @param content 验证消息
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsAdd:(NSString*) uid content:(NSString*) content {
    HttpRequestPath requestPath=HttpRequestPathForFriendsAdd;
    if ([NSString isEmpty:uid]) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"uid"];
    if (![NSString isEmpty:content]) {
        [params setObject:content forKey:@"content"];
    }
    
    [self requestWithParams:params actionName:@"app/friends/add" requestPath:requestPath needCache:NO];
}

/**
 * 删除好友接口
 * @param uid 待删除的用户id
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsDelete:(NSString*) uid {
    HttpRequestPath requestPath=HttpRequestPathForFriendsDelete;
    if ([NSString isEmpty:uid]) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"uid"];
    
    [self requestWithParams:params actionName:@"app/friends/delete" requestPath:requestPath needCache:NO];
}

/**
 * 处理添加好友请求
 * @param uid 待处理的用户id
 * @param opt 操作，1:接受请求，2:拒绝请求
 * @param content 拒绝理由	拒绝才有效
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsReply:(NSString *)uid opt:(int) opt content:(NSString*) content {
    HttpRequestPath requestPath=HttpRequestPathForFriendsReply;
    if ([NSString isEmpty:uid]) {
        [self returnParamsError:requestPath];
        return;
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"uid"];
    if (![NSString isEmpty:content]) {
        [params setObject:content forKey:@"content"];
    }
    [self requestWithParams:params actionName:@"app/friends/reply" requestPath:requestPath needCache:NO];
}

/**
 * 修改好友/关注人的备注
 * @param uid 待备注的用户id
 * @param type 好友类型，1:我的关注，2:好友
 * @param remark 备注信息
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsRemark:(NSString*) uid type:(int) type remark:(NSString*) remark {
    HttpRequestPath requestPath=HttpRequestPathForFriendsRemark;
    if ([NSString isEmpty:uid] || type<1) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:uid forKey:@"uid"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    if (![NSString isEmpty:remark]) {
        [params setObject:remark forKey:@"remark"];
    }
    [self requestWithParams:params actionName:@"app/friends/remark" requestPath:requestPath needCache:NO];
}

/**
 * 查询未读粉丝数量
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为未读粉丝数
 */
-(void) countUnreadFollowers {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [self requestWithParams:params actionName:@"app/user/unreadFollowers" requestPath:HttpRequestPathForCountUnreadFollowers needCache:NO];
}

/**
 * 粉丝标记为已读
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) followersReaded {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [self requestWithParams:params actionName:@"app/user/readFollowers" requestPath:HttpRequestPathForFollowersReaded needCache:NO];
}

/**
 * 获取帮助数据
 * @param page 页码，从1开始
 * @param pageCount 每页最大返回数
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为HelpBean数组
 **/
-(void) queryHelps:(int) page pagecount:(int) pageCount{
    if (page<1) page=1;
    if (pageCount<1) pageCount=1;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    [self requestWithParams:params actionName:@"app/helps" requestPath:HttpRequestPathForHelps needCache:YES];
}

/**
 * 积分支付接口
 * @param sellerId 商家id
 * @param integral 用于支付的积分数
 * @param payPassword 支付密码，MD5加密后的字符
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) integralPay:(NSNumber*) sellerId integral:(int) integral payPassword:(NSString*) payPassword{
    if (!sellerId || integral<1 || [NSString isEmpty:payPassword]) {
        [self returnParamsError:HttpRequestPathForIntegralPay];
        return;
    }
    payPassword=[BasicsHttpClient MD5:payPassword];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sellerId forKey:@"sellerId"];
    [params setObject:[NSNumber numberWithInt:integral] forKey:@"integral"];
    [params setObject:payPassword forKey:@"payPassword"];
    [self requestWithParams:params actionName:@"app/integral/pay" requestPath:HttpRequestPathForIntegralPay needCache:NO];
}

-(void) setObject:(id)anObject forKey:(id <NSCopying>)aKey forDic:(NSMutableDictionary*) dic withDefault:(id) defValue{
    if (!defValue) {
        defValue=@"";
    }
    if (anObject==nil) {
        anObject=defValue;
    }
    [dic setObject:anObject forKey:aKey];
}

static NSString *_fileZone;
/** 
 * 设置文件存储命名空间
 * @param zone 命名空间，一般为项目名(英文字符)
 **/
+(void) setFileZone:(NSString *) zone{
    _fileZone=zone;
}

/**
 * 文件上传(包括图片)接口
 * @param fileBean 媒体文件数据对象
 * @param path 模块路径 用于域下模块隔离,多级以/分隔
 * @param size 图片缩略尺寸如：64x64 图片上传和视频上传时可用，支持多个，多个示例：32x32_64x64
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为AttachmentBean对象
 **/
-(void) uploadFile:(MediaBean*) fileBean path:(NSString*)path thumbSize:(NSString*)thumbSize{
    if (fileBean==nil || [NSString isEmpty:fileBean.type] || fileBean.data.length<=0) {
        [self returnParamsError:HttpRequestPathForUploadFile];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:fileBean.type forKey:@"type"];
    if(fileBean.reco){
        [params setObject:fileBean.reco forKey:@"reco"];
    }
    NSString *zone=_fileZone;
    if ([NSString isEmpty:zone]) {
        zone=@"APP";
    }
    [params setObject:zone forKey:@"zone"];
    if (path) {
        [params setObject:path forKey:@"path"];
    }
    NSMutableDictionary *userInfo=nil;
    if (thumbSize) {
        [params setObject:thumbSize forKey:@"size"];
        [userInfo setObject:thumbSize forKey:@"thumbSize"];
    }
    if(!userInfo){
        userInfo=[NSMutableDictionary dictionary];
    }
    [userInfo setObject:fileBean forKey:@"media"];
    [params setObject:fileBean forKey:@"upload"]; //二进制文件数据
    NSString *url=[kImageServerUrl stringByAppendingString:@"upload.json"];
    [self httpPostWithParams:params withUrl:url requestPath:HttpRequestPathForUploadFile needCache:NO userInfo:userInfo];
}

/**
 * 获取关于数据url
 * @return 返回关于url
 */
+ (NSString*) getAboutUrl{
    return [NSString stringWithFormat:@"%@app/about",kServerUrl];
}

/**
 * 获取webView的扩展头
 * @param url 链接地址
 * @return 返回扩展头
 */
+(NSDictionary*) getExtraHeads:(NSString*) strUrl {
    if ([NSString isEmpty:strUrl]) {
        return nil;
    }
    NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
    NSString *appid=[config objectForKey:kAppidKey];
    NSString *uid=[config objectForKey:kUidKey];
    NSString *sessionKey=[config objectForKey:kSessionIdKey];
    
    NSString *aboleUrl=strUrl;
    NSURL *url=[NSURL URLWithString:strUrl];
    if (url) {
        aboleUrl=url.relativePath;
        if (!aboleUrl) {
            aboleUrl=strUrl;
        }
        NSString *query=url.query;
        if (query) {
            aboleUrl=[NSString stringWithFormat:@"%@?%@",aboleUrl,query];
        }
    }
    
    NSString *timestamp=[NSString stringWithFormat:@"%ld",(long)(1000*[[NSDate date] timeIntervalSince1970])];
    NSString *sign=nil;
    NSMutableDictionary *heads=[NSMutableDictionary dictionary];
    if (![NSString isEmpty:appid]) {
        [heads setObject:appid forKey:@"appid"];
        sign=[BasicsHttpClient MD5:[NSString stringWithFormat:@"%@%@%@%@",appid,kSignSecretKey,timestamp,aboleUrl]];
    }else {
        sign=[BasicsHttpClient MD5:[NSString stringWithFormat:@"%@%@%@",kSignSecretKey,timestamp,aboleUrl]];
    }
    [heads setObject:timestamp forKey:@"timestamp"];
    [heads setObject:sign forKey:@"sign"];
    if (![NSString isEmpty:uid]) {
        [heads setObject:uid forKey:@"uid"];
        if (![NSString isEmpty:sessionKey]) {
            [heads setObject:sessionKey forKey:@"sessionKey"];
        }
    }
    [heads setObject:@"IOS" forKey:@"system"];
    [heads setObject:@"ALIDAO" forKey:@"x-provider-name"];
    return heads;
}

#pragma mark end http methods

-(void) decodeJSONObject:(NSDictionary *)resultData toClass:(NSString*)class returnResult:(ALDResult*) result{
    if ([resultData isKindOfClass:[NSDictionary class]]) {
        if ([resultData count]>0) {
            result.obj=[JSONUtils jsonToBeanWithObject:resultData toBeanClass:class];
        }else{
            result.code=kNO_RESULT;
        }
    }else{
        result.code=kDATA_ERROR;
    }
}

-(void) decodeJSONArray:(NSDictionary *)jobj itemClass:(NSString*)class returnResult:(ALDResult*) result{
    id resultData=[jobj objectForKey_NONULL:@"result"];
    if ([resultData isKindOfClass:[NSArray class]]) {
        if ([resultData count]>0) {
            id hasNext=[jobj objectForKey_NONULL:@"hasNext"];
            if (hasNext) {
                result.hasNext=[hasNext intValue];
            }
            result.obj=[JSONUtils jsonToArrayWithArray:resultData withItemClass:class];
        }else{
            result.code=kNO_RESULT;
        }
    }else{
        result.code=kDATA_ERROR;
    }
}

//#pram mark
-(void) onRequestStart:(ASIHTTPRequest *)request{
    [super onRequestStart:request];
}

-(ALDResult*) onRequestDone:(ASIHTTPRequest *)request isSuccessed:(BOOL)isSuccess{ //请求成功完成
    if (isSuccess) {
        NSDictionary *userInfo=request.userInfo;
        int requestPath=[[userInfo objectForKey_NONULL:kRequestPathKey] intValue];
        if (requestPath==HttpRequestPathForDownload || requestPath==HttpRequestPathForHtmlInfo) {
            return [super onRequestDone:request isSuccessed:YES];
        }
        
        NSString *responseString = [request responseString];
        if ([ALDHttpClient isDebug]) {
            NSLog(@"response:%@",responseString);
        }
        //    NSString *postData=[[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding];
        //    NSLog(@"request data:%@",[postData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        id jobj=[responseString strToJSON];
        ALDResult *result=[[ALDResult alloc] init];
        if (!jobj || ![jobj isKindOfClass:[NSDictionary class]]) {
            result.code=kDATA_ERROR;
            result.errorMsg=@"请求失败，返回数据有误！";
            return result;
        }
        int resultCode=[[jobj objectForKey_NONULL:@"resultCode"] intValue];
        result.code=resultCode;
        result.errorMsg=[jobj objectForKey_NONULL:@"message"];
        
        /* 401：用户未登录，需登录 508：登录已过期 509：已在别的地方登录*/
        if (resultCode==401) {
            result.isNeedLogin=YES;
            result.errorMsg=@"请求需要登录权限，请先登录!";
        }else if (resultCode==508) {
            result.isNeedLogin=YES;
            result.errorMsg=@"登录已过期，请重新登录!";
        }else if (resultCode==509) {
            result.isNeedLogin=YES;
            result.errorMsg=@"账户已在别的地方登录，请重新登录!";
        }else if (resultCode != KOK && requestPath!=HttpRequestPathForUploadFile) {
            return result;
        }
        id resultData=[jobj objectForKey_NONULL:@"result"];
        if(requestPath==HttpRequestPathForUploadFile){
            resultData=jobj;
        }
        switch (requestPath) {
            case HttpRequestPathForAppid:{
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    NSString *appId = [resultData objectForKey_NONULL:@"appid"];
                    if (appId) {
                        result.obj=appId;
                        [[NSUserDefaults standardUserDefaults] setObject:appId forKey:kAppidKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }else {
                        result.code=kAPPID_ERROR;
                    }
                }else{
                    result.code=kDATA_ERROR;
                }
            }
                break;
            case HttpRequestPathForPush:
            case HttpRequestPathForSendVerifyCode:
            case HttpRequestPathForModifyPassword:
            case HttpRequestPathForModifyPayPassword:
            case HttpRequestPathForModifyUserInfo:
            case HttpRequestPathForOpenUserBind:
            case HttpRequestPathForChatFeedback:
            case HttpRequestPathForEventApply:
            case HttpRequestPathForDataForwardResult:
            case HttpRequestPathForFriendsAttention:
            case HttpRequestPathForFriendsAdd:
            case HttpRequestPathForFriendsDelete:
            case HttpRequestPathForFriendsReply:
            case HttpRequestPathForFriendsRemark:
            case HttpRequestPathForIntegralPay://无需处理
                break;
            case HttpRequestPathForCheckAppUpdate:{
                [self decodeJSONObject:resultData toClass:@"AppUpdateBean" returnResult:result];
            }
                break;
            case HttpRequestPathForVerifyCode:{
                if (!([resultData isKindOfClass:[NSDictionary class]])) {
                    result.code=kDATA_ERROR;
                    result.errorMsg=@"返回数据错误!";
                }else{
                    NSString *token=[resultData objectForKey_NONULL:@"token"];
                    if ([NSString isEmpty:token]) {
                        result.code=kDATA_ERROR;
                        result.errorMsg=@"返回数据错误!";
                    }else{
                        result.obj=token;
                    }
                }
            }
                break;
                
            case HttpRequestPathForOpenUserRelevance:
            case HttpRequestPathForLogin:
            case HttpRequestPathForRegister:
            case HttpRequestPathForResetPassword:
            case HttpRequestPathForOpenUserLogin:
            case HttpRequestPathForUserInfo:{
                [self decodeJSONObject:resultData toClass:@"UserBean" returnResult:result];
            }
                break;
                
            case HttpRequestPathForMyAttentions:
            case HttpRequestPathForMyFans:
            case HttpRequestPathForApplyMembers:{
                [self decodeJSONArray:jobj itemClass:@"UserInfoBean"returnResult:result];
            }
                break;

            case HttpRequestPathForMyFriends:{
                [self decodeJSONArray:jobj itemClass:@"UserBean"returnResult:result];
            }
                break;
            case HttpRequestPathForIntegralRecords:{
                [self decodeJSONArray:jobj itemClass:@"IntegralRecordsBean"returnResult:result];
            }
                break;
            case HttpRequestPathForMessages:{
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    NSArray *array=[resultData objectForKey_NONULL:@"list"];
                    id seq=[resultData objectForKey_NONULL:@"seq"];
                    if (array.count<1) {
                        result.code=kNO_RESULT;
                        result.errorMsg=@"暂无数据!";
                    }else{
                        if (seq) {
                            result.pagetag=[NSString stringWithFormat:@"%@",seq];
                        }
                        result.obj=[JSONUtils jsonToArrayWithArray:array withItemClass:@"MessageBean"];
                    }
                }else{
                    result.code=kDATA_ERROR;
                    result.errorMsg=@"返回数据错误!";
                }
            }
                break;
            case HttpRequestPathForFriendsCircleSend:
            case HttpRequestPathForChatSend:
            case HttpRequestPathForCommentSend:{
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    NSString *sid=[resultData objectForKey_NONULL:@"id"];
                    if ([NSString isEmpty:sid]) {
                        result.code=kDATA_ERROR;
                        result.errorMsg=@"返回数据错误!";
                    }else{
                        result.obj=sid;
                    }
                }else {
                    result.code=kDATA_ERROR;
                    result.errorMsg=@"返回数据错误!";
                }
            }
                break;
            case HttpRequestPathForFriendsCircleTimelines:
            case HttpRequestPathForMyFriendsCircle:{
                [self decodeJSONArray:jobj itemClass:@"FriendsCircleBean"returnResult:result];
            }
                break;
            case HttpRequestPathForFriendsCircleDetails:{
                [self decodeJSONObject:resultData toClass:@"FriendsCircleBean" returnResult:result];
            }
                break;
            case HttpRequestPathForChatMessages:{
                [self decodeJSONArray:jobj itemClass:@"ChatBean"returnResult:result];
            }
                break;
            case HttpRequestPathForCommentList:{
                [self decodeJSONArray:jobj itemClass:@"CommentBean"returnResult:result];
            }
                break;
            case HttpRequestPathForEventList:{
                [self decodeJSONArray:jobj itemClass:@"ActivityBean"returnResult:result];
            }
                break;
            case HttpRequestPathForEventDetails:{
                [self decodeJSONObject:resultData toClass:@"ActivityBean" returnResult:result];
            }
                break;
            case HttpRequestPathForDataDelete:
            case HttpRequestPathForDataFavorite:{
                [self decodeJSONArray:jobj itemClass:@"ResultStatusBean"returnResult:result];
            }
                break;
            case HttpRequestPathForMyFavorites:{
                int type=[[userInfo objectForKey_NONULL:@"type"] intValue];
                if (type==1) { //收藏的朋友圈/微博数据
                    [self decodeJSONArray:jobj itemClass:@"FriendsCircleBean"returnResult:result];
                }else if (type==2) { //收藏的活动
                    [self decodeJSONArray:jobj itemClass:@"ActivityBean"returnResult:result];
                }
            }
                break;
            case HttpRequestPathForDataPraise:
            case HttpRequestPathForUserDataVerify:{
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    result.obj=resultData;
                }else {
                    result.code=kDATA_ERROR;
                    result.errorMsg=@"返回数据错误!";
                }
            }
                break;
            case HttpRequestPathForCountUnreadFollowers:{
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    id count = [resultData objectForKey_NONULL:@"count"];
                    result.obj=count;
                }else {
                    result.code=kDATA_ERROR;
                    result.errorMsg=@"返回数据错误!";
                }
            }
                break;
            case HttpRequestPathForHelps:{
                [self decodeJSONArray:jobj itemClass:@"HelpBean"returnResult:result];
            }
                break;
                
            case HttpRequestPathForUploadFile:{
                int errcode=[[resultData objectForKey_NONULL:@"errcode"] intValue];
                if (errcode==0) {
                    AttachmentBean *bean=[[AttachmentBean alloc] init];
                    bean.size=[resultData objectForKey_NONULL:@"size"];
                    bean.type=[resultData objectForKey_NONULL:@"type"];
                    bean.url=[resultData objectForKey_NONULL:@"url"];
                    bean.times=[resultData objectForKey_NONULL:@"times"];
                    bean.width=[resultData objectForKey_NONULL:@"width"];
                    bean.height=[resultData objectForKey_NONULL:@"height"];
                    MediaBean *fileBean = [userInfo objectForKey:@"media"];
                    if (!bean.width || [bean.width intValue]<1
                                     || !bean.height || [bean.height intValue]<1) {
                        bean.width=fileBean.width;
                        bean.height=fileBean.height;
                    }
                    
                    NSDictionary *thumbnails=[resultData objectForKey_NONULL:@"thumbnails"];
                    NSString *thumbSize=[userInfo objectForKey:@"thumbSize"];
                    if (thumbnails && thumbnails.count>0 && thumbSize) {
                        NSArray *sizeList=[thumbSize componentsSeparatedByString:@"_"];
                        NSMutableDictionary *thumbs=[NSMutableDictionary dictionary];
                        for (NSString *temp in sizeList) {
                            NSDictionary *tempDic = [thumbnails objectForKey_NONULL:temp];
                            if (tempDic) {
                                NSString *thumbUrl=[tempDic objectForKey_NONULL:@"url"];
                                if (thumbUrl) {
                                    if (bean.thumbnail==nil) {
                                        bean.thumbnail=thumbUrl;
                                    }
                                    [thumbs setObject:thumbUrl forKey:temp];
                                }
                            }
                        }
                        bean.thumbs=thumbs;
                    }
                    if([bean.type intValue]==2){
                        NSDictionary *recoDic=[resultData objectForKey_NONULL:@"reco"];
                        bean.recoBean=(RecoBean *)[JSONUtils jsonToBeanWithObject:recoDic toBeanClass:@"RecoBean"];
                    }
                    result.obj=bean;
                    result.code=KOK;
                }else{
                    result.code=kNO_RESULT;
                    result.errorMsg=[jobj objectForKey_NONULL:@"errmsg"];
                }
            }
                break;
            default:
                break;
        }
        return result;
    }else{
        return [self onRequestFailed:request];
    }
}

- (ALDResult*) onRequestFailed:(ASIHTTPRequest *)request{ //请求失败
    NSInteger errorCode=0;
    int statusCode=request.responseStatusCode;
    NSError *error=request.error;
    if (error) {
        errorCode=error.code;
        NSDictionary *errorInfo=error.userInfo;
        if (errorInfo && [errorInfo isKindOfClass:[NSDictionary class]]) {
            NSString *descrip=[errorInfo objectForKey_NONULL:NSLocalizedDescriptionKey];
            NSRange range=[descrip rangeOfString:@"timed out"];
            if (range.location!=NSNotFound) {
                errorCode=kNET_TIMEOUT;
            }
        }
        if (errorCode==KOK) {
            errorCode=kNET_ERROR;
        }
        NSLog(@"request error:%@",error);
    } else if (![NetworkTest connectedToNetwork]) {
        errorCode=kNET_ERROR;
    } else {
        errorCode=statusCode;
    }
    NSLog(@"request failed url:%@ ,responseStatusCode:%d",request.url.absoluteString,request.responseStatusCode);
    if (errorCode==kNET_ERROR || errorCode==kNET_TIMEOUT) {
        if (self.needTipsNetError) {
            NSString *title=ALDLocalizedString(@"msgTitle", @"温馨提示");
            NSString *tips=ALDLocalizedString(@"netErrorTips", @"你的网络很不给力，请检查是否已连接。");
            [self showAlert:title strForMsg:tips withTag:111 otherButtonTitles:nil];
        }
    }
    
    ALDResult *result=[[ALDResult alloc] init];
    result.code=errorCode;
    /* 401：用户未登录，需登录 508：登录已过期 509：已在别的地方登录*/
    if (statusCode==401) {
        result.isNeedLogin=YES;
        result.errorMsg=@"请求需要登录权限，请先登录!";
    }else if (statusCode==508) {
        result.isNeedLogin=YES;
        result.errorMsg=@"登录已过期，请重新登录!";
    }else if (statusCode==509) {
        result.isNeedLogin=YES;
        result.errorMsg=@"账户已在别的地方登录，请重新登录!";
    }else if(statusCode==402){ //没有该操作权限
        result.errorMsg=@"抱歉，没有该操作权限!";
    }else if(statusCode==507){ //签名验证失败
        result.errorMsg=@"抱歉，请求非法!";
    }else if(statusCode==404){ //接口不存在
        result.errorMsg=@"抱歉，接口不存在!";
    }else{
        result.errorMsg=@"请求失败，网络异常!";
    }
    return result;
}

@end
