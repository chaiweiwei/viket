//
//  GlobalVariables.h
//  NetBusiness
//
//  Created by 朱 国军 on 11-12-27.
//  Copyright (c) 2011年 guojun.zhu. All rights reserved.
//

typedef enum
{
    HasSetSinaWeibo, //已经设置新浪微博
    HasSetTecentWeibo, //已经设置腾讯微博
    HasSetWyWeibo, //网易微博
    HasSetSinaAndWyWeibo, //新浪和网易微博
    HasSetSinaAndTecentWeibo, //新浪和腾讯微博
    HasSetTecentAndWyWeibo, //腾讯和网易微博
    HasSetAllWeibo, //新浪和腾讯微博都已设置
}HasSetWeibo;

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define kSystemLanguage    [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] //系统语言

//获取屏幕高度
#define screenHight [UIScreen mainScreen].bounds.size.height //屏幕高度
#define screenWidth [UIScreen mainScreen].bounds.size.width  //屏幕宽度
#define kMoreButtonHeight 35 //列表更多按钮高度

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


//设备相关配置
#define kIdentifier [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]] //包名
#define kSoftwareName [NSString stringWithFormat:@"%@-IOS版",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]] //软件名称
#define kSoftwareVersion [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] //软件版本
#define kPublishChannel @"www.uhuiyi.com" //是通过什么渠道下载安装的（程序打包时封装好的）
#define kMobileResolution @"320*480" //手机分辨率（width*height）
#define kIsTouch @"2" //是否支持触摸(1 键盘,2触摸,3键盘触摸皆可)
#define kMobileBrandModel [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemName]] //手机品牌和型号
#define kSdkVersion [NSString stringWithFormat:@"%@",[[UIDevice currentDevice] systemVersion]] //sdk版本号
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define kKernelVersion @"2.0" //内核版本号
#define kBuilderNumber @"1.0" //版本号
#define kFirmwareConfiguationVersion @"1.0" //固件版本号
#define kSupportNetwork @"wifi,2G,3G" //支持通信模式
#define kBrowserKernel @"0022" //浏览器内核

#define kUidKey @"uid" //用户id key
#define kSessionIdKey @"sessionId" //用户会话id
#define kUserNameKey @"userName" //用户名(注册手机号)
#define KNickNameKey @"nickName" //昵称
#define KIconKey @"iconImage" //昵称
#define kAutoCheckAppUpdateKey @"autoCheckAppUpdate" //自动检测app更新
#define KUserInfoExtra @"userInfoExtra" //userinfoBean的扩展字段
#define KPostionkey @"position"
#define KCompanyKey @"company"
#define kNameKey @"Name"
#define kHeadUrlKey @"headUrl"
#define kSeqKey @"seq" //推送数据序列
#define KBageCount @"bageCount"
#define KUserStatus @"userStatus"

#define KWeixinCode @"weixinCode"
#define KWeixinToken @"weixinToken"
#define KWeixinOpenId @"weixinOpenId"

#define kDeviceTokenKey @"deviceToken" //手机push注册token
#define kNeedSendTokenKey @"needSendToken" //是否需要发送token到服务器
#define kAppidKey @"myAppId"
#define kConfidKey @"confid" //会议id存储key
#define kDefaultConfidKey @"defaultConfid" //初始化APPSN时的会议id
#define kLastCheckAppTimeKey @"lastCheckAppTime" //最后检查应用更新的时间
#define kLastTimeKey @"lastTime" //数据最后同步时间
#define kLastTimeOfSessionKey @"lastTimeOfSession" //会话最后同步时间
#define kUpdateRecordsKey @"update_records" //数据更新数记录
#define kLastCheckNotifyTimeKey @"lastCheckNotifyTime" //最后检查消息提醒时间
#define kLastBindSinaWeiboTimeKey @"lastBindSinaWeiboTime" //最后一次绑定新浪微博时间key
#define kLastBindTecentWeiboTimeKey @"lastBindTecentWeiboTime" //最后一次绑定腾讯微博时间key
#define kLastBindWyWeiboTimeKey @"lastBindWyWeiboTime" //最后一次绑定网易微博时间key
#define kDefaultWeiboTypeKey @"default_weibo_type" //默认使用的发送微博类型
#define kALDREFRASHDATANOTIFICATION @"refrash_data_notification" //新登录通知name
#define kWeixinShareSuccessNotification @"WeixinShareSuccessNotification" //微信分享成功通知
#define KModifyBageCount @"modifyBageCount"
#define KOpenApiResult @"openApiResult" //第三方登录结果通知

//----------------------------------------------------------------------------------------------
#define kLayerBorderColor        RGBCOLOR(204, 204, 204)         //视图边框颜色

//列表标题字体,大小28px
#define kListTitleFont [UIFont boldSystemFontOfSize:16.0]
#define KUpdateUserInfoKey @"updatedUserInfo" //用户信息修改通知
#define KLoginSucessKey @"loginSucess" //登录成功通知
#define KLoginFailKey @"loginFail" //登录失败

//以下是一些数据请求错误码的定义
#define kDATA_ERROR -500 //返回数据格式错误
#define kNET_ERROR -400  //网络异常
#define kSTORE_ERROR -300 //数据存储错误
#define kNET_TIMEOUT -100 //网络超时
#define kHOST_ERROR -3  //主机异常
#define kPARAM_ERROR -2 //参数错误
#define kAPPID_ERROR -1 //appid非法或分配失败
#define kNO_RESULT 0 //请求结果为空
#define KOK 1 //请求OK
#define kNO_UPDATE 304 //没有数据更新
#define kERROR_REQUEST 400 //其他任何非法请求
#define kNOT_AUTHORIZED 401 //请求未授权

#define kAutoCheckKey @"auto_check"
#define kHasRun @"hasRun" //是否是第一次进入app

#define kNormalFontColor         [UIColor blackColor]            //普通字体颜色
#define kRedFontColor            [UIColor redColor]              //红色字体颜色
#define kLetterColor             [UIColor grayColor]             //字母查找字母的字体颜色
#define kTitleColor              RGBCOLOR(0, 0, 0)               //标题颜色
//#define kNavigationBarTextColor  [UIColor whiteColor]

//----------------------------------------------------------------------------------------------
// 字体类

#define kFontSize20px [UIFont systemFontOfSize:10.f]
#define KFontSizeBold20px [UIFont boldSystemFontOfSize:10.f]
#define kFontSize22px [UIFont systemFontOfSize:11.f]
#define KFontSizeBold22px [UIFont boldSystemFontOfSize:10.f]
#define kFontSize24px [UIFont systemFontOfSize:12.f]
#define KFontSizeBold24px [UIFont boldSystemFontOfSize:12.f]
#define kFontSize26px [UIFont systemFontOfSize:13.f]
#define KFontSizeBold26px [UIFont boldSystemFontOfSize:13.f]
#define kFontSize28px [UIFont systemFontOfSize:14.f]
#define KFontSizeBold28px [UIFont boldSystemFontOfSize:14.f]
#define kFontSize30px [UIFont systemFontOfSize:15.f]
#define KFontSizeBold30px [UIFont boldSystemFontOfSize:15.f]
#define kFontSize32px [UIFont systemFontOfSize:16.f]
#define KFontSizeBold32px [UIFont boldSystemFontOfSize:16.f]
#define kFontSize34px [UIFont systemFontOfSize:17.f]
#define KFontSizeBold34px [UIFont boldSystemFontOfSize:17.f]
#define kFontSize36px [UIFont systemFontOfSize:18.f]
#define KFontSizeBold36px [UIFont boldSystemFontOfSize:18.f]
#define kFontSize38px [UIFont systemFontOfSize:19.f]
#define KFontSizeBold38px [UIFont boldSystemFontOfSize:19.f]
#define kFontSize40px [UIFont systemFontOfSize:20.f]
#define KFontSizeBold40px [UIFont boldSystemFontOfSize:20.f]


#define MyLocalizedString(key, defValue) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:defValue table:nil]

/**
 * 消息类型
 **/
typedef NS_ENUM(NSInteger, PushMessageType){
    PushMessageTypeDefault          = 0, //普通通知
    PushMessageTypeRegister              //注册通知
};


