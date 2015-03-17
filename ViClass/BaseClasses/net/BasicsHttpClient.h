//
//  HttpClient.h
//  FunCat
//
//  Created by alidao on 14-9-29.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALDHttpClient.h"
#import "StringUtil.h"
#import "UserInfoBean.h"
#import "FriendsCircleBean.h"
#import "ChatBean.h"
#import "AttachmentBean.h"
#import "MediaBean.h"
#import "CommentBean.h"

typedef NS_ENUM(NSInteger, BasicsHttpRequestPath){
    /** 应用初始化请求 **/
    HttpRequestPathForAppid = 1,
    /** 推送信息注册请求 **/
    HttpRequestPathForPush = 2,
    /** 用户登录 **/
    HttpRequestPathForLogin = 3,
    /** 用户注册 **/
    HttpRequestPathForRegister = 4,
    /** 第三方平台用户登录 **/
    HttpRequestPathForOpenUserLogin = 5,
    /** 第三方平台用户登录后绑定系统账户接口 **/
    HttpRequestPathForOpenUserRelevance = 6,
    /** 用户登录后绑定第三方平台账户接口 **/
    HttpRequestPathForOpenUserBind = 7,
    /** 重置密码 **/
    HttpRequestPathForResetPassword = 8,
    /** 验证手机验证码 **/
    HttpRequestPathForVerifyCode = 9,
    /** 发送手机验证码 **/
    HttpRequestPathForSendVerifyCode = 10,
    /** 修改用户密码 **/
    HttpRequestPathForModifyPassword = 11,
    /** 创建或修改支付密码 **/
    HttpRequestPathForModifyPayPassword = 12,
    /** 查看用户信息 **/
    HttpRequestPathForUserInfo = 13,
    /** 修改用户信息 **/
    HttpRequestPathForModifyUserInfo = 14,
    /** 退出登录 **/
    HttpRequestPathForLogout = 15,
    /** 查询我的关注 **/
    HttpRequestPathForMyAttentions = 16,
    /** 查询我的粉丝 **/
    HttpRequestPathForMyFans = 17,
    /** 查询我的玩友 **/
    HttpRequestPathForMyFriends = 18,
    /** 查询积分记录 **/
    HttpRequestPathForIntegralRecords = 19,
    /** 文件上传(包括图片) **/
    HttpRequestPathForUploadFile = 20,
    /** 检查软件更新 **/
    HttpRequestPathForCheckAppUpdate = 21,
    /** 获取消息中心数据 **/
    HttpRequestPathForMessages = 22,
    /** 发送数据到朋友圈 **/
    HttpRequestPathForFriendsCircleSend = 23,
    /** 朋友圈/微博数据列表获取 **/
    HttpRequestPathForFriendsCircleTimelines = 24,
    /** 朋友圈/微博数据详情 **/
    HttpRequestPathForFriendsCircleDetails = 25,
    /** 发送对话消息 **/
    HttpRequestPathForChatSend = 26,
    /** 获取对话消息列表 **/
    HttpRequestPathForChatMessages = 27,
    /** 消息处理反馈回调 **/
    HttpRequestPathForChatFeedback =28,
    /** 发表评论 **/
    HttpRequestPathForCommentSend = 29,
    /** 获取评论数据列表 **/
    HttpRequestPathForCommentList = 30,
    /** 获取获取活动列表数据 **/
    HttpRequestPathForEventList = 31,
    /** 获取活动详情数据 **/
    HttpRequestPathForEventDetails = 32,
    /** 数据删除接口 **/
    HttpRequestPathForDataDelete = 33,
    /** 数据收藏/取消收藏操作 **/
    HttpRequestPathForDataFavorite = 34,
    /** 点赞接口 **/
    HttpRequestPathForDataPraise=35,
    /** 数据转发成功通知后台 **/
    HttpRequestPathForDataForwardResult = 36,
    /** 关注操作接口 **/
    HttpRequestPathForFriendsAttention = 37,
    /** 请求添加好友接口 **/
    HttpRequestPathForFriendsAdd = 38,
    /** 删除好友接口 **/
    HttpRequestPathForFriendsDelete = 39,
    /** 处理好友请求接口 **/
    HttpRequestPathForFriendsReply = 40,
    /** 修改好友/关注的人备注信息 **/
    HttpRequestPathForFriendsRemark = 41,
    /** 统计未读粉丝数 **/
    HttpRequestPathForCountUnreadFollowers = 42,
    /** 粉丝数已查看通知后台 **/
    HttpRequestPathForFollowersReaded = 43,
    /** 查询我的收藏数据 **/
    HttpRequestPathForMyFavorites = 44,
    /** 查询我发送的朋友圈数据 **/
    HttpRequestPathForMyFriendsCircle=45,
    /** 活动报名 **/
    HttpRequestPathForEventApply=46,
    /** 帮助数据 **/
    HttpRequestPathForHelps = 47, 
    /** 积分支付接口 **/
    HttpRequestPathForIntegralPay = 48, 
    /** 用户数据验证接口 **/
    HttpRequestPathForUserDataVerify = 49,
    HttpRequestPathForApplyMembers, //活动报名人数
    
};

//本类中实现了app所有数据请求协议，全为异步请求，采用接口回调方式通知请求发起对象，需要实现DataLoadStateDelegate协议
@interface BasicsHttpClient : ALDHttpClient{
    
}

/**
 * 组装请求参数
 * @param params 参数组合，params为NSDictionary或NSArray
 **/
-(NSDictionary*) packageParams:(id) params;

-(void) requestWithParams:(NSDictionary*) params actionName:(NSString*) actionName requestPath:(HttpRequestPath) requestPath needCache:(BOOL) needCache;

-(void) decodeJSONObject:(NSDictionary *)resultData toClass:(NSString*)class returnResult:(ALDResult*) result;

-(void) decodeJSONArray:(NSDictionary *)jobj itemClass:(NSString*)class returnResult:(ALDResult*) result;

/**
 * 申请appid
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态，若成功obj为appid
 */
-(void)registAppId;

/**
 * 将获取到的push token传送到后台
 * @param appid 应用初始化申请的appid
 * @param deviceToken 获取到的设备push token
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) registPush:(NSString *)appid withDeviceToken:(NSString*) deviceToken;

/**
 * 用户账户登录
 * @param userName 用户名
 * @param pwd 密码
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为uid
 *   对code说明: 1：登录成功
 *              0：账号或密码错误
 *              2：账号因冻结等其他原因导致无法登录
 **/
-(void) loginWithUser:(NSString*)userName pwd:(NSString*) pwd;

/**
 * 用户数据验证接口
 * @param username 检查用户名是否存在
 * @param mobile 检查手机号是否存在
 * @param email 检查邮箱是否存在
 */
-(void) userDataVerify:(NSString*) username mobile:(NSString*) mobile email:(NSString*) email;

/**
 * 发送手机验证码
 * @param mobile 手机号
 * @param type 类型，1：注册，2：找回密码,3:创建/修改支付密码 4:绑定/重绑定手机
 **/
-(void) sendVerifyCode:(NSString*)mobile withType:(int) type;

/**
 * 验证手机验证码
 * @param mobile 手机号
 * @param type 类型，1：注册，2：找回密码，3：创建/修改支付密码 4:绑定/重绑定手机
 * @param code 验证码
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,code=1则返回result.obj为交换的token
 */
-(void) verifyCode:(NSString*) mobile type:(NSInteger) type code:(NSString*) code;

/**
 * 注册接口，支持手机注册和用户名密码注册
 * @param username 注册用户名或手机号,如果type=1则为手机号
 * @param password 设置密码 大于等于6小于16个字符
 * @param type 注册类型，1：手机号注册，2：用户名密码注册
 * @param token 验证验证码成功后交换的token 手机注册时必须传
 * @param invitationCode 注册邀请码,用于好友邀请注册
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) registerWithUser:(NSString*) username pwd:(NSString*) pwd type:(NSInteger) type token:(NSString*)token invitationCode:(NSString*) invitationCode;

/**
 * 第三方平台用户登录接口
 * @param openid 开放平台id
 * @param openType 开放平台类型，1：新浪微博 2：腾讯微博  3：网易微博  4：QQ  5:微信  6：淘宝
 * @param accessToken 开放平台授权令牌
 * @param accessSecret 开发平台授权secret	可能为空
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,result.obj为UserBean对象
 */
-(void) openUserLogin:(NSString*) openid openType:(NSInteger) openType
          accessToken:(NSString*) accessToken accessSecret:(NSString*) accessSecret;

/**
 * 当第三方用户登录后，返回的isNew=1时(新用户)，无论用户绑定或不绑定系统用户都需要调用该接口，以在后台建立关联关系
 * @param id 第三方用户数据表id
 * @param username 用户名 可空
 * @param password 用户密码，MD5加密后的字符 可空
 * @return
 */
-(void) openUserRelevance:(NSString*) sid username:(NSString*) username pwd:(NSString*) password;

/**
 * 用户登录后绑定第三方平台账户接口
 * @param openid 开放平台id
 * @param openType 开放平台类型，1：新浪微博 2：腾讯微博  3：网易微博  4：QQ  5:微信  6：淘宝
 * @param accessToken 开放平台授权令牌
 * @param accessSecret 开发平台授权secret	可能为空
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态
 */
-(void) openUserBind:(NSString*) openid openType:(NSInteger) openType
         accessToken:(NSString*) accessToken accessSecret:(NSString*) accessSecret;

/**
 * 用户密码修改接口
 * @param oldPwd 旧密码	跳过修改时只传该参数
 * @param pwd 新密码,大于等于6个字符
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyPassword:(NSString*) oldPwd pwd:(NSString*) pwd;

/**
 * 密码重置接口
 * @param mobile 手机号(即用户名)
 * @param pwd 设置密码 大于等于6个字符
 * @param token 验证验证码成功后交换的token
 * @return 结果以接口回调dataLoadDone(httpClient,code,obj)通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) resetPassword:(NSString*) mobile pwd:(NSString*) pwd token:(NSString*)token;

/**
 * 创建或修改支付密码接口
 * @param mobile 手机号
 * @param token 验证验证码成功后交换的token
 * @param payPassword 新密码,等于6个字符
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyPayPassword:(NSString*) mobile token:(NSString*) token payPassword:(NSString*) payPassword;

/**
 * 获取用户信息
 * @param uid 用户id，如果为空则为查询当前登录用户信息
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) viewUserInfo:(NSString*) uid;

/**
 * 修改用户信息 如果只修改头像，则只传头像到后台
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyUserInfo:(UserInfoBean*) userInfo username:(NSString*) username email:(NSString*) email extra:(NSDictionary*) extra;

/**
 * 用户退出登录
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) logout;

/**
 * 获取我的积分记录
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为IntegralRecordsBean数组
 **/
-(void) queryIntegralRecords:(int) page pageCount:(int) pageCount;

/**
 * 获取我的关注
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserInfoBean数组
 **/
-(void) queryMyAttentions:(int) page pageCount:(int) pageCount;

/**
 * 获取我的粉丝
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserInfoBean数组
 **/
-(void) queryMyFans:(int) page pageCount:(int) pageCount;

/**
 * 获取我的玩友
 * @param page 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @param needReply	获取需要应答的好友请求数据时使用 1：是，其他否,不使用该参数则传null
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserBean数组
 **/
-(void) queryMyFriends:(int) page pageCount:(int) pageCount needReply:(NSNumber*) needReply;

/**
 * 获取消息中心数据接口
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为MessageBean对象
 **/
-(void) queryMessages:(NSString*) seq;

/**
 * 发送到朋友圈/微博信息
 * @param bean 朋友圈/微博数据bean
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) friendsCircleSend:(FriendsCircleBean*) bean;

/**
 * 获取朋友圈/微博内容列表
 * @param pagetag 分页标识，如果不传则为刷新或第一次获取数据(long)
 * @param pageCount 每页最大返回数，默认20
 * @param keyword 搜索关键字 搜索时用
 * @param moduleId 模块ID 通过模块id查找时用(int)
 * @param hot 是否热门 1.热门
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean列表
 */
-(void) friendsCircleTimelines:(NSNumber*) pagetag pageCount:(int)pageCount keyword:(NSString*) keyword moduleId:(NSNumber*)moduleId hot:(BOOL)hot;

/**
 * 获取朋友圈/微博内容详情
 * @param id 数据id
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean对象
 */
-(void) friendsCircleDetails:(NSString*) sid;

/**
 * 对话模式发送信息
 * @param bean 对话数据bean
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) chatSend:(ChatBean*) bean;

/**
 * 获取最新对话消息或聊天记录接口
 * @param pagetag 分页标识,不传则取最新的未读消息
 * @param pageCount 每页最大返回数，默认20
 * @param 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ChatBean数组
 * @return @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ChatBean列表
 **/
-(void) chatMessages:(NSNumber*) pagetag pageCount:(int) pageCount;

/**
 * 对话消息处理反馈接口
 * @param pagetag 分页标识
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) chatFeedback:(NSNumber*) pagetag;

/**
 * 发表评论接口
 * @param type 评论类型，1：朋友圈/微博内容；2：活动内容
 * @param sourceId 源数据id
 * @param content 评论内容，如果为语音则为语音url
 * @param contentType 评论内容类型：1.文本，2.语音，暂时只做文本评论，默认为文本
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) commentSend:(int) type sourceId:(NSString*) sourceId content:(NSString*) content contentType:(int) contentType;

/**
 * 发表评论接口(type=1朋友圈/微博内容； type=2活动内容 评论)
 * @param bean 评论数据bean,评论内容和附件不能同时为空
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为新增的id
 */
-(void) commentSend:(CommentBean*) bean;

/**
 * 获取评论数据列表
 * @param type 数据类型，1：朋友圈/微博内容；2：活动内容
 * @param sourceId 源数据id
 * @param pagetag 分页标识，为空则为刷新或第一次获取
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为CommentBean列表
 */
-(void) commentList:(int) type sourceId:(NSString*) sourceId pagetag:(NSNumber*) pagetag pageCount:(int) pageCount;

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
-(void) eventList:(int) page pageCount:(int) pageCount keyword:(NSString*) keyword type:(NSString*) type tag:(NSString*) tag orderBy:(NSString*) orderBy;

/**
 * 获取活动详情信息接口，如果要展示活动详情，需要使用EventBean.detailsUrl的Html页面
 * @param eventId 活动id
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ActivityBean对象
 **/
-(void) viewEventDetails:(NSString*) eventId;

/**
 * 获取活动下的报名人员
 * @param sid活动id
 * @param page 页码
 * @param pageCount 最大分页数
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为UserBean对象
 **/
-(void) queryApplyMembers:(NSString *)sid page:(int) page pageCount:(int) pageCount;

/**
 * 删除数据接口,朋友圈/微博、朋友圈/微博评论或活动评论删除时调用接口
 * @param idList 源数据id(String数组)列表
 * @param type 数据类型 1：朋友圈/微博、2：朋友圈/微博评论、3：活动评论 4.贴吧回帖 5.帖子
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ResultStatusBean列表
 */
-(void) dataDelete:(NSArray*) idList type:(int) type;

/**
 * 数据收藏/取消收藏接口 朋友圈/微博内容或活动等收藏/取消收藏操作接口
 * @param idList 源数据id列表
 * @param type 数据类型 1:朋友圈/微博、2：活动
 * @param opt 1:收藏，-1：取消收藏
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为ResultStatusBean列表
 */
-(void) dataFavoriteOpt:(NSArray*) idList type:(int) type opt:(int) opt;

/**
 * 查询我的收藏数据
 * @param type 数据类型 1:朋友圈/微博 2:活动
 * @param page 页面 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean或ActivityBean列表
 */
-(void) queryMyFavorites:(int) type page:(int) page paeCount:(int) pageCount;

/**
 * 查询我发送的朋友圈数据
 * @param page 页面 分页页码，从1开始
 * @param pageCount 每页最大返回数，默认20
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为FriendsCircleBean列表
 */
-(void) queryMyFriendsCircle:(int) page pageCount:(int) pageCount;

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
          contacts:(NSString*) contacts email:(NSString*) email extra:(NSDictionary*) extra;

/**
 * 点赞操作接口
 * @param id 源数据id
 * @param type 数据类型 1.朋友圈，2.其他
 * @param opt 操作，1：赞，-1：取消赞
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为JSONObject对象
 * 	内含 praiseNum 属性(当前已赞数)和praiseAble属性(是否还可赞，1：可赞，其他否)
 */
-(void) dataPraise:(NSString*) sid type:(int) type opt:(int) opt;

/**
 * 数据转发(转发到微信、微博等)成功通知后台
 * @param id 源数据id
 * @param type 1.朋友圈，2.其他
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) dataForwardResult:(NSString*) sid type:(int) type;

/**
 * 关注/取消关注操作
 * @param uid 待关注的用户id
 * @param opt 操作，1：关注，-1：取消关注
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsAttention:(NSString*) uid opt:(int) opt;

/**
 * 请求添加好友接口
 * @param uid 待添加的用户id
 * @param content 验证消息
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsAdd:(NSString*) uid content:(NSString*) content;

/**
 * 删除好友接口
 * @param uid 待删除的用户id
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsDelete:(NSString*) uid;

/**
 * 处理添加好友请求
 * @param uid 待处理的用户id
 * @param opt 操作，1:接受请求，2:拒绝请求
 * @param content 拒绝理由	拒绝才有效
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsReply:(NSString *)uid opt:(int) opt content:(NSString*) content;

/**
 * 修改好友/关注人的备注
 * @param uid 待备注的用户id
 * @param type 好友类型，1:我的关注，2:好友
 * @param remark 备注信息
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) friendsRemark:(NSString*) uid type:(int) type remark:(NSString*) remark;

/**
 * 查询未读粉丝数量
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为未读粉丝数
 */
-(void) countUnreadFollowers;

/**
 * 粉丝标记为已读
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 */
-(void) followersReaded;

/**
 * 获取帮助数据
 * @param page 页码，从1开始
 * @param pageCount 每页最大返回数
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为HelpBean数组
 **/
-(void) queryHelps:(int) page pagecount:(int) pageCount;

/**
 * 设置文件存储命名空间
 * @param zone 命名空间，一般为项目名(英文字符)
 **/
+(void) setFileZone:(NSString *) zone;

/**
 * 文件上传(包括图片)接口
 * @param fileBean 媒体文件数据对象
 * @param path 模块路径 用于域下模块隔离,多级以/分隔
 * @param size 图片缩略尺寸如：64x64 图片上传和视频上传时可用，支持多个，多个示例：32x32_64x64
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result.obj为AttachmentBean对象
 **/
-(void) uploadFile:(MediaBean*) fileBean path:(NSString*)path thumbSize:(NSString*)thumbSize;

/**
 * 检查软件更新
 * @param appid 应用程序初始化时，服务端分配给应用程序的id
 **/
-(void)checkAppUpdate:(NSString *)appid;

/**
 * 获取关于数据url
 * @return 返回关于url
 */
+ (NSString*) getAboutUrl;

/**
 * 获取webView的扩展头
 * @param url 链接地址
 * @return 返回扩展头
 */
+(NSDictionary*) getExtraHeads:(NSString*) url;

/**
 * 返回参数错误
 *
 **/
-(void) returnParamsError:(HttpRequestPath) requestPath;

/**
 * 检查活动报名状态
 * sid活动id
 **/
//-(void) queryCheckApplyStatus:(NSString *)sid;

@end
