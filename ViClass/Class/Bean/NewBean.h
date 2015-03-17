//
//  NewBean.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewBean : NSObject

@property (nonatomic,copy) NSString *sid;//数据id
@property (nonatomic,copy) NSString *title;//标题
@property (nonatomic,copy) NSString *type;//消息类型
@property (nonatomic,copy) NSString *content;//内容
@property (nonatomic,copy) NSString *createTime;//消息发布时间
@property (nonatomic,copy) NSString *detailUrl;//消息详情H5页面URL
@property (nonatomic,assign) int status;//1：已读 0：未读

@end
