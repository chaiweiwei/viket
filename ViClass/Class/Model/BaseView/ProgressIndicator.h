#import <UIKit/UIKit.h>

@interface ProgressIndicator : UIView

//下载资源的总大小
@property CGFloat totalSize;

@property (nonatomic,retain) UIProgressView *progressView;

@end
