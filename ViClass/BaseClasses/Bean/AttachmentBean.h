//
//  AttachmentBean.h
//  TZAPP
//  附件数据bean
//  Created by chen yulong on 14-8-28.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecoBean.h"

@interface AttachmentBean : NSObject

/** 附件id **/
@property (retain,nonatomic) NSString *sid;
/** 附件类型,1:图片，2：语音，3：视频,4：其他 **/
@property (retain,nonatomic) NSNumber *type;
@property (retain,nonatomic) NSString *name;//文件名
/** 附件上传后的url **/
@property (retain,nonatomic) NSString *url;
/** 缩略图url **/
@property (retain,nonatomic) NSString *thumbnail;
/** 时长，单位秒 **/
@property (retain,nonatomic) NSNumber *times;
/** 附件大小，单位Bit **/
@property (retain,nonatomic) NSNumber *size;
/** 宽，单位像素 **/
@property (retain,nonatomic) NSNumber *width;
/** 高，单位像素 **/
@property (retain,nonatomic) NSNumber *height;
/** 语音识别结果 **/
@property (retain,nonatomic) RecoBean *recoBean;

/** 缩略图组,key为上传时的尺寸 **/
@property (retain,nonatomic) NSDictionary *thumbs;
/** 本地路径 **/
@property (retain,nonatomic) NSString *localPath;
/**
 * 转换成NSDictionary
 **/
-(NSDictionary*) toDictionary;

@end
