//
//  TimeDao.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/9.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "ALDBaseDao.h"

@interface TimeDao : ALDBaseDao
/**
 *  新增登陆时间记录,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) addTimeData:(NSString *)time;

/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(NSArray *) queryTimeData;


@end
