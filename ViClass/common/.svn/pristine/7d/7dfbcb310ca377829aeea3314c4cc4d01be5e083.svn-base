//
//  ALDAsyncLoadImage.m
//  npf
//  图片异步加载工具
//  Created by yulong chen on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDAsyncLoadImage.h"
#import <CommonCrypto/CommonDigest.h>
#import "NetworkTest.h"
#import "ALDUtils.h"

#define kMaxFailUrl 10

@implementation ALDAsyncLoadImage
@synthesize cachePath=_cachePath;
@synthesize cacheSize=_cacheSize;

-(NSString *) makeCachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"ImagesCache"];
}

- (id)init
{
    self = [super init];
    if (self) {
        _fileManager = [[NSFileManager alloc] init];
        _delegates=[[NSMutableArray alloc] init];
        _requests=[[NSMutableArray alloc] init];
        _requestForURL=[[NSMutableDictionary alloc] init];
        _failedURLs=[[NSMutableArray alloc] init];
        
        self.cachePath=[self makeCachePath];
        BOOL isDirectory;
        NSString *path=[NSString stringWithFormat:@"%@/",_cachePath];
        if (![_fileManager fileExistsAtPath:_cachePath isDirectory:&isDirectory]) {
            NSError *error=nil;
            BOOL res=[_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (!res) {
                if (error) {
                    NSLog(@"创建目录失败,error:%@, path:%@",error,path);
                }else {
                    NSLog(@"创建目录失败");
                }
            }
        }else if (!isDirectory) {
            NSError *error=nil;
            [_fileManager removeItemAtPath:_cachePath error:&error];
            if (error) {
                NSLog(@"删除文件%@失败",_cachePath);
            }
            BOOL res=[_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (!res) {
                if (error) {
                    NSLog(@"创建目录失败,error:%@, path:%@",error,path);
                }else {
                    NSLog(@"创建目录失败");
                }
            }
        }else {
            //NSLog(@"目录已存在,isDirectory:%d",isDirectory);
        }
        
        cachedResponses = [[NSMutableDictionary alloc] init];
        _cacheSize=20;
        networkQueue = [[ASINetworkQueue alloc] init];
        [networkQueue reset];
        //[networkQueue setDownloadProgressDelegate:progressIndicator];
        //[networkQueue setRequestDidStartSelector:@selector(requestStarted:)];
        //[networkQueue setRequestDidReceiveResponseHeadersSelector:@selector(request:didReceiveResponseHeaders:)];
        [networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [networkQueue setShouldCancelAllRequestsOnFailure:NO ]; //设置为NO当取消了一个请求，不至于取消所有的请求
        [networkQueue setMaxConcurrentOperationCount:5]; //最大同时执行任务数
        //[networkQueue setShowAccurateProgress:[accurateProgress isOn]]; //设置精确控制进度
        [networkQueue setDelegate:self];
        [networkQueue go];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMemoryWarning)
                                                     name: kDidReceiveMemoryWarningNotification
                                                   object: nil];
    }
    //    NSLog(@"init ALDAsyncLoadImage****");
    return self;
}

static ALDAsyncLoadImage *imageLoad;

+(id) asyncLoadImage{
    if (!imageLoad) {
        imageLoad=[[self alloc] init];
    }
    return imageLoad;
}

+(void) releaseImageLoad{
    ALDRelease(imageLoad);
    imageLoad=nil;
}

static inline char hexChar(unsigned char c) {
    return c < 10 ? '0' + c : 'a' + c - 10;
}

static inline void hexString(unsigned char *from, char *to, NSUInteger length) {
    for (NSUInteger i = 0; i < length; ++i) {
        unsigned char c = from[i];
        unsigned char cHigh = c >> 4;
        unsigned char cLow = c & 0xf;
        to[2 * i] = hexChar(cHigh);
        to[2 * i + 1] = hexChar(cLow);
    }
    to[2 * length] = '\0';
}

/*
 static NSString * md5(const char *string) {
 static const NSUInteger LENGTH = 16;
 unsigned char result[LENGTH];
 CC_MD5(string, (CC_LONG)strlen(string), result);
 
 char hexResult[2 * LENGTH + 1];
 hexString(result, hexResult, LENGTH);
 
 return [NSString stringWithUTF8String:hexResult];
 } */

static NSString * strToHex(const char *string) {
    static const NSUInteger LENGTH = 20;
    unsigned char result[LENGTH];
    CC_SHA1(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}

/**
 * 将url转换成本地路径
 */
+(NSString *) convertUrlToPath:(NSString *)url{
    NSString *filename = strToHex([url UTF8String]);
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
}

- (void)cancelForDelegate:(id<AsyncLoadImageDelegate>)delegate
{
    if (!delegate) {
        return ;
    }
    NSUInteger idx = [_delegates indexOfObjectIdenticalTo:delegate];
    
    if (idx == NSNotFound)
    {
        return;
    }
    ASIHTTPRequest *request = ALDReturnRetained([_requests objectAtIndex:idx]);
    
    [_delegates removeObjectAtIndex:idx];
    [_requests removeObjectAtIndex:idx];
    
    if (![_requests containsObject:request]) //如果没有该url的请求，则取消该请求
    {
        // No more delegate are waiting for this download, cancel it
        NSString *url=request.url.absoluteString;
        [request cancel];
        [_requestForURL removeObjectForKey:url];
    }
    
    ALDRelease(request);
}

/**
 *  从网络加载
 **/
-(void) loadFromNet:(NSString*)path imageUrl:(NSString*) imageUrl fileName:(NSString*)fileName delegate:(id<AsyncLoadImageDelegate>) delegate{
    // Share the same request for identical URLs so we don't download the same URL several times
    NSURL *url=[NSURL URLWithString:imageUrl];
    if (!url) {
        NSError *error=nil;
        NSString *urlStr=imageUrl==nil?@"":imageUrl;
        error=[NSError errorWithDomain:@"UIImage preload failed!" code:ASIMimeTypeError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The image url is a bad address.",NSLocalizedDescriptionKey,urlStr,NSURLErrorKey,nil]];
        if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
            [delegate imageLoadedFail:error];
        }
        return;
    }
    ASIHTTPRequest *request = [_requestForURL objectForKey:imageUrl];
    if (!request)
    {
        request = [ASIHTTPRequest requestWithURL:url];
        [request setDownloadDestinationPath:path];
        [request setShouldAttemptPersistentConnection:NO]; //设置是否重用链接
        [request setTimeOutSeconds:10]; //设置超时时间，单位秒
        [request setNumberOfTimesToRetryOnTimeout:0]; //设置请求超时时，设置重试的次数
        //[request setDownloadProgressDelegate:imageProgressIndicator1];
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        [dic setValue:fileName forKey:@"filename"];
        if (delegate) {
            [dic setValue:delegate forKey:@"delegate"];
        }
        [request setUserInfo:dic];
        [networkQueue addOperation:request];
        [_requestForURL setObject:request forKey:imageUrl];
    }
    
    if (delegate) {
        [_delegates addObject:delegate];
    }else{
        [_delegates addObject:[NSNull null]];
    }
    [_requests addObject:request];
}

/**
 * 加载远程图片，优先使用缓存
 * @param imageUrl 图片url
 * @param imageView 要显示图片的view
 * @return 如果本地存在缓存，则直接返回
 */
-(UIImage *) loadImageWithUrl:(NSString *) imageUrl delegate:(id<AsyncLoadImageDelegate>) delegate{
    [self cancelForDelegate:delegate]; //取消先前的委托
    if (!imageUrl || [_failedURLs containsObject:imageUrl])
    {
        NSError *error=nil;
        if (!imageUrl) {
            imageUrl=@"null";
        }
        error=[NSError errorWithDomain:@"UIImage preload failed!" code:ASIMimeTypeError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The image url is a bad address.",NSLocalizedDescriptionKey,imageUrl,NSURLErrorKey,nil]];
        if ([delegate respondsToSelector:@selector(imageLoadedFail:withImageUrl:)]) {
            [delegate imageLoadedFail:error withImageUrl:imageUrl];
        }else if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
            [delegate imageLoadedFail:error];
        }
        return nil;
    }
    imageUrl=[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *filename = strToHex([imageUrl UTF8String]);
    //设置缓存存放路径
    NSString *path = [_cachePath stringByAppendingPathComponent:filename];
    //NSLog(@"image path:%@",path);
    if (cachedResponses.count>=_cacheSize) {
        [cachedResponses removeAllObjects];
    }
    UIImage *image=[cachedResponses objectForKey:path];
    if (image) {
        //NSLog(@"load image from cachedResponses");
        return image;
    }if ([_fileManager fileExistsAtPath:path]){
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image=[UIImage imageWithData:data];
        if (image) {
            //NSLog(@"load image from cached file");
            [cachedResponses setValue:image forKey:path];
            return image;
        }else if([NetworkTest connectedToNetwork]){
            //NSLog(@"load image from net");
            [_fileManager removeItemAtPath:path error:nil];
            
            [self loadFromNet:path imageUrl:imageUrl fileName:filename delegate:delegate];
        }else{
            if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
                NSError *error=nil;
                error=[NSError errorWithDomain:@"NetDidNotConnected" code:ASIConnectionFailureErrorType userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to get net connect",NSLocalizedDescriptionKey,imageUrl,NSURLErrorKey,nil]];
                [delegate imageLoadedFail:error];
            }
        }
    }else if([NetworkTest connectedToNetwork]){
        //NSLog(@"load image from net");
        [self loadFromNet:path imageUrl:imageUrl fileName:filename delegate:delegate];
    }else {
        if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
            NSError *error=nil;
            error=[NSError errorWithDomain:@"NetDidNotConnected" code:ASIConnectionFailureErrorType userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Failed to get net connect",NSLocalizedDescriptionKey,imageUrl,NSURLErrorKey,nil]];
            [delegate imageLoadedFail:error];
        }
    }
    return nil;
}

/**
 * 删除缓存图片
 * @param imageUrl 图片url
 **/
-(void) deleteCacheImageWithUrl:(NSString*) imageUrl{
    if (!imageUrl || [imageUrl isEqualToString:@""]) {
        return;
    }
    NSString *filename = strToHex([imageUrl UTF8String]);
    //设置缓存存放路径
    NSString *path = [_cachePath stringByAppendingPathComponent:filename];
    [cachedResponses removeObjectForKey:path];
    NSError *error=nil;
    if([_fileManager fileExistsAtPath:path]){
        [_fileManager removeItemAtPath:path error:&error];
    }
    if(error){
        NSLog(@"error = %@",error);
    }
}

//- (void)requestStarted:(ASIHTTPRequest *)request{
//
//}

//- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
//    NSString *mimeType=[responseHeaders objectForKey:@"Content-Type"];
//    if (![mimeType hasPrefix:@"image/"]) {
//        NSDictionary *userInfo = request.userInfo;
//        id tmp=[userInfo objectForKey:@"delegate"];
//        if (tmp) {
//            id<AsyncLoadImageDelegate> delegate=(id<AsyncLoadImageDelegate>)tmp;
//            if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
//                NSError *error=nil;
//                error=[NSError errorWithDomain:@"ResponseMimeTypeIsNotImage" code:ASIMimeTypeError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response Mime is not an image.",NSLocalizedDescriptionKey,error,NSUnderlyingErrorKey,nil]];
//                [delegate imageLoadedFail:error];
//            }
//        }
//        [request clearDelegatesAndCancel];
//    }
//}

- (void)requestFinished:(ASIHTTPRequest *)request{
    ALDRetain(request);
    NSString *imageUrl=request.url.absoluteString;
    // Notify all the delegates with this downloader
    UIImage *image = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
    NSError *error=nil;
    if (!image) {
        if (!imageUrl) {
            imageUrl=@"null";
        }
        error=[NSError errorWithDomain:@"UIImage can't create" code:ASIMimeTypeError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The response Mime is not an image.",NSLocalizedDescriptionKey,imageUrl,NSURLErrorKey,nil]];
        // The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
        //        [_failedURLs addObject:request.url.absoluteString];
        //        if (_failedURLs.count>kMaxFailUrl) {
        //            [_failedURLs removeObjectAtIndex:0];
        //        }
    }else {
        NSDictionary *userInfo = request.userInfo;
        id tmp=[userInfo objectForKey:@"delegate"];
        NSString *fileName=nil;
        if (tmp) {
            fileName=[userInfo objectForKey:@"filename"];
        }else {
            fileName=strToHex([imageUrl UTF8String]);
        }
        // Store the image in the cache
        [cachedResponses setValue:image forKey: fileName];
    }
    for (NSInteger idx = [_requests count] - 1; idx >= 0; idx--)
    {
        ASIHTTPRequest *arequest = [_requests objectAtIndex:idx];
        if (arequest == request)
        {
            id<AsyncLoadImageDelegate> delegate = [_delegates objectAtIndex:idx];
            if (image) {
                if ([delegate respondsToSelector:@selector(imageLoadedFinish:withImageUrl:)]) {
                    [delegate imageLoadedFinish:image withImageUrl:imageUrl];
                }else if ([delegate respondsToSelector:@selector(imageLoadedFinish:)]) {
                    [delegate imageLoadedFinish:image];
                }
            }else {
                if ([delegate respondsToSelector:@selector(imageLoadedFail:withImageUrl:)]) {
                    [delegate imageLoadedFail:error withImageUrl:imageUrl];
                }else if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
                    [delegate imageLoadedFail:error];
                }
            }
            [_requests removeObjectAtIndex:idx];
            [_delegates removeObjectAtIndex:idx];
        }
    }
    
    // Release the request
    [_requestForURL removeObjectForKey:request.url.absoluteString];
    ALDRelease(request);
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    ALDRetain(request);
    NSString *path=[request downloadDestinationPath];
    if ([_fileManager fileExistsAtPath:path]){
        [_fileManager removeItemAtPath:path error:nil];
    }
    NSString *imageUrl=request.url.absoluteString;
    NSError *error=request.error;
    for (NSInteger idx = [_requests count] - 1; idx >= 0; idx--)
    {
        ASIHTTPRequest *arequests = [_requests objectAtIndex:idx];
        if (arequests == request)
        {
            id<AsyncLoadImageDelegate> delegate = [_delegates objectAtIndex:idx];
            if ([delegate respondsToSelector:@selector(imageLoadedFail:withImageUrl:)]) {
                [delegate imageLoadedFail:error withImageUrl:imageUrl];
            }else if ([delegate respondsToSelector:@selector(imageLoadedFail:)]) {
                [delegate imageLoadedFail:error];
            }
            
            [_requests removeObjectAtIndex:idx];
            [_delegates removeObjectAtIndex:idx];
        }
    }
    // The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
    //NSLocalizedDescription=The request timed out
    if (error) {
        NSLog(@"Image request error:%@",error);
    }
    
    
    // Release the request
    [_requestForURL removeObjectForKey:imageUrl];
    ALDRelease(request);
}

-(void) clearCache{
    [cachedResponses removeAllObjects];
}

-(void) receiveMemoryWarning{
    [self clearCache];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ALDRelease(_requestForURL);
    ALDRelease(_failedURLs);
    ALDRelease(_requests);
    ALDRelease(_delegates);
    ALDRelease(_cachePath);
    ALDRelease(_fileManager);
    ALDRelease(cachedResponses);
    [networkQueue reset];
	ALDRelease(networkQueue);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end
