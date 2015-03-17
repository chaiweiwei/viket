//
//  HostBean.m
//  Zenithzone
//  主办方Bean
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "HostBean.h"

@implementation HostBean

-(void)dealloc
{
    self.sid=nil;
    self.name=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
