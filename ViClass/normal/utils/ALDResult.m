//
//  ALDResult.m
//  why
//
//  Created by yulong chen on 12-4-7.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import "ALDResult.h"
#import "ALDUtils.h"

@implementation ALDResult
@synthesize success=_success,code=_code,obj=_obj,lastTime=_lastTime;
@synthesize pageInfo=_pageInfo,hasNext=_hasNext,page=_page;
@synthesize pagesize=_pagesize,totalCount=_totalCount;
@synthesize userInfo=_userInfo;
@synthesize isLoadFromCache=_isLoadFromCache;
@synthesize errorMsg=_errorMsg;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isNeedLogin=NO;
    }
    return self;
}

- (void)dealloc
{
    self.pagetag=nil;
    ALDRelease(_obj);
    ALDRelease(_lastTime);
    ALDRelease(_pageInfo);
    ALDRelease(_userInfo);
    ALDRelease(_errorMsg);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(BOOL) captureHasNext{
    if (_page*_pagesize<_totalCount) {
        return YES;
    }
    return _hasNext;
}

-(NSString *) description{
    return [NSString stringWithFormat:@"[code=%d, lastTime=%@, obj=%@ ,errorMsg=%@]",(int)_code,_lastTime,_obj,_errorMsg];
}
@end
