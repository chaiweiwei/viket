//
//  ALDAsyncLoadImage.h
//  npf
//
//  Created by yulong chen on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#define ASIMimeTypeError 12

@protocol AsyncLoadImageDelegate <NSObject>
@optional
/**
 * 执行返回调用接口
 * @param error 错误信息
 */
-(void) imageLoadedFail:(NSError *) error;

/**
 * 执行返回调用接口
 * @param error 错误信息
 * @param imageUrl 请求的图片Url
 */
-(void) imageLoadedFail:(NSError *) error withImageUrl:(NSString*)imageUrl;

/**
 * 执行返回调用接口
 * @param image 请求返回的image对象
 */
-(void) imageLoadedFinish:(UIImage *) image;

/**
 * 执行返回调用接口
 * @param image 请求返回的image对象
 * @param imageUrl 请求的图片Url
 */
-(void) imageLoadedFinish:(UIImage *) image withImageUrl:(NSString*)imageUrl;
@end

@interface ALDAsyncLoadImage : NSObject{
    ASINetworkQueue *networkQueue;
    NSFileManager *_fileManager;
    NSMutableDictionary *cachedResponses;
    
    @private
        NSMutableArray *_delegates;
        NSMutableArray *_requests;
        NSMutableDictionary *_requestForURL;
        NSMutableArray *_failedURLs;
}

+(id) asyncLoadImage; //单例

+(void) releaseImageLoad; //销毁单例

-(void) clearCache;

/** 获取缓存图片路径 **/
@property(retain,nonatomic) NSString* cachePath;
//缓存图片大小
@property(nonatomic) int cacheSize;

/**
 * 取消任务执行
 * @param delegate 异步加载委托实现
 **/
- (void)cancelForDelegate:(id<AsyncLoadImageDelegate>)delegate;

/**
 * 加载远程图片，优先使用缓存
 * @param imageUrl 图片url
 * @param delegate 异步加载委托实现
 * @return 如果本地存在缓存，则直接返回
 */
-(UIImage *) loadImageWithUrl:(NSString *) imageUrl delegate:(id<AsyncLoadImageDelegate>) delegate;

/**
 * 删除缓存图片
 * @param imageUrl 图片url
 **/
-(void) deleteCacheImageWithUrl:(NSString*) imageUrl;

/**
 * 将url转换成本地路径
 */
+(NSString *) convertUrlToPath:(NSString *)url;
@end
