//
//  BageBean.m
//  Zenithzone2
//  消息中心bageBean
//  Created by alidao on 14/11/27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "BageBean.h"

@implementation BageBean

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSNumber numberWithInt:self.NCBageCount] forKey:@"NCBageCount"];
    [encoder encodeObject:[NSNumber numberWithInt:self.AtBageCount] forKey:@"AtBageCount"];
    [encoder encodeObject:[NSNumber numberWithInt:self.commentBageCount] forKey:@"commentBageCount"];
    [encoder encodeObject:[NSNumber numberWithInt:self.praiseBageCount] forKey:@"praiseBageCount"];
}
- (id)initWithCoder:(NSCoder *)decoder
{
    if(self = [super init])
    {
        self.NCBageCount = [[decoder decodeObjectForKey:@"NCBageCount"] intValue];
        self.AtBageCount = [[decoder decodeObjectForKey:@"AtBageCount"] intValue];
        self.commentBageCount = [[decoder decodeObjectForKey:@"commentBageCount"] intValue];
        self.praiseBageCount = [[decoder decodeObjectForKey:@"praiseBageCount"] intValue];
    }
    return  self;
}

@end
