//
//  MessageDao.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/13.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "MessageDao.h"

@implementation MessageDao

//TB_USERS
- (id)init
{
    NSString *tbname=@"TB_MESSAGEPUSH";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_USERS";
    }
    return self;
}
//创建表，覆盖父类方法
-(BOOL)createTable{
    //[uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (sid Varchar(20),uid Varchar(20),title Varchar(20),type Varchar(60),content Varchar(60),createTime Varchar(30),detailUrl Varchar(60),status Integer,Constraint pk_mytable Primary Key(sid))",_tbname];
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
-(BOOL) addMeaasgeData:(NewBean *)bean
{
    NSString *sid=bean.sid;
    if(!bean || !sid){
        return NO;
    }
    //sid Varchar(20) PRIMARY KEY,classId Varchar(20),uid Varchar(20),name Varchar(60),url Varchar(60),createTime Varchar(30),count Integer
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"sid" value:sid];
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    [self dictionarySetValue:dic key:@"uid" value:uid];
    
    NSString *title = bean.title;
    if (title && ![title isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"title" value:title];
    }
    
    NSString *type=bean.type;
    if (type && ![type isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"type" value:type];
    }
    
    NSString *content = bean.content;
    if (content && ![content isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"content" value:content];
    }
    
    NSString *createTime = bean.createTime;
    [self dictionarySetValue:dic key:@"createTime" value:createTime];
    
    NSString *detailUrl = bean.detailUrl;
    [self dictionarySetValue:dic key:@"detailUrl" value:detailUrl];
    
    
    [self dictionarySetValue:dic key:@"status" value:[NSNumber numberWithInt:bean.status]];
    
    NSArray *params=[NSArray arrayWithObjects:sid,nil];
    NSString *where=@"sid=?";
    FMResultSet *rs=[self query:@"sid" whereCaluse:where selectionArgs:params];
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
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteMeaasgeData:(NSString *)sid
{
    if(!sid || [sid isEqualToString:@""]){
        return NO;
    }
    BOOL success=NO;
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:uid,sid, nil];
    
    success = [self delete:@"uid=? and sid=?" selectionArgs:params];
    
    return success;

}

-(NSArray *) queryMeaasgeData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NewBean *bean = nil;
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    NSMutableArray *result=[NSMutableArray array];
    FMResultSet *rs=[self query:@"*" whereCaluse:@"uid=?" selectionArgs:params];
    
    while([rs next]){ //sid Varchar(20) PRIMARY KEY,classId Varchar(20),uid Varchar(20),name Varchar(60),url Varchar(60),type ,createTime Varchar(30),count Integer
        bean=[[NewBean alloc] init];
        
        bean.sid=[rs stringForColumn:@"sid"];
        bean.title=[rs stringForColumn:@"title"];
        bean.type = [rs stringForColumn:@"type"];
        bean.content = [rs stringForColumn:@"content"];
        bean.createTime=[rs stringForColumn:@"createTime"];
        bean.detailUrl=[rs stringForColumn:@"detailUrl"];
        bean.status=[rs intForColumn:@"status"];
        [result addObject:bean];
    }
    [rs close];
    
    return result;

}

@end
