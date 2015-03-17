//
//  TypesBean.m
//  TZAPP
//
//  分类标签Bean
//
//  Created by chen yulong on 14-8-28.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "TypesBean.h"

@implementation TypesBean

- (void)dealloc
{
    self.sid=nil;
    self.name=nil;
    self.badgeCount=nil;
    self.defaultDisplay=nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end
