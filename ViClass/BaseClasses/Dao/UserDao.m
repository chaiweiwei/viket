//
//  UserDao.m
//  ZYClub
//  用户dao [uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
//  Created by chen yulong on 14-3-19.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "UserDao.h"
#import "AddressDao.h"

@implementation UserDao
//TB_USERS
- (id)init
{
    NSString *tbname=@"TB_USERS";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_USERS";
    }
    return self;
}

//创建表，覆盖父类方法
-(BOOL)createTable{
    //[uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (uid Varchar(20) PRIMARY KEY,userName Varchar(60),pwd Varchar(32),sessionKey Varchar(60),name Varchar(30),nickname VARCHAR(60),headImage Varchar(100),integral Integer Default 0,sex Varchar(10),mobile Varchar(20),birthday Varchar(20),homephone Varchar(20),email Varchar(100),company Varchar(200),department Varchar(100),position Varchar(60),haspayPassword Integer,inviteRegister Text,addrId Integer)",_tbname];
    BOOL success = [self.db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"SQL Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    return success;
}


/**
 * 新增用户,存在则更新
 * @param bean 用户数据bean
 * @return 成功返回true,失败返回false
 */
-(BOOL) addUser:(UserBean *) bean {
    NSString *uid=bean.uid;
    if(!bean || !uid){
        return NO;
    }
    //[uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"uid" value:bean.uid];
    NSString *username=bean.username;
    if (username && ![username isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"userName" value:username];
    }
    NSString *pwd=nil;//bean.pwd;
    if (pwd && ![pwd isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"pwd" value:pwd];
    }
    NSString *sessionId=bean.sessionKey;
    if (sessionId && ![sessionId isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"sessionKey" value:sessionId];
    }
    
    [self dictionarySetValue:dic key:@"name" value:bean.username];
    
    [self dictionarySetValue:dic key:@"nickname" value:bean.userInfo.nickname];
    [self dictionarySetValue:dic key:@"headImage" value:bean.userInfo.nickname];
    [self dictionarySetValue:dic key:@"integral" value:bean.userInfo.gender];
    [self dictionarySetValue:dic key:@"sex" value:bean.userInfo.gender];
    [self dictionarySetValue:dic key:@"mobile" value:bean.mobile];
    [self dictionarySetValue:dic key:@"birthday" value:bean.userInfo.birthday];
    [self dictionarySetValue:dic key:@"homephone" value:bean.mobile];
    [self dictionarySetValue:dic key:@"email" value:bean.email];
    [self dictionarySetValue:dic key:@"company" value:bean.userInfo.company];
    [self dictionarySetValue:dic key:@"department" value:bean.userInfo.occupation];
    [self dictionarySetValue:dic key:@"position" value:bean.userInfo.position];
    [self dictionarySetValue:dic key:@"haspayPassword" value:bean.haspayPassword];
    [self dictionarySetValue:dic key:@"inviteRegister" value:bean.inviteRegister];
    
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    NSString *where=@"uid=?";
    FMResultSet *rs=[self query:@"uid,name" whereCaluse:where selectionArgs:params];
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
 * 更新用户数据,不存在则新增
 * @param User 用户数据对象
 * @return 成功返回true,失败返回false
 */
-(BOOL) updateUser:(UserBean *) bean{
    return [self addUser:bean];
}

/**
 * 修改头像
 * @param uid 用户id
 * @param avatar 头像url
 * @return 成功返回true,失败返回false
 **/
-(BOOL) updateHeadWithUid:(NSString*) uid withAvator:(NSString*) avatar{
    if (!uid || [uid isEqualToString:@""]) {
        return NO;
    }
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"headImage" value:avatar];
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    NSString *where=@"uid=?";
    return [self update:dic whereClase:where selectionArgs:params];
}

/**
 * 删除用户
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteUser:(NSString*) uid{
    if(!uid || [uid isEqualToString:@""]){
        return NO;
    }
    BOOL success=NO;
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    success = [self delete:@"uid=?" selectionArgs:params];
    return success;
}

/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(UserBean *) queryUser:(NSString*)uid{
    if (!uid || [uid isEqualToString:@""]) {
        return nil;
    }
    UserBean *bean=nil;
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    FMResultSet *rs=[self query:@"*" whereCaluse:@"uid=?" selectionArgs:params];
    long addrId=0;
    if([rs next]){ //[uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
        bean=[[UserBean alloc] init];
        bean.uid=[rs stringForColumn:@"uid"];
        bean.username=[rs stringForColumn:@"userName"];
//        bean.pwd=[rs stringForColumn:@"pwd"];
        bean.sessionKey=[rs stringForColumn:@"sessionKey"];
        bean.userInfo.noteName=[rs stringForColumn:@"name"];
        bean.userInfo.nickname=[rs stringForColumn:@"nickname"];
        bean.userInfo.avatar=[rs stringForColumn:@"headImage"];
//        bean.integral=[NSNumber numberWithInt:[rs intForColumn:@"integral"]];
        bean.userInfo.gender=[rs stringForColumn:@"sex"];
        bean.mobile=[rs stringForColumn:@"mobile"];
        bean.userInfo.birthday=[rs stringForColumn:@"birthday"];
//        bean.userInfo.=[rs stringForColumn:@"homephone"];
        bean.email=[rs stringForColumn:@"email"];
        bean.userInfo.company=[rs stringForColumn:@"company"];
//        bean.department=[rs stringForColumn:@"department"];
        bean.userInfo.position=[rs stringForColumn:@"position"];
        bean.haspayPassword=[NSNumber numberWithInt:[rs intForColumn:@"haspayPassword"]];
        bean.inviteRegister=[rs stringForColumn:@"inviteRegister"];
        addrId=[rs longForColumn:@"addrId"];
    }
    [rs close];
//    if (addrId>0) {
//        AddressDao *dao=[[AddressDao alloc] init];
//        bean.address=[dao queryAddresses:addrId];
//    }
    return bean;
}

@end
