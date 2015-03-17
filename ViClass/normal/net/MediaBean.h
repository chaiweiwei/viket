//
//  MediaBean.h
//  Basics
//  媒体数据bean
//  Created by chen yulong on 14/12/9.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFileTypeOfImage @"image" //图片
#define kFileTypeOfAudio @"audio" //音频
#define kFileTypeOfVideo @"video" //视频
#define kFileTypeOfFile  @"file" //文件

@interface MediaBean : NSObject
/** 媒体数据类型，可选类型[file|image|audio|video] **/
@property (retain,nonatomic) NSString *type;
/** 文件二进制数据	 **/
@property (retain,nonatomic) NSData *data;
/** 文件名称 **/
@property (retain,nonatomic) NSString *fileName;
/** 内容类型，用于http提交 **/
@property (retain,nonatomic) NSString *contentType;
/** 是否进行语音识别 **/
@property (retain,nonatomic) NSNumber *reco;
/** 图片宽 **/
@property (retain,nonatomic) NSNumber *width;
/** 图片高 **/
@property (retain,nonatomic) NSNumber *height;


@end
