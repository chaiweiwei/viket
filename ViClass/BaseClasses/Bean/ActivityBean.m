//
//  ActivityBean.m
//  Zenithzone
//  活动Bean
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "ActivityBean.h"
#import "JSONUtils.h"

@implementation ActivityBean
/*
-(void) setHost:(HostBean *)host{
    if(_host){
        _host=nil;
    }
    
    if([host isKindOfClass:[NSDictionary class]]){
        _host=(HostBean *)[JSONUtils jsonToBeanWithObject:(NSDictionary *)host toBeanClass:@"HostBean"];
    }else if([host isKindOfClass:[HostBean class]]){
        _host=host;
    }
}

-(void)setTags:(NSArray *)tags
{
    if(_tags){
        _tags=nil;
    }
    
    if([tags isKindOfClass:[NSArray class]]){
        if(tags.count>0){
            id temp=[tags objectAtIndex:0];
            if([temp isKindOfClass:[NSDictionary class]]){
                _tags=[JSONUtils jsonToArrayWithArray:tags withItemClass:@"TagsBean"];
            }else{
                _tags=tags;
            }
            
        }else{
            _tags=tags;
        }
    }
}*/

-(void)dealloc
{
    self.sid=nil;
    self.name=nil;
    self.logo=nil;
    self.startTime=nil;
    self.endTime=nil;
    self.address=nil;
    self.applyStatus=nil;
    self.top=nil;
    self.applyLimit=nil;
    self.applyEndTime=nil;
    self.host=nil;
    self.tags=nil;
    self.detailsUrl=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
