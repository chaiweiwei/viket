//
//  MessageDao.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/13.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "ALDBaseDao.h"
#import "NewBean.h"

@interface MessageDao : ALDBaseDao

/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) addMeaasgeData:(NewBean *)bean;

/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteMeaasgeData:(NSString *)sid;

-(NSArray *) queryMeaasgeData;

@end
