//
//  FileDao.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/5.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "FileDao.h"

@implementation FileDao

//TB_USERS
- (id)init
{
    NSString *tbname=@"TB_FILECUNS";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_USERS";
    }
    return self;
}
//创建表，覆盖父类方法
-(BOOL)createTable{
    //[uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (sid Varchar(20),uid Varchar(20),name Varchar(60),logo Varchar(32),categoryName Varchar(60),createTime Varchar(30),count Integer,Constraint pk_mytable Primary Key(sid,uid))",_tbname];
    BOOL success = [self.db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"SQL Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    return success;
}


/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) addFileData:(ClassRoomBean *) bean
{
    NSString *sid=bean.sid;
    if(!bean || !sid){
        return NO;
    }
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"sid" value:sid];
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    [self dictionarySetValue:dic key:@"uid" value:uid];
    
    NSString *name=bean.name;
    if (name && ![name isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"name" value:name];
    }
    NSString *logo=bean.logo;
    if (logo && ![logo isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"logo" value:logo];
    }
    NSString *categoryName=bean.categoryName;
    if (categoryName && ![categoryName isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"categoryName" value:categoryName];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    [self dictionarySetValue:dic key:@"createTime" value:dateTime];
    
    [self dictionarySetValue:dic key:@"count" value:0];
    
    NSArray *params=[NSArray arrayWithObjects:sid,uid,nil];
    NSString *where=@"sid=? and uid=?";
    FMResultSet *rs=[self query:@"sid,uid" whereCaluse:where selectionArgs:params];
    BOOL success;
    if([rs next]){ //已经存在,则做更新
        [rs close];
        success = [self update:dic whereClase:where selectionArgs:params];
    }else{
        [rs close];
        success = [super insert:dic];
    }
    
    return success;

}

/**
 *  新增缓存用户,存在则更新
 *
 *  @param cb 课程数据
 *  @param tb 课程章节数据
 *
 *  @return 成功返回true,失败返回false
 */
-(BOOL) updateFileData:(ClassRoomBean *) bean
{
    return [self addFileData:bean];
}

/**
 * 删除课程所有缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteFileData:(NSString*) sid
{
    if(!sid || [sid isEqualToString:@""]){
        return NO;
    }
    BOOL success=NO;
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:sid,uid, nil];
    
    success = [self delete:@"sid=? and uid=?" selectionArgs:params];
    if(success)
    {
        ChapterDao *chapterDao = [[ChapterDao alloc] init];
        [chapterDao deleteChapterData:sid];
    }
    return success;
}
/**
 * 删除课程所有缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteFileData
{
    BOOL success=NO;
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    
    success = [self delete:@"uid=?" selectionArgs:params];
    if(success)
    {
        ChapterDao *chapterDao = [[ChapterDao alloc] init];
        [chapterDao deleteChapterData];
    }
    return success;
}
/**
 *  查询课程缓存
 *
 *  @param uid 用户ID
 *  @param sid 课程ID
 *
 *  @return 成功返回true,失败返回false
 */
-(NSArray *) queryFileData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    ClassRoomBean *bean=nil;
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    NSMutableArray *result=[NSMutableArray array];
    FMResultSet *rs=[self query:@"*" whereCaluse:@"uid=?" selectionArgs:params];

    while([rs next]){ //create table IF NOT EXISTS %@ (sid Varchar(20) PRIMARY KEY,uid Varchar(20)，name Varchar(60),logo Varchar(32),categoryName Varchar(60),createTime Varchar(30),count Integer)
        bean=[[ClassRoomBean alloc] init];
        bean.sid=[rs stringForColumn:@"sid"];
        bean.name=[rs stringForColumn:@"name"];
        bean.logo=[rs stringForColumn:@"logo"];
        bean.categoryName=[rs stringForColumn:@"categoryName"];
        bean.createTime=[rs stringForColumn:@"createTime"];
        bean.count=[rs intForColumn:@"count"];
        
        [result addObject:bean];
       
    }
    [rs close];
    
    return result;

}
@end
