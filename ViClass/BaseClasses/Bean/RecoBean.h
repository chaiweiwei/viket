//
//  RecoBean.h
//  WeTalk
//
//  Created by alidao on 14/12/16.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecoBean : NSObject

/** 语音识别响应码
 0.识别成功
 -1.没有调用权限
 -2.权限签名错误
 -3.语音文件过大
 -4，不支持的格式
 -5.未找到该语音
 -6.未开启该服务
 -7.语音识别异常
 **/
@property (nonatomic,retain) NSNumber *errcode;
/** 语音识别提示 **/
@property (nonatomic,retain) NSString *errmsg;
/** 识别结果 **/
@property (nonatomic,retain) NSString *content;

@end

