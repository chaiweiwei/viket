//
//  NSNullAdditions.m
//  NetBusiness
//
//  Created by yulong chen on 12-7-6.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import "NSNullAdditions.h"

@implementation NSNull(Additions)

-(BOOL) isEqualToString:(id) obj{
    if ([obj isKindOfClass:[NSNull class]]) {
        return YES;
    }else if ([obj isKindOfClass:[NSString class]]) {
        NSString *str=obj;
        if ([str isEqualToString:@""]) {
            return YES;
        }
    }
    return NO;
}

-(NSInteger) length{
    return 0;
}

-(int) intValue{
    return 0;
}
@end
