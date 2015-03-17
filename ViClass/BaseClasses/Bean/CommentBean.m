//
//  CommentBean.m
//  Zenithzone
//
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "CommentBean.h"
#import "JSONUtils.h"
#import "AttachmentBean.h"

@implementation CommentBean

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
    }else if (time<3600*24) {
        result=[NSString stringWithFormat:@"%.0f小时前",(time/3600)];
    }else if(time<3600*48) {
        [formatter setDateFormat:@" HH:mm"];
        result=[NSString stringWithFormat:@"昨天%@",[formatter stringFromDate:date]];
    }else if(time<3600*72) {
        [formatter setDateFormat:@" HH:mm"];
        result=[NSString stringWithFormat:@"前天%@",[formatter stringFromDate:date]];
    }else if(time<3600*168) {
        [formatter setDateFormat:@" HH:mm"];
        result=[NSString stringWithFormat:@"%0.f天前%@",(time/3600/24),[formatter stringFromDate:date]];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        result=[formatter stringFromDate:date];
    }
    
    return result;
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
    if (!self.type || [self.type intValue]<1) {
        [self dictionarySetValue:dic key:@"type" value:[NSNumber numberWithInt:1]];
    }else{
        [self dictionarySetValue:dic key:@"type" value:self.type];
    }
    
    [self dictionarySetValue:dic key:@"content" value:self.content];
    [self dictionarySetValue:dic key:@"sourceId" value:self.sourceId];
    
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

@end
