//
//  ALDBaseDao.m
//  why
//  数据库表操作基类
//  Created by yulong chen on 12-4-12.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import "ALDBaseDao.h"
//#import "ALDAppDelegate.h"
#import "ALDUtils.h"


@implementation ALDBaseDao
@synthesize db=_db,tbname=_tbname;
@synthesize lock=_lock;

/**
 *  使用表名创建对象，使用该方法需要在AppDelegate中实现getDatabase(返回FMDatabase对象)和getLock(返回NSLock对象)方法
 *  @param tbname 表名
 **/
-(id) initWithTbname:(NSString *) tbname{
    id appDelegate =[[UIApplication sharedApplication] delegate];
    FMDatabase *db=nil;
    if ([appDelegate respondsToSelector:@selector(getDatabase)]) {
        db=[appDelegate performSelector:@selector(getDatabase) withObject:nil];
    }
    NSAssert(db!=nil,@"You have not implements the method getDatabase in AppDelegate,so you can call the method initWithTbname:db:lock:");
    id<NSLocking> lock=nil;
    if ([appDelegate respondsToSelector:@selector(getLock)]) {
        lock=[appDelegate performSelector:@selector(getLock) withObject:nil];
    }
    self = [self initWithTbname:tbname db:db lock:lock];
    return self;
}

/**
 *  使用表名创建对象
 *  @param tbname 表名
 *  @param db 数据库对象
 *  @param lock 数据库操作锁
 **/
-(id) initWithTbname:(NSString *)tbname db:(FMDatabase *)db lock:(id<NSLocking>)lock{
    self = [super init];
    if (self) {
        self.tbname=tbname;
        self.db = db;
        self.lock=lock;
        if(![self createTable]){
            NSLog(@"createTable error,table name:%@",_tbname);
        }
    }
    return self;
}

//实现表的创建，该方法必须由子类实现，否则抛出异常
-(BOOL) createTable{
    //NSLog(@"Sub class has no implements this method");
    //[NSException raise:@"Sub class must implements this method:createTable" format:@" class:%@", [self description]];
    return NO;
}

-(BOOL) executeUpdate:(NSString *) sql{
    BOOL success=NO;
    [_lock lock];
    //NSLog(@"锁定数据库更新操作锁***** table name:%@",_tbname);
    //@synchronized(_db){
    @try {
        success=[_db executeUpdate:sql];
        if ([_db hadError]) {
            success=NO;
            NSLog(@"Table:%@ SQL Error %d: %@",_tbname, [_db lastErrorCode], [_db lastErrorMessage]);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"executeUpdate exception:%@",exception);
    }
    @finally {
        [_lock unlock];
       // NSLog(@"释放数据库更新操作锁***** table name:%@",_tbname);
    }  
    //}
    return success;
}

-(BOOL) executeUpdate:(NSString *) sql withArgumentsInArray:(NSArray*)arguments{
    BOOL success=NO;
    //@synchronized(_db){
    [_lock lock];
    //NSLog(@"锁定数据库更新操作***** table name:%@",_tbname);
    @try {
        success=[_db executeUpdate:sql withArgumentsInArray:arguments];
        if ([_db hadError]) {
            success=NO;
            NSLog(@"Table:%@ SQL Error %d: %@",_tbname, [_db lastErrorCode], [_db lastErrorMessage]);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"executeUpdate exception:%@",exception);
    }
    @finally {
        [_lock unlock];
        //NSLog(@"释放数据库更新操作锁***** table name:%@",_tbname);
    }
    //}
    return success;
}

-(FMResultSet *) excecuteQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arguments{
    FMResultSet *result=nil;
    [_lock lock];
    @try {
        result=[_db executeQuery:sql withArgumentsInArray:arguments];
    }
    @catch (NSException *exception) {
        NSLog(@"excecuteQuery exception:%@",exception);
    }
    @finally {
        [_lock unlock];
    }
    return result;
}

/**
 * 插入数据
 * @param keyValues 待插入的数据键值对
 * @Return 成功返回YES,失败返回NO
 */
-(BOOL) insert:(NSDictionary *) keyValues{
    NSArray *keys=[keyValues allKeys];
    NSArray *values=[keyValues allValues];
    NSString *cols=@"";
    NSString *replace=@"";
    int count=0;
    for(id key in keys){
        if(count==0){
            cols=[cols stringByAppendingString:key];
            replace=[replace stringByAppendingString:@"?"];
        }else {
            cols=[cols stringByAppendingFormat:@",%@",key];
            replace=[replace stringByAppendingString:@",?"];
        }
        count+=1;
    }
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)",_tbname,cols,replace];
    return [self executeUpdate:sql withArgumentsInArray:values];
}

/**
 * 修改数据
 * @param keyValues 待修改的数据键值对
 * @param whereClause where后面的条件语句
 * @param 用于填充whereClause的参数列表
 * @return 成功返回YES,失败返回NO
 */
-(BOOL) update:(NSDictionary *) keyValues whereClase:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs{
    if(!whereClause || [whereClause isEqualToString:@""]){
        NSLog(@"whereClause is null");
        return NO;
    }
    NSArray *keys=[keyValues allKeys];
    NSArray *values=[keyValues allValues];
    NSString *cols=@"";
    int count=0;
    for(id key in keys){
        if(count==0){
            cols=[cols stringByAppendingFormat:@" %@=? ",key];
        }else {
            cols=[cols stringByAppendingFormat:@", %@=? ",key];
        }
        count+=1;
    }
    NSString *sql;
    sql=[NSString stringWithFormat:@"update %@ set %@ where %@",_tbname,cols,whereClause];
    BOOL success;
    if(selectionArgs && selectionArgs.count>0){
        NSMutableArray *params=[NSMutableArray arrayWithArray:values];
        [params addObjectsFromArray:selectionArgs];
        success=[self executeUpdate:sql withArgumentsInArray:params];
    }else{
        success=[self executeUpdate:sql withArgumentsInArray:values];
    }
    return success;
}

/**
 * 删除数据
 * @param whereClause where后面的条件语句
 * @param 用于填充whereClause的参数列表
 * @return 成功返回YES,失败返回NO
 */
-(BOOL) delete:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs{
    NSString *sql;
    BOOL success;
    if(whereClause && ![whereClause isEqualToString:@""]){
        sql=[NSString stringWithFormat:@"delete from %@ where %@",_tbname,whereClause];
        if(selectionArgs && selectionArgs.count>0){
            success=[self executeUpdate:sql withArgumentsInArray:selectionArgs];
        }else {
            success=[self executeUpdate:sql];
        }
    }else{
        sql=[NSString stringWithFormat:@"delete from %@",_tbname];
        success=[self executeUpdate:sql];
    }
    return success;
}

/**
 * 数据查询
 * @param columns 要查询的列，多列以,分隔
 * @param whereClause where后面的条件语句，不包括where关键字部分
 * @param selectionArgs 用于填充whereClause的参数列表
 * @return  该语句返回结果集，使用完该结果集需调用FMResultSet.close释放
 */
-(FMResultSet *) query:(NSString *)columns whereCaluse:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs{
    return [self query:columns whereCaluse:whereClause selectionArgs:selectionArgs orderBy:nil limit:nil];
}

/**
 * 数据查询
 * @param columns 要查询的列，多列以,分隔
 * @param whereClause where后面的条件语句，不包括where关键字部分
 * @param selectionArgs 用于填充whereClause的参数列表
 * @param orderBy 排序语句，不包括order by关键字部分
 * @param limit 记录分页选取，不包括limit关键字部分
 * @return  该语句返回结果集，使用完该结果集需调用FMResultSet.close释放
 */
-(FMResultSet *) query:(NSString *)columns whereCaluse:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs orderBy:(NSString *)orderBy limit:(NSString *) limit{
    return [self query:columns whereCaluse:whereClause selectionArgs:selectionArgs groupBy:nil having:nil orderBy:orderBy limit:limit];
}

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
-(FMResultSet *) query:(NSString *)columns whereCaluse:(NSString *) whereClause selectionArgs:(NSArray *)selectionArgs groupBy:(NSString *) groupBy having:(NSString *) having orderBy:(NSString *)orderBy limit:(NSString *) limit{
    if(!columns || [columns isEqualToString:@""]){
        columns=@"*";
    }
    NSString *sql=[NSString stringWithFormat:@"SELECT %@ FROM %@ ",columns,_tbname];
    if(whereClause && ![whereClause isEqualToString:@""]){
        sql=[sql stringByAppendingFormat:@" where %@ ",whereClause];
    }
    
    if(groupBy && ![groupBy isEqualToString:@""]){
        if(having && ![having isEqualToString:@""]){
            sql=[sql stringByAppendingFormat:@" GROUP BY %@ HAVING %@",groupBy,having];
        }else{
            sql=[sql stringByAppendingFormat:@" GROUP BY %@ ",groupBy];
        }
    }
    
    if(orderBy && ![orderBy isEqualToString:@""]){
        sql=[sql stringByAppendingFormat:@" ORDER By %@ ",orderBy];
    }
    
    if(limit && ![limit isEqualToString:@""]){
        sql=[sql stringByAppendingFormat:@" LIMIT %@ ",limit];
    }
    
    FMResultSet *rs=nil;
    //@synchronized(_db){
    [_lock lock];
    //NSLog(@"锁定数据库查询操作***** table name:%@",_tbname);
    //NSLog(@"sql:%@,params:%@",sql,selectionArgs);
    @try {
        if(whereClause && ![whereClause isEqualToString:@""] && selectionArgs && selectionArgs.count>0){
            rs=[_db executeQuery:sql withArgumentsInArray:selectionArgs];
        }else{
            rs=[_db executeQuery:sql];
        }
        if ([_db hadError]) {
            NSLog(@"SQL Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"executeQuery exception:%@",exception);
    }
    @finally {
        [_lock unlock];
        //NSLog(@"释放数据库查询操作锁***** table name:%@",_tbname);
    }
    //}
        
    return rs;
}

/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 */
-(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value{
    [self dictionarySetValue:dic key:key value:value withDefault:@""];
}

/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 * defaultValue 默认值，当value为nil时使用该值代替
 */
-(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value withDefault:(id) defaultVaule{
    if(!key){
        return ;
    }
    if(!value){
        if(!defaultVaule){
            defaultVaule=@"";
        }
        value=defaultVaule;
    }
    [dic setObject:value forKey:key];
}

-(long) countTable{
    NSString *sql=[NSString stringWithFormat:@"select count(*) from %@",_tbname];
    FMResultSet *rs=nil;
    //@synchronized(_db){
    [_lock lock];
    //NSLog(@"锁定数据库查询操作***** table name:%@",_tbname);
    NSInteger count=0;
    @try {
        rs=[_db executeQuery:sql];
        if ([_db hadError]) {
            NSLog(@"SQL Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        }else{
            if([rs next]){
                count=[rs longForColumnIndex:0];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"executeQuery exception:%@",exception);
    }
    @finally {
        [rs close];
        [_lock unlock];
        //NSLog(@"释放数据库查询操作锁***** table name:%@",_tbname);
    }
    //}
    return count;
}

/**
 * 清理数据
 **/
-(BOOL) clearData{
    return [self delete:nil selectionArgs:nil];
}

- (void)dealloc
{
    ALDRelease(_tbname);
    [_db close];
    ALDRelease(_db);
    self.lock=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end
