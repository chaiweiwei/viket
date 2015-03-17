//
//  TypeBean.m
//  WhbApp
//  栏目bean
//  Created by chen yulong on 13-9-2.
//  Copyright (c) 2013年 Bibo. All rights reserved.
//

#import "TypeBean.h"

@implementation TypeBean
@synthesize typeId=_typeId,name=_name;
@synthesize seq=_seq;
@synthesize status=_status;

- (void)dealloc
{
    self.typeId=nil;
    self.name=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end
