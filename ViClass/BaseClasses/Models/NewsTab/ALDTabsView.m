#import "ALDTabsView.h"
#import "ALDTabStyle.h"

@implementation ALDTabsView

@synthesize tabViews;
@synthesize style;
@synthesize needResizeTab=_needResizeTab;

-(id) initWithFrame:(CGRect)frame{
     if ((self = [super initWithFrame:frame])) {
         self.needResizeTab=YES;
     }
    return self;
}

- (void)layoutSubviews {
    if (_needResizeTab) {
        NSUInteger N = [self.tabViews count];
        
        CGFloat W;
        //  NSUInteger overlap = W * self.style.overlapAsPercentageOfTabWidth;
        NSUInteger overlap = 1;
        W = (self.frame.size.width + overlap * (N-1)) / N;

        NSUInteger tabIndex = 0;
        
        for (UIView *tabView in self.tabViews) {
            CGRect tabFrame = CGRectMake(tabIndex * W,
                                         self.style.tabsViewHeight - self.style.tabHeight - self.style.tabBarHeight,
                                         W, self.style.tabHeight);
            
            if (tabIndex > 0)
                tabFrame.origin.x -= tabIndex * overlap;
            
            tabView.frame = tabFrame;
            
            tabIndex++;
        }
    }
}

- (void)dealloc {
  self.tabViews = nil;
  self.style = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
