//
//  AddressDao.m
//  hyt_ios
//  地址Dao
//  表字段：[addrid,province,city,area,detail,lng,lat,postcode]
//  Created by yulong chen on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AddressDao.h"

@implementation AddressDao
- (id)init
{
    NSString *tbname=@"TB_ADDRESS";
    self = [super initWithTbname:tbname];
    if (self) {
        //self.tbname=@"TB_ADDRESS";
    }
    return self;
}

//创建表，覆盖父类方法
-(BOOL)createTable{
    //
    NSString *sql=[NSString stringWithFormat:@"create table IF NOT EXISTS %@ (addrid Varchar(20) PRIMARY KEY,province Varchar(30) Not Null,city VARCHAR(30),area VARCHAR(30),detail VARCHAR(200),lng VARCHAR(30),lat VARCHAR(30),postcode VARCHAR(8))",_tbname];
    BOOL success = [self.db executeUpdate:sql];
    if ([_db hadError]) {
        NSLog(@"SQL Error %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    return success;
}

/**
 * 添加地址，如果存在则更新
 * @param address 地址对象
 * @return 成功返回true,失败返回false
 */
-(BOOL) addAddress:(AddressBean *) address{
    if(!address || !address.sid){
        NSLog(@"invalid address data");
        return NO;
    }
    
    //addrid,province,city,area,detail,lng,lat,postcode
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init ];
    [self dictionarySetValue:dic key:@"addrid" value:address.sid];
    [self dictionarySetValue:dic key:@"province" value:address.province];
    [self dictionarySetValue:dic key:@"city" value:address.city];
    [self dictionarySetValue:dic key:@"area" value:address.area];
    [self dictionarySetValue:dic key:@"detail" value:address.detail];
    [self dictionarySetValue:dic key:@"lng" value:address.lng];
    [self dictionarySetValue:dic key:@"lat" value:address.lat];
    [self dictionarySetValue:dic key:@"postcode" value:address.postcode];
    
    NSArray *params=[[NSArray alloc] initWithObjects:address.sid, nil];
    NSString *where=@"addrid=?";
    FMResultSet *rs=[self query:@"addrid,province" whereCaluse:where selectionArgs:params];
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
 * 更新地址信息，如果不存在则添加
 * @param address 地址对象
 * @return 成功返回true,失败返回false
 */
-(BOOL) updateAddress:(AddressBean *) address{
    return [self addAddress:address];
}

/**
 * 根据地址id，删除会议地址
 * @param addrid 地址id
 * @return 成功返回true,失败返回false
 */
-(BOOL) deleteAddress:(long) addrid{
    NSArray *params=nil;
    if(addrid){
        params=[NSArray arrayWithObjects:[NSNumber numberWithLong:addrid], nil];
    }else {
        return NO;
    }
    BOOL success=[self delete:@"addrid=?" selectionArgs:params];

    return success;
}

/** 
 *  根据地址id，查询地址详情
 *  @param addrId 地址id
 *  @return 返回地址AddressBean对象
 */
-(AddressBean *) queryAddresses:(long) addrId{
    if(!addrId){
        return nil;
    }
    NSArray *params=[NSArray arrayWithObjects:[NSNumber numberWithLong:addrId], nil];
    NSString *where=@"addrid=?";
    AddressBean *address=nil;
    FMResultSet *rs=[self query:@"*" whereCaluse:where selectionArgs:params];
    if([rs next]){//[addrid,province,city,area,detail,lng,lat,postcode]
        address=[[AddressBean alloc] init];
        address.sid=[rs stringForColumn:@"addrid"];
        address.province=[rs stringForColumn:@"province"];
        address.city=[rs stringForColumn:@"city"];
        address.area=[rs stringForColumn:@"area"];
        address.detail=[rs stringForColumn:@"detail"];
        address.lng=[rs stringForColumn:@"lng"];
        address.lat=[rs stringForColumn:@"lat"];
        address.postcode=[rs stringForColumn:@"postcode"];
    }
    [rs close];
    
    return address;
}

/**
 * 清理数据
 **/
-(BOOL) clearData{
    return [self delete:nil selectionArgs:nil];
}

@end
