//
//  MyURLCache.h
//  hyt
//
//  Created by aaa a on 12-3-12.
//  Copyright (c) 2012年 alidao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyURLCache : NSURLCache{
    NSMutableDictionary *cachedResponses;
    NSMutableDictionary *responsesInfo;
    
    BOOL isReload;
}
/** 获取缓存图片路径 **/
@property(retain,nonatomic) NSString* cachePath;

@property (nonatomic, retain) NSMutableDictionary *cachedResponses;
@property (nonatomic, retain) NSMutableDictionary *responsesInfo;
@property (nonatomic, readwrite) BOOL isReload;

- (void)saveInfo;


@end
