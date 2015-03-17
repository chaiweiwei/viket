#import <UIKit/UIKit.h>

@class ALDTabStyle;

@interface ALDTabsView : UIView {
  NSArray *tabViews;
  ALDTabStyle *style;
}

@property (nonatomic, retain) NSArray *tabViews;
@property (nonatomic, retain) ALDTabStyle *style;
@property (nonatomic, assign) BOOL needResizeTab;


@end
