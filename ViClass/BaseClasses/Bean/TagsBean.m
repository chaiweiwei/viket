//
//  TagsBean.m
//  Zenithzone
//  标签Bean
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "TagsBean.h"

@implementation TagsBean

-(void)dealloc
{
    self.sid=nil;
    self.name=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
