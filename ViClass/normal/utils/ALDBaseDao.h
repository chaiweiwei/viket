//
//  ALDBaseDao.h
//  why
//  数据库表操作基类
//  Created by yulong chen on 12-4-12.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface ALDBaseDao : NSObject{
    FMDatabase *_db;
    NSString *_tbname;
    id<NSLocking> _lock;
}

@property (nonatomic, retain) FMDatabase *db;
@property (nonatomic, retain) id<NSLocking> lock;
@property (nonatomic, retain) NSString *tbname;

/**
 *  使用表名创建对象，使用该方法需要在AppDelegate中实现getDatabase(返回FMDatabase对象)和getLock(返回NSLock对象)方法
 *  @param tbname 表名
 **/
-(id) initWithTbname:(NSString *) tbname;

/**
 *  使用表名创建对象
 *  @param tbname 表名
 *  @param db 数据库对象
 *  @param lock 数据库操作锁
 **/
-(id) initWithTbname:(NSString *) tbname db:(FMDatabase*)db lock:(id<NSLocking>)lock;

-(BOOL) createTable;

-(BOOL) executeUpdate:(NSString *) sql;

-(BOOL) executeUpdate:(NSString *) sql withArgumentsInArray:(NSArray*)arguments;

-(FMResultSet *) excecuteQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arguments;

/**
 * 插入数据
 * @param keyValues 待插入的数据键值对
 * @return 成功返回YES,失败返回NO
 */
-(BOOL) insert:(NSDictionary *) keyValues;

/**
 * 修改数据
 * @param keyValues 待修改的数据键值对
 * @param whereClause where后面的条件语句
 * @param 用于填充whereClause的参数列表
 * @return 成功返回YES,失败返回NO
 */
-(BOOL) update:(NSDictionary *) keyValues whereClase:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs;

/**
 * 删除数据
 * @param whereClause where后面的条件语句
 * @param 用于填充whereClause的参数列表
 * @return 成功返回YES,失败返回NO
 */
-(BOOL) delete:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs;

/**
 * 数据查询
 * @param columns 要查询的列，多列以,分隔
 * @param whereClause where后面的条件语句，不包括where关键字部分
 * @param selectionArgs 用于填充whereClause的参数列表
 * @return  该语句返回结果集，使用完该结果集需调用FMResultSet.close释放
 */
-(FMResultSet *) query:(NSString *)columns whereCaluse:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs;

/**
 * 数据查询
 * @param columns 要查询的列，多列以,分隔
 * @param whereClause where后面的条件语句，不包括where关键字部分
 * @param selectionArgs 用于填充whereClause的参数列表
 * @param orderBy 排序语句，不包括order by关键字部分
 * @param limit 记录分页选取，不包括limit关键字部分
 * @return  该语句返回结果集，使用完该结果集需调用FMResultSet.close释放
 */
-(FMResultSet *) query:(NSString *)columns whereCaluse:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs orderBy:(NSString *)orderBy limit:(NSString *) limit;

/**
 * 数据查询
 * @param columns 要查询的列，多列以,分隔
 * @param whereClause where后面的条件语句，不包括where关键字部分
 * @param selectionArgs 用于填充whereClause的参数列表
 * @param groupBy 分组语句,不包括group关键字部分
 * @param having 结果集筛选语句，不包括having关键字部分
 * @param orderBy 排序语句，不包括order by关键字部分
 * @param limit 记录分页选取，不包括limit关键字部分
 * @return  该语句返回结果集，使用完该结果集需调用FMResultSet.close释放
 */
-(FMResultSet *) query:(NSString *)columns whereCaluse:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs groupBy:(NSString *) groupBy having:(NSString *) having orderBy:(NSString *)orderBy limit:(NSString *) limit;

/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 */
-(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value;

/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 * defaultValue 默认值，当value为nil时使用该值代替
 */
-(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value withDefault:(id) defaultVaule;

/**
 * 统计表记录数
 */
-(long) countTable;

/**
 * 清理数据
 **/
-(BOOL) clearData;
@end
