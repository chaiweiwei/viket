//
//  AddressBean.m
//  FunCat
//  地址数据bean
//  Created by chen yulong on 14-10-11.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "AddressBean.h"

@implementation AddressBean


- (void)dealloc
{
    self.sid=nil;
    self.province=nil;
    self.city=nil;
    self.area=nil;
    self.detail=nil;
    self.lng=nil;
    self.lat=nil;
    self.postcode=nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@%@%@%@",self.province,self.city,self.area,self.detail];
}
@end
