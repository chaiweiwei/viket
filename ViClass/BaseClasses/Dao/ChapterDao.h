//
//  ChapterDao.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/5.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "ALDBaseDao.h"
#import "ChapterBean.h"
#import "AttachmentBean.h"

@interface ChapterDao : ALDBaseDao

/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) addChapterData:(ChapterBean *)bean classId:(NSString *)classId;

/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) updateChapterData:(ChapterBean *)bean classId:(NSString *)classId;
/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteChapterData;
/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteChapterData:(NSString*) sid classId:(NSString *)classId;
/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteChapterData:(NSString *)classId;
/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(NSArray *) queryChapterData:(NSString *)classId;

/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(ChapterBean *) queryChapterData:(NSString *)sid classId:(NSString *)classId;
@end
