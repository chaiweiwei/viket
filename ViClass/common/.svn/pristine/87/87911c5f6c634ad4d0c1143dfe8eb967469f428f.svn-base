//
//  MyURLCache.m
//  hyt
//
//  Created by aaa a on 12-3-12.
//  Copyright (c) 2012年 alidao. All rights reserved.
//

#import "MyURLCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "NetworkTest.h"

static NSString *cacheDirectory;
static NSSet *supportSchemes;


@implementation MyURLCache

#define kHtmlEncodingName @"utf-8"

@synthesize cachedResponses, responsesInfo;
@synthesize isReload;
@synthesize cachePath=_cachePath;

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

/*static NSString * md5(const char *string) {
    static const NSUInteger LENGTH = 16;
    unsigned char result[LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}*/

static NSString * strToHex(const char *string) {
    static const NSUInteger LENGTH = 20;
    unsigned char result[LENGTH];
    CC_SHA1(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}

-(NSString *) makeCachePath{
    if (_cachePath && ![_cachePath isEqualToString:@""]) {
        return _cachePath;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    self.cachePath = [documentDirectory stringByAppendingPathComponent:@"ImagesCache"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    NSString *path=[NSString stringWithFormat:@"%@/",_cachePath];
    if (![fileManager fileExistsAtPath:_cachePath isDirectory:&isDirectory]) {
        NSError *error=nil;
        BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!res) {
            if (error) {
                NSLog(@"创建目录失败,error:%@, path:%@",error,path);
            }else {
                NSLog(@"创建目录失败");
            }
        }
    }else if (!isDirectory) {
        NSError *error=nil;
        [fileManager removeItemAtPath:_cachePath error:&error];
        if (error) {
            NSLog(@"删除文件%@失败",_cachePath);
        }
        BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
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
    ALDRelease(fileManager);
    return _cachePath;
}

+ (void)initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (!cacheDirectory) {
        cacheDirectory = ALDReturnRetained([paths objectAtIndex:0]);
    }
    if (!supportSchemes) {
        NSSet *set=[NSSet setWithObjects:@"http", @"https", nil];
        supportSchemes = ALDReturnRetained(set);
    }
}

-(void) receiveMemoryWarning{
    [self removeAllCachedResponses];
}

-(NSString *)getFullUrlByRequest:(NSURLRequest *)request {
    NSString *url = nil;
    if ([request.HTTPMethod compare:@"GET"]== NSOrderedSame) {
        url = [[request URL] absoluteString];
    } else if ([request.HTTPMethod compare:@"POST"]== NSOrderedSame){   
        NSString *bodyStr = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        url = [NSString stringWithFormat:@"%@?%@",[[request URL] absoluteString],bodyStr];
        ALDRelease(bodyStr);
    }
    return url;    
}

- (NSString *)mimeTypeForPath:(NSString *)originalPath
{
	if([originalPath hasSuffix:@"png"]){
        return @"image/png";
    }else if([originalPath hasSuffix:@"jpg"]){
        return @"image/jpg";
    }else if([originalPath hasSuffix:@"gif"]){
        return @"image/gif";
    }
    return @"text/plain";
}

-(BOOL) needCacheWeibo:(NSURLRequest *)request{
    NSString *abUrl=request.URL.absoluteString;
    NSArray *map=[abUrl componentsSeparatedByString:@"?"];
    NSString *relativePath=[map objectAtIndex:0];
    NSString *query=nil;
    if(map.count>1){
        query=[map objectAtIndex:1];
    }
    if(!query){
        return false;
    }
    if([relativePath hasSuffix:@"/webhyt/weibo/viewhuati.htm"]){
        NSArray * params=[query componentsSeparatedByString:@"&"];
        for (NSString *str in params) {
            if(str){
                NSArray *tmp=[str componentsSeparatedByString:@"="];
                NSString *key=[[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if([key isEqualToString:@"pageInfo"]){
                    NSString *value=[[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(!value || [value isEqualToString:@""]){
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

-(NSString *) getParam:(NSString *) abUrl withName:(NSString*)name{
    NSArray *map=[abUrl componentsSeparatedByString:@"?"];
    NSString *query=nil;
    if(map.count>1){
        query=[map objectAtIndex:1];
    }
    if(!query){
        return nil;
    }
    NSArray * params=[query componentsSeparatedByString:@"&"];
    for (NSString *str in params) {
        if(str){
            NSArray *tmp=[str componentsSeparatedByString:@"="];
            NSString *key=[[tmp objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if([key isEqualToString:name]){
                NSString *value=[[tmp objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                return value;
            }
        }
    }

    return nil;
}

-(BOOL) netConnected{
    BOOL connected=false;
	if (![NetworkTest connectedToNetwork]){
        connected=false;
	}else {
		//网络是通的
        connected=true;
    }
    return connected;
}

-(NSString*)replaceWeiboCallback:(NSString*) data withCallback:(NSString*) callback{
    if(!data || !callback) return data;
    NSRange range = [data rangeOfString:@"({"];
    if (range.location != NSNotFound) {
        NSInteger dataLengh = [data length];
        range.length = dataLengh-range.location;
        NSString *result = [data substringWithRange:range];
        result= [callback stringByAppendingString:result];
        return result;
    }
    return data;
}

/**
 * 此方法一定要设置磁盘缓存大小才会被调用
 */
-(void) storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request{
    //NSLog(@"storeCachedResponse***********，request：%@",request);
    NSString *scheme=request.URL.scheme;
    if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        [super storeCachedResponse:cachedResponse forRequest:request];
        return;
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURLResponse *response=cachedResponse.response;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse*)response;
        if (httpResponse.statusCode!=200) {
            ALDRelease(fileManager);
            return [super storeCachedResponse:cachedResponse forRequest:request];
        }
        //NSLog(@"storeCachedResponse code:%d",httpResponse.statusCode);
    }
    NSString *absoluteString=request.URL.absoluteString;
    NSString *filename = strToHex([absoluteString UTF8String]);
    NSString *documentDirectory = [self makeCachePath];
    NSString *path = [documentDirectory stringByAppendingPathComponent:filename];
    if([response isKindOfClass:[NSURLResponse class]]&&[response.MIMEType hasPrefix:@"image/"]){
        NSString *fullURL = [self getFullUrlByRequest:request];
        NSData *data=[cachedResponse data];
        UIImage *image=[UIImage imageWithData:data];
        if (image && [image isKindOfClass:[UIImage class]]) {
            [fileManager createFileAtPath:path contents:data attributes:nil];
        }
        [cachedResponses setObject:cachedResponse forKey:fullURL];
    }else{
        [super storeCachedResponse:cachedResponse forRequest:request];
    }
    ALDRelease(fileManager);
}


- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSURL *url = request.URL;
    NSString *absoluteString = url.absoluteString;
    //NSLog(@"cachedResponseForRequest url:%@",absoluteString);
    
    //if is back or forward ,reload from cache
    NSString *fullURL = [self getFullUrlByRequest:request];
    NSCachedURLResponse *cachedResponse = [cachedResponses objectForKey:fullURL];
    
    if (cachedResponse) {
        return cachedResponse;
    }
    
    NSURLResponse *response = nil;
    NSString *filename = strToHex([absoluteString UTF8String]);
    NSString *documentDirectory = [self makeCachePath];
    NSString *path = [documentDirectory stringByAppendingPathComponent:filename];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]){
        NSData *data = [NSData dataWithContentsOfFile:path];
        //NSLog(@"load image from file!url:%@",absoluteString);
        ALDRelease(fileManager);
        NSURLResponse *newResponse =[[NSURLResponse alloc] initWithURL:url MIMEType:response.MIMEType
                                                  expectedContentLength:[data length] textEncodingName:nil];
        cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse data:data];
        ALDRelease(newResponse);
        [cachedResponses setObject:cachedResponse forKey:fullURL];
        return ALDReturnAutoreleased(cachedResponse);
    }
    ALDRelease(fileManager);
    return [super cachedResponseForRequest:request];
}

- (void)saveInfo {
    if ([responsesInfo count]) {
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        [responsesInfo writeToFile:path atomically: YES];
    }   
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    NSString *fullURL = [self getFullUrlByRequest:request];
    
    [cachedResponses removeObjectForKey:fullURL];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
    NSLog(@"removeAllObjects");
    [cachedResponses removeAllObjects];
    [super removeAllCachedResponses];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ALDRelease(_cachePath);
    ALDRelease(cachedResponses);
    ALDRelease(responsesInfo);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        cachedResponses = [[NSMutableDictionary alloc] init];
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            responsesInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        } else {
            responsesInfo = [[NSMutableDictionary alloc] init];
        }
        ALDRelease(fileManager);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMemoryWarning)
                                                     name: kDidReceiveMemoryWarningNotification
                                                   object: nil];
    }
    return self;
}

@end
