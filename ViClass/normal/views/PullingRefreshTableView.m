

#import "PullingRefreshTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewsLocalizedString.h"
#import "ALDUtils.h"

#define kPROffsetY 60.f
#define kPRMargin 5.f
#define kPRLabelHeight 20.f
#define kPRLabelWidth 100.f
#define kPRArrowWidth 20.f  
#define kPRArrowHeight 40.f

#define kTextColor [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define kPRBGColor [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define kPRAnimationDuration .18f

@interface LoadingView () 
- (void)updateRefreshDate :(NSDate *)date;
- (void)layouts;
@end

@implementation LoadingView
@synthesize atTop = _atTop;
@synthesize state = _state;
@synthesize loading = _loading;

@synthesize topTips=_topTips,topReleaseTips=_topReleaseTips,topStateTips=_topStateTips;
@synthesize bottomTips=_bottomTips,bottomReleaseTips=_bottomReleaseTips,bottomStateTips=_bottomStateTips;

 //Default is at top
- (id)initWithFrame:(CGRect)frame atTop:(BOOL)top {
    self = [super initWithFrame:frame];
    if (self) {
        self.atTop = top;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = kPRBGColor;
//        self.backgroundColor = [UIColor clearColor];
        UIFont *ft = [UIFont systemFontOfSize:12.f];
        _stateLabel = [[UILabel alloc] init ];
        _stateLabel.font = ft;
        _stateLabel.textColor = kTextColor;
        _stateLabel.textAlignment = TEXT_ALIGN_CENTER;
        _stateLabel.backgroundColor = kPRBGColor;
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _stateLabel.text = ViewsLocalizedString(@"下拉刷新",@"Pull_down_refresh", @"");
        [self addSubview:_stateLabel];

        _dateLabel = [[UILabel alloc] init ];
        _dateLabel.font = ft;
        _dateLabel.textColor = kTextColor;
        _dateLabel.textAlignment = TEXT_ALIGN_CENTER;
        _dateLabel.backgroundColor = kPRBGColor;
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _dateLabel.text = NSLocalizedString(@"最后更新", @"");
        [self addSubview:_dateLabel];
        
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20) ];

        _arrow = [CALayer layer];
        _arrow.frame = CGRectMake(0, 0, 20, 20);
        _arrow.contentsGravity = kCAGravityResizeAspect;
      
        _arrow.contents = (id)[UIImage imageWithCGImage:[UIImage imageNamed:@"blueArrow"].CGImage scale:1 orientation:UIImageOrientationDown].CGImage;

        [self.layer addSublayer:_arrow];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        
        [self layouts];
        
    }
    return self;
}

- (void)dealloc
{
    ALDRelease(_topTips);
    ALDRelease(_topReleaseTips);
    ALDRelease(_topStateTips);
    ALDRelease(_bottomTips);
    ALDRelease(_bottomReleaseTips);
    ALDRelease(_bottomStateTips);
    
    ALDRelease(_stateLabel);
    ALDRelease(_dateLabel);
    ALDRelease(_arrowView);
    ALDRelease(_activityView);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)layouts {
    
    CGSize size = self.frame.size;
    CGRect stateFrame,dateFrame,arrowFrame;

    float x = 0,y,margin;
//    x = 0;
    margin = (kPROffsetY - 2*kPRLabelHeight)/2;
    if (self.isAtTop) {
        y = size.height - margin - kPRLabelHeight;
        dateFrame = CGRectMake(0,y,size.width,kPRLabelHeight);
        
        y = y - kPRLabelHeight;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        
        x = kPRMargin;
        y = size.height - margin - kPRArrowHeight;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
        UIImage *arrow = [UIImage imageNamed:@"blueArrow"];
        _arrow.contents = (id)arrow.CGImage;
        
    } else {    //at bottom
        y = margin;
        stateFrame = CGRectMake(0, y, size.width, kPRLabelHeight );
        
        y = y + kPRLabelHeight;
        dateFrame = CGRectMake(0, y, size.width, kPRLabelHeight);
        
        x = kPRMargin;
        y = margin;
        arrowFrame = CGRectMake(4*x, y, kPRArrowWidth, kPRArrowHeight);
        
        UIImage *arrow = [UIImage imageNamed:@"blueArrowDown"];        
        _arrow.contents = (id)arrow.CGImage;
        _stateLabel.text = ViewsLocalizedString(@"上拉加载更多",@"Pull_up_Load", @"");
    }
    
    _stateLabel.frame = stateFrame;
    _dateLabel.frame = dateFrame;
    _arrowView.frame = arrowFrame;
    _activityView.center = _arrowView.center;
    _arrow.frame = arrowFrame;
    _arrow.transform = CATransform3DIdentity;
}

- (void)setState:(PRState)state {
    [self setState:state animated:YES];
}

- (void)setState:(PRState)state animated:(BOOL)animated{
    float duration = animated ? kPRAnimationDuration : 0.f;
    if (_state != state) {
        _state = state;
        if (_state == kPRStateLoading) {    //Loading
            
            _arrow.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
            
            _loading = YES;
            if (self.isAtTop) {
                _stateLabel.text = _topStateTips;
            } else {
                _stateLabel.text = _bottomStateTips;
            }
            
        } else if (_state == kPRStatePulling && !_loading) {    //Scrolling
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [CATransaction commit];
            
            if (self.isAtTop) {
                _stateLabel.text = _topReleaseTips;
            } else {
                _stateLabel.text = _bottomReleaseTips;
            }
            
        } else if (_state == kPRStateNormal && !_loading){    //Reset
            
            _arrow.hidden = NO;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            _arrow.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            if (self.isAtTop) {
                _stateLabel.text = _topTips;
            } else {
                _stateLabel.text = _bottomTips;
            }
        } else if (_state == kPRStateHitTheEnd) {
            if (!self.isAtTop) {    //footer
                _arrow.hidden = YES;
                _stateLabel.text = ViewsLocalizedString(@"没有了哦",@"No_more", @"");
            }
        }
    }
}

- (void)setLoading:(BOOL)loading {
//    if (_loading == YES && loading == NO) {
//        [self updateRefreshDate:[NSDate date]];
//    }
    _loading = loading;
}

- (void)updateRefreshDate :(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *dateString = [df stringFromDate:date];
    NSString *title = ViewsLocalizedString(@"今天",@"Today", @"");
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                               fromDate:date toDate:[NSDate date] options:0];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    if (year == 0 && month == 0 && day < 3) {
        if (day == 0) {
            title = ViewsLocalizedString(@"今天",@"Today", @"");
        } else if (day == 1) {
            title = ViewsLocalizedString(@"昨天",@"Yesterday", @"");
        } else if (day == 2) {
            title = ViewsLocalizedString(@"前天",@"Before_yesterday", @"");
        }
        df.dateFormat = @"HH:mm";
        dateString = [df stringFromDate:date];
        dateString=[NSString stringWithFormat:@"%@ %@",title,dateString];
        
    } 
    _dateLabel.text = [NSString stringWithFormat:@"%@: %@",
                       ViewsLocalizedString(@"最后更新",@"Latest_update", @""),
                       dateString];
    ALDRelease(df);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface PullingRefreshTableView (){
    BOOL _isInitedView;
}
- (void)scrollToNextPage;
@end

@implementation PullingRefreshTableView
@synthesize pullingDelegate = _pullingDelegate;
@synthesize autoScrollToNextPage;
@synthesize reachedTheEnd = _reachedTheEnd;
@synthesize headerOnly = _headerOnly;
@synthesize needLoading=_needLoading;

- (void)dealloc {
    if (hasContentSizeObserver) {
        [self removeObserver:self forKeyPath:@"contentSize"];
    }
    ALDRelease(_headerView);
    ALDRelease(_footerView);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
//        NSLog(@"PullingRefreshTableView initWithFrame called");
        [self initViews:frame];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame pullingDelegate:(id<PullingRefreshTableViewDelegate>)aPullingDelegate {
    self = [self initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        self.pullingDelegate = aPullingDelegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullingDelegate:(id<PullingRefreshTableViewDelegate>)aPullingDelegate{
    self = [self initWithFrame:frame style:style];
    if (self) {
        self.pullingDelegate = aPullingDelegate;
    }
    return self;
}

-(void) initViews:(CGRect) frame{
    _isInitedView=YES;
    CGRect rect = CGRectMake(0, 0 - frame.size.height, frame.size.width, frame.size.height);
    _headerView = [[LoadingView alloc] initWithFrame:rect atTop:YES];
    _headerView.atTop = YES;
    [self addSubview:_headerView];
    
    rect = CGRectMake(0, frame.size.height, frame.size.width, frame.size.height);
    _footerView = [[LoadingView alloc] initWithFrame:rect atTop:NO];
    _footerView.atTop = NO;
    [self addSubview:_footerView];
    
    [self setTopTips:ViewsLocalizedString(@"下拉刷新",@"Pull_down_refresh", @"")];
    [self setTopReleaseTips:ViewsLocalizedString(@"释放刷新",@"Release_refresh", @"")];
    [self setTopStateTips:ViewsLocalizedString(@"正在刷新",@"Refreshing", @"")];
    [self setBottomTips:ViewsLocalizedString(@"上拉加载更多",@"Pull_up_Load", @"")];
    [self setBottomReleaseTips:ViewsLocalizedString(@"释放加载更多",@"Release_load_more", @"")];
    [self setBottomStateTips:ViewsLocalizedString(@"正在加载",@"Loading", @"")];
    
    [self addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    hasContentSizeObserver=YES;
}

-(void) layoutSubviews{
    if (!_isInitedView) {
        [self initViews:self.frame];
    }
    [super layoutSubviews];
}

-(void) setTopTips:(NSString *)topTips{
    _headerView.topTips=topTips;
    _footerView.topTips=topTips;
}

-(void) setTopReleaseTips:(NSString *)topReleaseTips{
    _headerView.topReleaseTips=topReleaseTips;
    _footerView.topReleaseTips=topReleaseTips;
}

-(void) setTopStateTips:(NSString *)topStateTips{
    _headerView.topStateTips=topStateTips;
    _footerView.topStateTips=topStateTips;
}

-(void) setBottomTips:(NSString *)bottomTips{
    _headerView.bottomTips=bottomTips;
    _footerView.bottomTips=bottomTips;
}

-(void) setBottomReleaseTips:(NSString *)bottomReleaseTips{
    _headerView.bottomReleaseTips=bottomReleaseTips;
    _footerView.bottomReleaseTips=bottomReleaseTips;
}

-(void) setBottomStateTips:(NSString *)bottomStateTips{
    _headerView.bottomStateTips=bottomStateTips;
    _footerView.bottomStateTips=bottomStateTips;
}

- (void)setReachedTheEnd:(BOOL)reachedTheEnd{
    _reachedTheEnd = reachedTheEnd;
    if (_reachedTheEnd){
        _footerView.state = kPRStateHitTheEnd;
    } else {
        _footerView.state = kPRStateNormal;
    }
}

- (void)setHeaderOnly:(BOOL)headerOnly{
    _headerOnly = headerOnly;
    _footerView.hidden = _headerOnly;
}

-(void) setNeedLoading:(BOOL)needLoading{
    _needLoading=needLoading;
    BOOL hidden=!needLoading;
    _headerView.hidden=hidden;
    _footerView.hidden=hidden;
}

#pragma mark - Scroll methods

- (void)scrollToNextPage {
    float h = self.frame.size.height;
    float y = self.contentOffset.y + h;
    y = y > self.contentSize.height ? self.contentSize.height : y;
    
//    [UIView animateWithDuration:.4 animations:^{
//        self.contentOffset = CGPointMake(0, y);
//    }];
//    NSIndexPath *ip = [NSIndexPath indexPathForRow:_bottomRow inSection:0];
//    [self scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    
    [UIView animateWithDuration:.7f 
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut 
                     animations:^{
                        self.contentOffset = CGPointMake(0, y);  
                     }
                     completion:^(BOOL bl){
                     }];
}

- (void)tableViewDidScroll:(UIScrollView *)scrollView {

    if (_headerView.state == kPRStateLoading || _footerView.state == kPRStateLoading) {
        return;
    }

    CGPoint offset = scrollView.contentOffset;
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
 
    float yMargin = offset.y + size.height - contentSize.height;
    if (offset.y < -kPROffsetY) {   //header totally appeard
         _headerView.state = kPRStatePulling;
    } else if (offset.y > -kPROffsetY && offset.y < 0){ //header part appeared
        _headerView.state = kPRStateNormal;
        
    } else if ( yMargin > kPROffsetY){  //footer totally appeared
        if (_footerView.state != kPRStateHitTheEnd) {
            _footerView.state = kPRStatePulling;
        }
    } else if ( yMargin < kPROffsetY && yMargin > 0) {//footer part appeared
        if (_footerView.state != kPRStateHitTheEnd) {
            _footerView.state = kPRStateNormal;
        }
    }
}

- (void)tableViewDidEndDragging:(UIScrollView *)scrollView {
    
//    CGPoint offset = scrollView.contentOffset;
//    CGSize size = scrollView.frame.size;
//    CGSize contentSize = scrollView.contentSize;
    if (_headerView.state == kPRStateLoading || _footerView.state == kPRStateLoading) {
        return;
    }
    if (_headerView.state == kPRStatePulling) {
//    if (offset.y < -kPROffsetY) {
        _isFooterInAction = NO;
        _headerView.state = kPRStateLoading;
        
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            self.contentInset = UIEdgeInsetsMake(kPROffsetY, 0, 0, 0);
        }];
        if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingTableViewDidStartRefreshing:)]) {
            [_pullingDelegate pullingTableViewDidStartRefreshing:self];
        }
    } else if (_footerView.state == kPRStatePulling) {
//    } else  if (offset.y + size.height - contentSize.height > kPROffsetY){
        if (self.reachedTheEnd || self.headerOnly) {
            return;
        }
        _isFooterInAction = YES;
        _footerView.state = kPRStateLoading;
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            self.contentInset = UIEdgeInsetsMake(0, 0, kPROffsetY, 0);
        }];
        if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingTableViewDidStartLoading:)]) {
            [_pullingDelegate pullingTableViewDidStartLoading:self];
        }
    }
}

- (void)tableViewDidFinishedLoading {
    [self tableViewDidFinishedLoadingWithMessage:nil];  
}

- (void)tableViewDidFinishedLoadingWithMessage:(NSString *)msg{

    //    if (_headerView.state == kPRStateLoading) {
    if (_headerView.loading) {
        _headerView.loading = NO;
        [_headerView setState:kPRStateNormal animated:NO];
        NSDate *date = [NSDate date];
        if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingTableViewRefreshingFinishedDate)]) {
            date = [_pullingDelegate pullingTableViewRefreshingFinishedDate];
        }
        [_headerView updateRefreshDate:date];
        [UIView animateWithDuration:kPRAnimationDuration*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL bl){
            if (msg != nil && ![msg isEqualToString:@""]) {
                [self flashMessage:msg];
            }
        }];
    }
    //    if (_footerView.state == kPRStateLoading) {
    else if (_footerView.loading) {
        _footerView.loading = NO;
        [_footerView setState:kPRStateNormal animated:NO];
        NSDate *date = [NSDate date];
        if (_pullingDelegate && [_pullingDelegate respondsToSelector:@selector(pullingTableViewLoadingFinishedDate)]) {
            date = [_pullingDelegate pullingTableViewRefreshingFinishedDate];
        }
        [_footerView updateRefreshDate:date];
        
        [UIView animateWithDuration:kPRAnimationDuration animations:^{
            self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL bl){
            if (msg != nil && ![msg isEqualToString:@""]) {
                [self flashMessage:msg];
            }
        }];
    }
}

- (void)flashMessage:(NSString *)msg{
    //Show message
    __block CGRect rect = CGRectMake(0, self.contentOffset.y - 20, self.bounds.size.width, 20);
    
    if (_msgLabel == nil) {
        _msgLabel = ALDReturnAutoreleased([[UILabel alloc] init]);
        _msgLabel.frame = rect;
        _msgLabel.font = [UIFont systemFontOfSize:14.f];
        _msgLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _msgLabel.backgroundColor = kPRBGColor;
        _msgLabel.textAlignment = TEXT_ALIGN_CENTER;
        [self addSubview:_msgLabel];    
    }
    _msgLabel.text = msg;
    
    rect.origin.y += 20;
    [UIView animateWithDuration:.4f animations:^{
        _msgLabel.frame = rect;
    } completion:^(BOOL finished){
        rect.origin.y -= 20;
        [UIView animateWithDuration:.4f delay:1.2f options:UIViewAnimationOptionCurveLinear animations:^{
            _msgLabel.frame = rect;
        } completion:^(BOOL finished){
            [_msgLabel removeFromSuperview];
            _msgLabel = nil;            
        }];
    }];
}

-(void) setFootInloading{
    _footerView.state = kPRStateLoading;
    _footerView.loading=YES;
}

- (void)launchRefreshing {
    [self setContentOffset:CGPointMake(0,0) animated:NO];
    [UIView animateWithDuration:kPRAnimationDuration animations:^{
        self.contentOffset = CGPointMake(0, -kPROffsetY-1);
    } completion:^(BOOL bl){
        [self tableViewDidEndDragging:self];
    }];
}

-(void) launchLoadingMore{
    [self setContentOffset:CGPointMake(0,0) animated:NO];
    [UIView animateWithDuration:kPRAnimationDuration animations:^{
        self.contentOffset = CGPointMake(0, self.frame.size.height+kPROffsetY);
    } completion:^(BOOL bl){
        [self tableViewDidEndDragging:self];
    }];
}

#pragma mark - 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    CGRect frame = _footerView.frame;
    CGSize contentSize = self.contentSize;
    frame.origin.y = contentSize.height < self.frame.size.height ? self.frame.size.height : contentSize.height;
    _footerView.frame = frame;
    if (self.autoScrollToNextPage && _isFooterInAction) {
        [self scrollToNextPage];
        _isFooterInAction = NO;
    } else if (_isFooterInAction) {
        CGPoint offset = self.contentOffset;
        offset.y += 44.f;
        self.contentOffset = offset;
    }

    
}

@end
