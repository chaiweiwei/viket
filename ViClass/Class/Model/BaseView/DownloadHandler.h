#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ProgressIndicator.h"

@protocol DownloadDelegate <NSObject>

-(void)downloadFinish:(int)sign;

@end
@interface DownloadHandler : NSObject
<ASIHTTPRequestDelegate, ASIProgressDelegate>

@property (nonatomic,copy) NSString *url;
//下载资源的名称
@property (nonatomic,copy) NSString *name;
//下载资源的类型，即后缀
@property (nonatomic,copy) NSString *fileType;
@property (nonatomic,copy) NSString *savePath;
@property (nonatomic,retain) ProgressIndicator *progress;

@property (nonatomic,assign) id<DownloadDelegate> delegate;
@property (nonatomic,assign) int sign;//标记是哪一个cell

+(DownloadHandler *)sharedInstance;

-(void)start;

-(void)removeRequestFromQueue;

@end
