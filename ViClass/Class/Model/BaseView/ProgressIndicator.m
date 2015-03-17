#import "ProgressIndicator.h"

@implementation ProgressIndicator
{
    UIProgressView *_progressView;
    UILabel *_label;
}
@synthesize totalSize = _totalSize;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
-(id)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}
-(void)initView{
    [self initProgressView];
    [self initLabel];
}
-(void)initProgressView{
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = CGRectMake(0, 0, self.frame.size.width, 15);
    [self addSubview:_progressView];
}
-(void)initLabel{
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, _progressView.frame.size.height+5.0, self.frame.size.width, 20.0)];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:13.0];
    _label.backgroundColor = [UIColor clearColor];
    [self addSubview:_label];
}
-(void)setProgress:(float)progress{
    [_progressView setProgress:progress];
    if (progress != 1.0) {
        _label.text = [NSString stringWithFormat:@"%.2f M / %.2f M", _totalSize*progress, _totalSize];
    } else {
        _label.text = @"download complete";
    }
}
-(void)setProgress:(float)progress animated:(BOOL)animated{
    [_progressView setProgress:progress animated:animated];
    if (progress != 1.0) {
        _label.text = [NSString stringWithFormat:@"%.2f M / %.2f M", _totalSize*progress, _totalSize];
    } else {
        _label.text = @"download complete";
    }
}
//-(void)dealloc{
//    [_progressView release];
//    _progressView  = nil;
//    [_label release];
//    _label = nil;
//    [super dealloc];
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
