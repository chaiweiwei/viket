#import "ChapterBean.h"

@implementation ChapterBean

-(void) setAttachments:(NSArray*)attachments{
    if (_attachments) {
        _attachments=nil;
    }
    if ([attachments isKindOfClass:[NSArray class]]) {
        if (attachments.count>0) {
            id temp=[attachments objectAtIndex:0];
            if (![temp isKindOfClass:[NSDictionary class]]) {
                _attachments=attachments;
            }else{
                _attachments=[JSONUtils jsonToArrayWithArray:attachments withItemClass:@"AttachmentBean"];
            }
        }else{
            _attachments=attachments;
        }
    }
}

@end
