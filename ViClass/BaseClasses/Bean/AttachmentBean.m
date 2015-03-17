//
//  AttachmentBean.m
//  TZAPP
//  附件数据Bean
//  Created by chen yulong on 14-8-28.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "AttachmentBean.h"
#import "MediaBean.h"

@implementation AttachmentBean
- (void)dealloc
{
    self.sid=nil;
    self.type=nil;
    self.url=nil;
    self.thumbnail=nil;
    self.times=nil;
    self.size=nil;
    self.width=nil;
    self.height=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void) setType:(id)type{
    if (_type) {
        _type=nil;
    }
    if (!type) {
        return;
    }
    if ([type isKindOfClass:[NSNumber class]]) {
        _type=type;
    }else if ([type isKindOfClass:[NSString class]]){
        NSString *temp=type;
        if ([temp isEqualToString:kFileTypeOfImage]) {
            _type=[NSNumber numberWithInt:1];
        }else if ([temp isEqualToString:kFileTypeOfAudio]){
            _type=[NSNumber numberWithInt:2];
        }else if ([temp isEqualToString:kFileTypeOfVideo]){
            _type=[NSNumber numberWithInt:3];
        }else{
            _type=[NSNumber numberWithInt:4];
        }
    }
}

-(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value{
    if(!key){
        return ;
    }
    if(!value){
        return;
    }
    [dic setObject:value forKey:key];
}

-(NSDictionary*) toDictionary{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [self dictionarySetValue:dic key:@"type" value:self.type];
    [self dictionarySetValue:dic key:@"url" value:self.url];
    [self dictionarySetValue:dic key:@"thumbnail" value:self.thumbnail];
    [self dictionarySetValue:dic key:@"times" value:self.times];
    [self dictionarySetValue:dic key:@"size" value:self.size];
    [self dictionarySetValue:dic key:@"width" value:self.width];
    [self dictionarySetValue:dic key:@"height" value:self.height];
    return dic;
}

@end
