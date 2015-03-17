//
//  ChatBean.m
//  Basics
//  对话消息数据bean
//  Created by chen yulong on 14/12/5.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "ChatBean.h"
#import "JSONUtils.h"

@implementation ChatBean

-(void) setAttachments:(NSArray*)attachments{
    if (_attachments) {
        _attachments=nil;
    }
    if ([attachments isKindOfClass:[NSArray class]]) {
        if (attachments.count>0) {
            id temp=[attachments objectAtIndex:0];
            if (![temp isKindOfClass:[NSDictionary class]]) {
                _attachments=attachments;
            }else{
                _attachments=[JSONUtils jsonToArrayWithArray:attachments withItemClass:@"AttachmentsBean"];
            }
        }else{
            _attachments=attachments;
        }
    }
}
@end
