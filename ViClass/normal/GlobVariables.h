//
//  GlobalVariables.h
//  NetBusiness
//
//  Created by x-Alidao on 14-12-28.
//  Copyright (c) 2011年 guojun.zhu. All rights reserved.
//
#import "BasicsGlobVariables.h"

//数据接口服务器url
//#define kServerUrl @"http://192.168.3.105/fmopen/"
#define kServerUrl @"http://121.41.47.149/viket/"
//#define kServerUrl @"http://mobiren.gicp.net:8004/fmopen/"
//#define kServerUrl @"http://192.168.1.16/fmopen/"
//#define kServerUrl @"http://192.168.2.114:8080/fmopen/"
//#define kServerUrl @"http://192.168.2.112:8080/fmopen/"
//#define kServerUrl @"http://192.168.1.16/fmopen/"
//#define kServerUrl @"http://192.168.1.22/fmopen/"
//#define kServerUrl @"http://mobiren.gicp.net:8004/fmopen/"
//#define kServerUrl @"http://www.alidao.com:8081/fmopen/"
//#define kServerUrl @"http://www.alidao.com:9080/fmopen/"

//图片上传服务器url
//#define kImageServerUrl @"http://192.168.1.16/mizar/"
#define kImageServerUrl @"http://121.41.47.149/mizar/"
//#define kImageServerUrl @"http://www.alidao.com:8081/mizar/"
//#define kImageServerUrl @"http://mobiren.gicp.net:8080/mizar/"
//#define kImageServerUrl @"http://www.alidao.com:8081/mizar/"
//#define kImageServerUrl  @"http://images.hwmao.com:8080/"

//签名秘钥
#define kSignSecretKey   @"viket2015"

/**
 * 使用高德API，请注册Key，注册地址：http://lbs.amap.com/console/key
 **/
#define kMapAPIKey @"8b1152f47d0d467f91351a1bc5c6fd04"

/*
* TODO:                  请填写您的应用的appkey和appsecret
 */
#define kTecentAppKey    @"1103839698"//@"100763337"
#define kTecentAppSecret @"LG6lo3AwxmuuFJXX"//@"a035276a999a67dfa2640168bc9efe37"

/*
* TODO:                  新浪微博appkey和appsecret
 **/
#define kWeiboAppKey     @"4117763823"
#define kWeiboAppSecret  @"49409716c751209e794c7d3b91cef01d"
#define kRedirectURI     @"http://www.alidao.com"

/*
* TODO:                  微信appkey和appsecret
 **/
#define kWeixinAppKey    @"wxab9bbd5de71cfd6f"
#define kWeixinAppSecret @"b0907f1a639e8dadc127238dab3779e1"

/*
* TODO:                  请填写您的应用的appkey和appsecret
 */
#define kWyAppKey        @"QEoSNxanTk6xaxXV"
#define kWyAppSecret     @"EMvPYRa85KhFqydqTZiZJ9bSyDmacUg2"

/*
 * TODO:                 请正确填写您的应用回调网址，否则将导致授权失败
 */
#define kRedirectUri     @"http://www.youhd.cn" //微博绑定回调Url



//###############
//颜色定义
#define kNavigationBarTextColor [UIColor          whiteColor]         //IOS导航栏的字体颜色值，IOS7有效
#define kNavBackgroundColor [UIColor          blackColor]
#define kBackgroudColor                       RGBCOLOR(248,248,248)//The background color of all view
#define kButtonBackgroundColor                RGBCOLOR(175,120,40) //按钮背景颜色
#define kButtonDisableBackgroundColor         RGBCOLOR(135,135,135)//按钮不可用背景颜色
#define KTableViewBackgroundColor             RGBCOLOR(248,248,248)//表的背景色
#define kButtonSelectBackgroundColor [UIColor orangeColor]         //按钮点击背景色
#define kBottomBgColor RGBCOLOR(246, 246, 246)

#define KBorderColor                 RGBCOLOR(22,68,118)
#define kNavColor                    RGBCOLOR(248,248,248)
#define kLineColor                   RGBCOLOR(204,204,204) //分割线颜色
#define KBgViewColor                 RGBCOLOR(248,248,248) //背景色
#define KClearColor                  [UIColor clearColor]
#define kTitleBarColor               RGBCOLOR(6, 95, 212) //标题栏颜色


#define kColorCommonBg           RGBCOLOR(243, 243, 243)         //页面默认背景颜色
#define kColorTopTitle           RGBCOLOR(215, 0, 15)            //页面顶部标题
#define kColorButton             RGBCOLOR(215, 0, 15)            //页面顶部标题
#define kColorButtonSelected     RGBCOLOR(235, 10, 15)           //页面顶部标题
#define kColorCellSelectedBg     RGBCOLOR(2,   108, 234)         //cell被点击时的背景颜色
#define kColorCellSeparatorLine  RGBCOLOR(225, 225, 225)         //cell分割线的颜色
#define kColorLayerBorder        RGBCOLOR(166, 166, 166)         //视图边框颜色
#define kColorNavBlack           RGBCOLOR(103, 182, 230)         //导航栏颜色

#define kLittleTitleColor        RGBCOLOR(87, 87, 87)            //二号标题颜色
#define kGrayFontColor           RGBCOLOR(153, 153, 153)         //灰色字体颜色
#define kViewCellBgColor         RGBACOLOR(255, 255, 255, 0.4)   //单元视图背景颜色
#define kTitleBarColor           RGBCOLOR(6, 95, 212)            //标题栏颜色
#define kBackBtnColor            RGBCOLOR(4, 57, 198)            //返回按钮颜色
#define kAnnounceTimeColor       RGBCOLOR(6, 95, 212)            //标题栏颜色
#define KBackGroundColor         RGBCOLOR(241, 247, 253)         //背景色
#define KNumLabelColor           RGBCOLOR(204, 51, 51)           //首页倒计时显示字体颜色
#define kHeaderSectionBgColor    RGBCOLOR(217, 213, 213)         //栏目分组头背景颜色
#define kLetterViewBgColor       RGBACOLOR(25, 122, 164, 0.6f)   //弹出字母的背景颜色
#define kColorSeparatorLine      RGBCOLOR(224,224,224)           //分割线颜色
#define kViewGrayBgColor         RGBACOLOR(0, 0, 0, 0.2)
#define kLabletitleColor         RGBCOLOR(38, 55, 66)
#define kTimesColor              RGBCOLOR(90,90, 90) //消息时间颜色

#define kLightTextColor          RGBCOLOR(166,166,166)          //灰色字体颜色
#define kBottomBarBgColor        RGBCOLOR(226,226,226)          //底部固定部分背景色
#define kNewsDetailTextColor     RGBCOLOR(90,90,90)             //消息详情文本颜色
#define kColorSeparatorLine      RGBCOLOR(224,224,224)
#define kColorDateText           RGBCOLOR(136,136,136)          //日期，地址字体颜色

//字体颜色
#define KWordBlackColor              RGBCOLOR(30,30,30)
#define KWordGrayColor               RGBCOLOR(130,130,130)
#define KWordWhiteColor              RGBCOLOR(255,255,255)
#define KGreenColor                  RGBCOLOR(70,240,160)
#define KWordRedColor                RGBCOLOR(200,20,20)
#define KWordBlueColor               RGBCOLOR(0,128,238)
#define KOrangeColor                 RGBCOLOR(250,112,30)
#define KBtnBgColor                  RGBCOLOR(250,112,30)

#define KBtnLoginBgColor             RGBCOLOR(250,112,30)
#define KBtnTitleColor               RGBCOLOR(255, 255, 255)
#define FriendsCircleNameColor       RGBCOLOR(0,128,238)

//圆圈状态
#define kCirlurProgressColor RGBCOLOR(250,112,30)

//Notificition
#define kServiceNumber     @"0578-2055399"   //客服服务电话

#define kAnimationImg      @"logo"
#define kAnimationDuration 0.5f
#define kCoverViewTag      0x3001
#define shareTitle         @"开吧应用邀请"
#define shareDescription   @"要分钱，至少你要在（载）。亲！我在，你来吧？快来下载好玩猫APP，玩分享、玩分钱、玩游戏！"

//-------------------------------
// 视图属性
//-------------------------------
#define kViewBorderWidth   1
#define kViewButtonRadius  3 //按钮圆角
#define kViewCornerRadius  3
#define kMoreDataRowHeight 40

#define kPageCount         20
#define kAdd               1
#define kUpdate            2
#define kUpdateSub         3
#define kDelete            -1

//登录注册相关
#define KRegisterTip @"请输入您的国家或地区手机号码"
#define KRegisterTipFont [UIFont systemFontOfSize:17.f]
#define KRegisterTipColor RGBCOLOR(142,142,142)

#define PlateFollowOpt @"plateFollowOpt"

//发布说说时附件图片的最大数
#define kMaxPhotoCount 9
//发布说说时图片每行的最大数
#define kMaxLinePhoto 5
#define KBottomHeight 44
#define KLastLat @"lastLat"
#define KLastLng @"lastLng"
#define KLastAddress @"lastAddress"

#define MyLocalizedString(key, defValue) \
[[NSBundle mainBundle] localizedStringForKey:(key) value:defValue table:nil]


