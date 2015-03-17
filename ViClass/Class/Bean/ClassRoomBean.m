#import "ClassRoomBean.h"
#import "JSONUtils.h"
#import "ChapterBean.h"

@implementation ClassRoomBean
-(void) setChapters:(NSArray *)chapters{
    if (_chapters) {
        _chapters=nil;
    }
    if ([chapters isKindOfClass:[NSArray class]]) {
        if (chapters.count>0) {
            id temp=[chapters objectAtIndex:0];
            if (![temp isKindOfClass:[NSDictionary class]]) {
                _chapters=chapters;
            }else{
                _chapters=[JSONUtils jsonToArrayWithArray:chapters withItemClass:@"ChapterBean"];
            }
        }else{
            _chapters=chapters;
        }
    }
}
@end
