//
//  TimeDao.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/9.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "TimeDao.h"
#import "TimeBean.h"

@implementation TimeDao
//TB_USERS
- (id)init
{
    NSString *tbname=@"TB_TIME";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_USERS";
    }
    return self;
}
//创建表，覆盖父类方法
-(BOOL)createTable{
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (uid Varchar(20),time Varchar(20),month Integer)",_tbname];
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
-(BOOL) addTimeData:(NSString *)time
{
    if(!time ){
        return NO;
    }
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    [self dictionarySetValue:dic key:@"uid" value:uid];
    
    if (time) {
        [self dictionarySetValue:dic key:@"time" value:time];
    }

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =  NSMonthCalendarUnit;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateTime = [formatter dateFromString:time];
    comps = [calendar components:unitFlags fromDate:dateTime];
    [self dictionarySetValue:dic key:@"month" value:[NSNumber numberWithLong:[comps month]]];

    
    NSArray *params=[NSArray arrayWithObjects:uid,time,nil];
    NSString *where=@"uid=? and time=?";
    FMResultSet *rs=[self query:@"uid,time" whereCaluse:where selectionArgs:params];
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
 *  根据uid查询用户
 *  @param uid 用户id
 *  @return 返回UserBean对象
 */
-(NSArray *) queryTimeData
{
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSArray *params=[NSArray arrayWithObjects:uid, nil];
    NSMutableArray *result=[NSMutableArray array];
    FMResultSet *rs=[self query:@"*" whereCaluse:@"uid=? order by time desc" selectionArgs:params];
    
    while([rs next]){ //sid Varchar(20) PRIMARY KEY,classId Varchar(20),uid Varchar(20),name Varchar(60),url Varchar(60),type ,createTime Varchar(30),count Integer
        TimeBean *bean = [[TimeBean alloc] init];
        bean.time=[rs stringForColumn:@"time"];
        bean.month= [rs longForColumn:@"month"];
        
        [result addObject:bean];
    }
    [rs close];
    
    return result;
    
}

@end
