//
//  NCDao.m
//  Zenithzone2
//  消息中心Dao
//  Created by alidao on 14/11/27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "NCDao.h"

@implementation NCDao

- (id)init
{
    NSString *tbname=@"TB_NCs";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_SERVICES";
    }
    return self;
}

//创建表，覆盖父类方法
-(BOOL)createTable{
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (msgId Varchar(20) PRIMARY KEY,sid Varchar(20),uid INTEGER Not Null,t INTEGER Default 0,title Text,msg Text,createTime Varchar(20))",_tbname];
    BOOL success = [self.db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"SQL Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    return success;
}


/**
 * 新增通知,存在则更新
 * @param ncBean 通知bean
 * @return 成功返回true,失败返回false
 */
-(BOOL) addNC:(NCBean *) ncBean
{
    if(!ncBean){
        return NO;
    }
    if(!ncBean.sourceId || [ncBean.sourceId isEqualToString:@""]){
        ncBean.sourceId=@"0";
    }
    NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
    //[sid,confid,title,html,num]
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"msgId" value:ncBean.msgId];
    [self dictionarySetValue:dic key:@"sid" value:ncBean.sourceId];
    [self dictionarySetValue:dic key:@"uid" value:uid];
    [self dictionarySetValue:dic key:@"t" value:ncBean.type];
    [self dictionarySetValue:dic key:@"title" value:ncBean.title];
    [self dictionarySetValue:dic key:@"msg" value:ncBean.descContent];
    [self dictionarySetValue:dic key:@"createTime" value:ncBean.createTime];
    
    NSArray *params=[NSArray arrayWithObject:ncBean.msgId];
    NSString *where=@"msgId=?";
    FMResultSet *rs=[self query:@"msgId,uid,t" whereCaluse:where selectionArgs:params];
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
 * 更新通知,不存在则新增
 * @param ncBean 通知bean
 * @return 成功返回true,失败返回false
 */
-(BOOL) updateNC:(NCBean *) ncBean
{
     return [self addNC:ncBean];
}

/**
 * 根据用户id查询通知
 * @param uid 用户id
 * @param t 通知类型 0.通知 1.@我 3.评论 4.赞
 * @return 返回NCBean数组
 */
-(NSArray *)queryAllNCs:(NSString *)uid t:(NSNumber *)t
{
    if(!uid || [uid isEqualToString:@""] || [t intValue]<0 || [t intValue]>4){
        return [NSArray array];
    }
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:uid];
    [params addObject:t];
    NSString *where=@"uid=? and t=? order by createTime desc";
    NSMutableArray *result=[NSMutableArray array];
    FMResultSet *rs=[self query:@"*" whereCaluse:where selectionArgs:params];
    while([rs next])
    {
        NCBean *bean=[[NCBean alloc] init];
        bean.msgId=[rs stringForColumn:@"msgId"];
        bean.sourceId=[rs stringForColumn:@"sid"];
        bean.type=[NSNumber numberWithInt:[rs intForColumn:@"t"]];
        bean.title=[rs stringForColumn:@"title"];
        bean.descContent=[rs stringForColumn:@"msg"];
        bean.createTime=[rs stringForColumn:@"createTime"];
        
        [result addObject:bean];
    }
    [rs close];
    return result;

}

@end
