//
//  NSNullAdditions.h
//  NetBusiness
//
//  Created by yulong chen on 12-7-6.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull(Additions)

-(NSInteger) length;

-(BOOL) isEqualToString:(id) obj;

-(int) intValue;
@end
