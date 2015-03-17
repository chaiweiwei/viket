//
//  FriendsCircleBean.m
//  WhbApp
//  朋友圈bean
//  Created by Bibo on 13-9-2.
//  Copyright (c) 2013年 Bibo. All rights reserved.
//

#import "FriendsCircleBean.h"
#import "JSONUtils.h"
#import "AttachmentBean.h"

@interface FriendsCircleBean ()
@property (retain,nonatomic) NSArray *images;
@property (retain,nonatomic) NSArray *bigImages;
@end

@implementation FriendsCircleBean

- (void)dealloc
{
    self.sid=nil;
    self.moduleId=nil;
    self.uid=nil;
    self.text=nil;
    self.title=nil;
    self.name=nil;
    self.avatar=nil;
    self.lat=nil;
    self.lng=nil;
    self.address=nil;
    self.commentCount=nil;
    self.praiseCount=nil;
    self.forwardCount=nil;
    self.favoriteCount=nil;
    self.praiseFlag=nil;
    self.favoriteFlag=nil;
    self.attachments=nil;
    self.extra=nil;
    self.createTime=nil;
    self.pagetag=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void) setAttachments:(NSArray *)attachments{
    if (_attachments) {
        _attachments=nil;
    }
    if ([attachments isKindOfClass:[NSArray class]]) {
        if (attachments.count>0) {
            id temp=[attachments objectAtIndex:0];
            if (![temp isKindOfClass:[NSDictionary class]]) {
                _attachments=attachments;
            }else{
                _attachments=[JSONUtils jsonToArrayWithArray:attachments withItemClass:@"AttachmentBean"];
            }
        }else{
            _attachments=attachments;
        }
    }
}

/*
* 得到格式化的时间
**/
-(NSString*) getFormatDate{
    if (!_createTime || [_createTime isEqualToString:@""]) {
        return nil;
    }
    //1小时内显示分钟，8小时以上显示具体时间(日期+时间)
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:_createTime];
    if (!date) {
        return _createTime;
    }
    NSDate *nowDate = [NSDate date];// 获取本地时间
    NSTimeInterval time=[nowDate timeIntervalSince1970]-[date timeIntervalSince1970];
    NSString *result=nil;
    if (time<3600) { //1小时
        if (time<60) {
            result=@"1分钟前";
        }else {
            result=[NSString stringWithFormat:@"%.0f分钟前",(time/60)];
        }
    }else if (time<3600*8) {
        result=[NSString stringWithFormat:@"%.0f小时前",(time/3600)];
    }else {
        [formatter setDateFormat:@"MM-dd HH:mm"];
        result=[formatter stringFromDate:date];
    }
    
    return result;
}

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


-(NSDictionary*) toDictionary {
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"moduleId" value:self.moduleId];
    
    [self dictionarySetValue:dic key:@"text" value:self.text];
    [self dictionarySetValue:dic key:@"visible" value:self.visible];
    [self dictionarySetValue:dic key:@"title" value:self.title];
    [self dictionarySetValue:dic key:@"lat" value:self.lat];
    [self dictionarySetValue:dic key:@"lng" value:self.lng];
    [self dictionarySetValue:dic key:@"address" value:self.address];
    [self dictionarySetValue:dic key:@"tags" value:self.tags];
    
    if (self.attachments && self.attachments.count>0) {
        NSMutableArray *array=[NSMutableArray array];
        for (AttachmentBean *bean in self.attachments) {
            if (!bean.url || [bean.url isEqualToString:@""] || !bean.type || [bean.type integerValue]<1) {
                continue;
            }
            [array addObject:[bean toDictionary]];
        }
        [self dictionarySetValue:dic key:@"attachments" value:array];
    }
    [self dictionarySetValue:dic key:@"extra" value:self.extra];
    
    return dic;
}

+(FriendsCircleBean *)initFriendCircle:(FriendsCircleBean *)bean
{
    FriendsCircleBean *friends=[[FriendsCircleBean alloc] init];
    friends.sid=bean.sid;
    friends.moduleId=bean.moduleId;
    friends.text=bean.text;
    friends.uid=bean.uid;
    friends.avatar=bean.avatar;
    friends.name=bean.name;
    friends.title=bean.title;
    friends.lat=bean.lat;
    friends.lng=bean.lng;
    friends.address=bean.address;
    friends.tags=bean.tags;
    friends.createTime=bean.createTime;
    friends.praiseCount=bean.praiseCount;
    friends.commentCount=bean.commentCount;
    friends.forwardCount=bean.forwardCount;
    friends.favoriteCount=bean.favoriteCount;
    friends.browseCount=bean.browseCount;
    friends.praiseFlag=bean.praiseFlag;
    friends.favoriteFlag=bean.favoriteFlag;
    friends.pagetag=bean.pagetag;
    NSArray *array=bean.attachments;
    if (array) {
        friends.attachments=[NSMutableArray arrayWithArray:array];
    }
    
    friends.extra=bean.extra;
    friends.visible=bean.visible;
    friends.weTitle=bean.weTitle;
    friends.weDescription=bean.weDescription;
    friends.weUrl=bean.weUrl;
    
    return friends;
}


@end
