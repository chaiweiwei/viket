#import "QuestionBean.h"

@implementation QuestionBean

#pragma mark - 对象初始化

-(void)setOptions:(NSArray *)options{
    if (_options) {
        _options=nil;
    }
    if ([options isKindOfClass:[NSArray class]]) {
        if (options.count>0) {
            id temp=[options objectAtIndex:0];
            if (![temp isKindOfClass:[NSDictionary class]]) {
                _options=options;
            }else{
                _options=[JSONUtils jsonToArrayWithArray:options withItemClass:@"OptionBean"];
            }
        }else{
            _options=options;
        }
    }
}

@end
