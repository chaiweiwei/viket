//
//  ChapterDao.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/5.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "ChapterDao.h"
#import "ALDAsyncDownloader.h"

@implementation ChapterDao

//TB_USERS
- (id)init
{
    NSString *tbname=@"TB_CHAPTERCUNS";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_USERS";
    }
    return self;
}
//创建表，覆盖父类方法
-(BOOL)createTable{
    //[uid,userName,pwd,sessionKey,name,nickname,headImage,integral,sex,mobile,birthday,homephone,email,company,department,position,haspayPassword,inviteRegister,addrId]
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (sid Varchar(20),classId Varchar(20),uid Varchar(20),name Varchar(60),logo Varchar(32),url Varchar(60),type Integer,createTime Varchar(30),count Integer,Constraint pk_mytable Primary Key(sid,uid,classId))",_tbname];
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
-(BOOL) addChapterData:(ChapterBean *)bean classId:(NSString *)classId
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
    
    if (classId && ![classId isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"classId" value:classId];
    }
    
    NSString *name=bean.name;
    if (name && ![name isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"name" value:name];
    }
    NSString *logo=bean.logo;
    if (logo && ![logo isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"logo" value:logo];
    }
    
    AttachmentBean *at = bean.attachments[0];
    
    NSString *url = at.url;
    if (url && ![url isEqualToString:@""]) {
        [self dictionarySetValue:dic key:@"url" value:url];
    }
    [self dictionarySetValue:dic key:@"type" value:at.type];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    [self dictionarySetValue:dic key:@"createTime" value:dateTime];
    
    [self dictionarySetValue:dic key:@"count" value:0];
    
    NSArray *params=[NSArray arrayWithObjects:sid,uid,classId,nil];
    NSString *where=@"sid=? and uid=? and classId=?";
    FMResultSet *rs=[self query:@"sid,uid,classId" whereCaluse:where selectionArgs:params];
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
-(BOOL) updateChapterData:(ChapterBean *)bean classId:(NSString *)classId
{
    return [self addChapterData:bean classId:classId];
}
/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteChapterData:(NSString *)classId
{
    if(!classId || [classId isEqualToString:@""]){
        return NO;
    }
    BOOL success=NO;
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:uid,classId, nil];
    
    //删除特定的文件
    NSArray *arrayM = [self queryChapterData:classId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //删除文件和文件夹
    NSString *fileName ;
    for(ChapterBean * bean in arrayM)
    {
        AttachmentBean *at = bean.attachments[0];
        
        ALDAsyncDownloader *aldDownloadHandler=[ALDAsyncDownloader asyncDownloader];
        NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str: at.url]];
        fileName =[aldDownloadHandler getCachedForUrlPath:url];

        [fileManager removeItemAtPath:fileName error:nil];
    }

    success = [self delete:@"uid=? and classId=?" selectionArgs:params];
    
    return success;
}

/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteChapterData:(NSString*) sid classId:(NSString *)classId
{
    if(!sid || [sid isEqualToString:@""]){
        return NO;
    }
    BOOL success=NO;
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:sid,uid,classId, nil];
    
    //删除特定的文件
    ChapterBean *bean = [self queryChapterData:sid classId:classId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //删除文件和文件夹
    NSString *fileName ;
    
    AttachmentBean *at = bean.attachments[0];
    
    ALDAsyncDownloader *aldDownloadHandler=[ALDAsyncDownloader asyncDownloader];
    NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str: at.url]];
    fileName =[aldDownloadHandler getCachedForUrlPath:url];
    
    [fileManager removeItemAtPath:fileName error:nil];
    
    success = [self delete:@"sid=? and uid=? and classId=?" selectionArgs:params];
    return success;
}
/**
 * 删除课程章节缓存
 * @param sid 用户id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteChapterData
{
    BOOL success=NO;
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    
    success = [self delete:@"uid=?" selectionArgs:params];
    if(success)
    {
        //删除文件和文件夹
        NSString *imageDir = [self getPathOfDocuments];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:imageDir error:nil];
    }
    return success;
}
/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(ChapterBean *) queryChapterData:(NSString *)sid classId:(NSString *)classId
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    if (!classId || [classId isEqualToString:@""]) {
        return nil;
    }
    
    ChapterBean *bean=nil;
    AttachmentBean *at = nil;
    
    NSArray *params=[NSArray arrayWithObjects:uid,classId,sid, nil];
    FMResultSet *rs=[self query:@"*" whereCaluse:@"uid=? and classId=? and sid=?" selectionArgs:params];
    
    if([rs next]){ //sid Varchar(20) PRIMARY KEY,classId Varchar(20),uid Varchar(20),name Varchar(60),url Varchar(60),type ,createTime Varchar(30),count Integer
        bean=[[ChapterBean alloc] init];
        at = [[AttachmentBean alloc] init];
        
        bean.sid=[rs stringForColumn:@"sid"];
        bean.name=[rs stringForColumn:@"name"];
        bean.logo=[rs stringForColumn:@"logo"];
        at.url = [rs stringForColumn:@"url"];
        at.type = [NSNumber numberWithInt:[[rs stringForColumn:@"type"] intValue]];
        
        bean.createTime=[rs stringForColumn:@"createTime"];
        bean.count=[rs intForColumn:@"count"];
        bean.attachments = [NSArray arrayWithObjects:at, nil];

    }
    [rs close];
    
    return bean;

}
/**
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(NSArray *) queryChapterData:(NSString *)classId
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    if (!classId || [classId isEqualToString:@""]) {
        return nil;
    }
    
    ChapterBean *bean=nil;
    AttachmentBean *at = nil;
    
    NSArray *params=[NSArray arrayWithObjects:uid,classId, nil];
    NSMutableArray *result=[NSMutableArray array];
    FMResultSet *rs=[self query:@"*" whereCaluse:@"uid=? and classId=?" selectionArgs:params];

    while([rs next]){ //sid Varchar(20) PRIMARY KEY,classId Varchar(20),uid Varchar(20),name Varchar(60),url Varchar(60),type ,createTime Varchar(30),count Integer
        bean=[[ChapterBean alloc] init];
        at = [[AttachmentBean alloc] init];
        
        bean.sid=[rs stringForColumn:@"sid"];
        bean.name=[rs stringForColumn:@"name"];
        bean.logo=[rs stringForColumn:@"logo"];
        at.url = [rs stringForColumn:@"url"];
        at.type = [NSNumber numberWithInt:[[rs stringForColumn:@"type"] intValue]];

        bean.createTime=[rs stringForColumn:@"createTime"];
        bean.count=[rs intForColumn:@"count"];
        bean.attachments = [NSArray arrayWithObjects:at, nil];
        
        [result addObject:bean];
    }
    [rs close];
    
    return result;

}
-(NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    chineseStr = [chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return chineseStr;
}
-(NSString *)getPathOfDocuments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    
    path = [path stringByAppendingPathComponent:@"ImagesCache"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSError *error=nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    return path;
}

@end
