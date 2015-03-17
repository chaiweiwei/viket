//
//  UserInfoBean.m
//  Basics
//
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "UserInfoBean.h"

@implementation UserInfoBean


/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 */
-(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value{
    if(!key){
        return ;
    }
    if(!value){
        return;
    }
    [dic setObject:value forKey:key];
}

/**
 * 将用户信息对象转换成NSDictionary对象
 * @return
 */
-(NSDictionary*) toDictionary{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"realname" value:self.realname];
    [self dictionarySetValue:dic key:@"nickname" value:self.nickname];
    [self dictionarySetValue:dic key:@"gender" value:self.gender];
    [self dictionarySetValue:dic key:@"pinyin" value:self.pinyin];
    [self dictionarySetValue:dic key:@"birthday" value:self.birthday];
    [self dictionarySetValue:dic key:@"idcard" value:self.idcard];
    [self dictionarySetValue:dic key:@"telephone" value:self.telephone];
    [self dictionarySetValue:dic key:@"zipcode" value:self.zipcode];
    [self dictionarySetValue:dic key:@"revenue" value:self.revenue];
    [self dictionarySetValue:dic key:@"address" value:self.address];
    [self dictionarySetValue:dic key:@"company" value:self.company];
    [self dictionarySetValue:dic key:@"occupation" value:self.occupation];
    [self dictionarySetValue:dic key:@"position" value:self.position];
    [self dictionarySetValue:dic key:@"qq" value:self.qq];
    [self dictionarySetValue:dic key:@"weixin" value:self.weixin];
    [self dictionarySetValue:dic key:@"weibo" value:self.weibo];
    [self dictionarySetValue:dic key:@"alipay" value:self.alipay];
    [self dictionarySetValue:dic key:@"taobao" value:self.taobao];
    [self dictionarySetValue:dic key:@"avatar" value:self.avatar];
    [self dictionarySetValue:dic key:@"intro" value:self.intro];
    [self dictionarySetValue:dic key:@"site" value:self.site];
    [self dictionarySetValue:dic key:@"tag" value:self.tag];
    [self dictionarySetValue:dic key:@"vip" value:self.vip];
    [self dictionarySetValue:dic key:@"bloodtype" value:self.bloodtype];
    [self dictionarySetValue:dic key:@"constellation" value:self.constellation];
    [self dictionarySetValue:dic key:@"mobile" value:self.mobile];
    
    [self dictionarySetValue:dic key:@"zodiac" value:self.zodiac];
    [self dictionarySetValue:dic key:@"grade" value:self.grade];
    [self dictionarySetValue:dic key:@"studentid" value:self.studentid];
    [self dictionarySetValue:dic key:@"nationality" value:self.nationality];
    [self dictionarySetValue:dic key:@"resideprovince" value:self.resideprovince];
    [self dictionarySetValue:dic key:@"graduateschool" value:self.graduateschool];
    [self dictionarySetValue:dic key:@"education" value:self.education];
    [self dictionarySetValue:dic key:@"interest" value:self.interest];
    [self dictionarySetValue:dic key:@"affectivestatus" value:self.affectivestatus];
    [self dictionarySetValue:dic key:@"lookingfor" value:self.lookingfor];
    
    return dic;
}

@end
