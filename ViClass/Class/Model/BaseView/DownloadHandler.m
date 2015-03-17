#import "DownloadHandler.h"
//#import "ZipArchive.h"
#import "ALDAsyncDownloader.h"

static DownloadHandler *sharedDownloadhandler = nil;

@implementation DownloadHandler
{
    ASIHTTPRequest *_request;
    ASINetworkQueue *_queue;
    NSString *_pathOfTmp;
    ProgressIndicator *_progress;
    UILabel *_label;
    unsigned long long _dataSize;
//    BOOL _downloading;
}

@synthesize url = _url;
@synthesize name = _name;
@synthesize fileType = _fileType;
@synthesize savePath = _savePath;
@synthesize progress = _progress;

+(DownloadHandler *)sharedInstance{
    if (!sharedDownloadhandler) {
        sharedDownloadhandler = [[DownloadHandler alloc] init];
    }
    return sharedDownloadhandler;
}
-(id)init{
    if (self = [super init]) {
        if (!_queue) {
            _queue = [[ASINetworkQueue alloc] init];
            _queue.showAccurateProgress = YES;
            _queue.shouldCancelAllRequestsOnFailure = NO;
            [_queue go];
        }
//        _downloading = NO;
    }
    return self;
}
-(void)start{
    
//    if([self hasCachedForUrl] && [self hasCachedForUrl].length>0)
//    {
//        [ALDUtils showToast:@"已下载，请直接查看"];
//        return;
//    }
    for (ASIHTTPRequest *r in [_queue operations]) {
        NSString *fileName = [r.userInfo objectForKey:@"Name"];
        if ([fileName isEqualToString:_name]) {
            return;//队列中已存在特定request时，退出
        }
    }
//    if (_downloading) {
//        return;
//    }
    NSURL *url = [NSURL URLWithString:_url];
    _request = [ASIHTTPRequest requestWithURL:url];
    _request.delegate = self;
    _request.temporaryFileDownloadPath = [self cachesPath];
    _request.downloadDestinationPath = [self actualSavePath];
    _request.downloadProgressDelegate = _progress;
    _request.allowResumeForFileDownloads = YES;
    _request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_name, @"Name", nil];
    [_queue addOperation:_request];
}
-(NSString *)actualSavePath{
    ALDAsyncDownloader *aldDownloadHandler=[ALDAsyncDownloader asyncDownloader];
    NSURL *url=[NSURL URLWithString:self.url];
    NSString *path =[aldDownloadHandler getCachedForPath:url];
    
    return path;
}
-(NSString *)cachesPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", _name, _fileType]];
    return path;
}
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    NSLog(@"total size: %lld", request.contentLength);
    _progress.totalSize = request.contentLength/1024.0/1024.0;
}
-(void)requestStarted:(ASIHTTPRequest *)request{
//    _downloading = YES;
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    if ([_fileType isEqualToString:@"zip"]) {
       // [self unzipFile];
    }
    if([_delegate respondsToSelector:@selector(downloadFinish:)])
   {
       [_delegate downloadFinish:self.sign];
   }
    //[self removeRequestFromQueue];
//    _downloading = NO;
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    NSError *error = [request error];
    NSLog(@"download failed, error: %@", error);
    
    [self removeRequestFromQueue];
//    _downloading = NO;
}
-(void)removeRequestFromQueue{
    for (ASIHTTPRequest *r in [_queue operations]) {
        NSString *fileName = [r.userInfo objectForKey:@"Name"];
        if ([fileName isEqualToString:_name]) {
            [r clearDelegatesAndCancel];
        }
    }
}

/**
 * 当前请求是否有缓存
 * @param url 请求url
 * @return 如果有缓存，则直接返回该缓存文件路径
 **/
-(NSString*) hasCachedForUrl
{
    ALDAsyncDownloader *aldDownloadHandler=[ALDAsyncDownloader asyncDownloader];
    NSURL *url=[NSURL URLWithString:[self chineseToUTf8Str: self.url]];
    NSString *path =[aldDownloadHandler getCachedForUrlPath:url];

    return path;
}
-(NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    chineseStr = [chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return chineseStr;
}
-(NSString *)getPathOfDocuments
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    
    path = [path stringByAppendingPathComponent:@"ImagesCache"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSError *error=nil;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return path;

}
//-(void)unzipFile{
//    NSString *unzipPath = [_savePath stringByAppendingPathComponent:_name];
//    ZipArchive *unzip = [[ZipArchive alloc] init];
//    if ([unzip UnzipOpenFile:[self actualSavePath]]) {
//        BOOL result = [unzip UnzipFileTo:unzipPath overWrite:YES];
//        if (result) {
//            NSLog(@"unzip successfully");
//        }
//        [unzip UnzipCloseFile];
//    }
//    unzip = nil;
//}
//-(void)dealloc
//{
//    [_queue release];
//    _queue = nil;
//    [_progress release];
//    _progress = nil;
//    [_label release];
//    _label = nil;
//    [super dealloc];
//}
@end
