//
//  UserDao.h
//  ZYClub
//  用户dao
//  Created by chen yulong on 14-3-19.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "ALDBaseDao.h"
#import "UserBean.h"

@interface UserDao : ALDBaseDao
/**
 * 新增用户,存在则更新
 * @param bean 用户数据bean
 * @return 成功返回true,失败返回false
 */
-(BOOL) addUser:(UserBean *) bean;

/**
 * 更新用户数据,不存在则新增
 * @param User 用户数据对象
 * @return 成功返回true,失败返回false
 */
-(BOOL) updateUser:(UserBean *) bean;

/**
 * 修改头像
 * @param uid 用户id
 * @param avatar 头像url
 * @return 成功返回true,失败返回false
 **/
-(BOOL) updateHeadWithUid:(NSString*) uid withAvator:(NSString*) avatar;

/**
 * 删除用户
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteUser:(NSString*) uid;

/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(UserBean *) queryUser:(NSString*)uid;


@end
