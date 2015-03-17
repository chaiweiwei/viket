//
//  FileDao.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/5.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "ALDBaseDao.h"
#import "ClassRoomBean.h"
#import "ChapterBean.h"
#import "ChapterDao.h"

@interface FileDao : ALDBaseDao

/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) addFileData:(ClassRoomBean *) bean;

/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) updateFileData:(ClassRoomBean *) bean;

/**
 * 删除课程所有缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteFileData:(NSString*) sid;
/**
 * 删除课程所有缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteFileData;
/**
 *  查询课程缓存
 *
 *  @param uid 用户ID
 *  @param sid 课程ID
 *
 *  @return <#return value description#>
 */
-(NSArray *) queryFileData;
@end
