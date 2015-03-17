//
//  NCDao.h
//  Zenithzone2
//  消息中心Dao
//  Created by alidao on 14/11/27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "ALDBaseDao.h"
#import "NCBean.h"

@interface NCDao : ALDBaseDao

/**
 * 新增通知,存在则更新
 * @param ncBean 通知bean
 * @return 成功返回true,失败返回false
 */
-(BOOL) addNC:(NCBean *) ncBean;

/**
 * 更新通知,不存在则新增
 * @param ncBean 通知bean
 * @return 成功返回true,失败返回false
 */
-(BOOL) updateNC:(NCBean *) ncBean;

/**
 * 根据用户id查询通知
 * @param uid 用户id
 * @param t 通知类型 0.通知 1.@我 3.评论 4.赞
 * @return 返回NCBean数组
 */
-(NSArray *)queryAllNCs:(NSString *)uid t:(NSNumber *)t;


@end
