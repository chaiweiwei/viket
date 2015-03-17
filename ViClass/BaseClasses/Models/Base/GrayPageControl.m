//
//  GrayPageControl.m
//  hyt_ios
//
//  Created by aaa a on 12-6-4.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import "GrayPageControl.h"

@implementation GrayPageControl

@synthesize activeImage,inactiveImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (isIOS7){
            self.pageIndicatorTintColor=[UIColor grayColor];
            self.currentPageIndicatorTintColor=kTitleBarColor;
        }else{
            self.activeImage=[UIImage imageNamed:@"icon_dot01"];
            self.inactiveImage=[UIImage imageNamed:@"icon_dot02"];
        }
    }
    return self;
}

- (void)dealloc
{
    self.activeImage=nil;
    self.inactiveImage=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void) updateDots
{
    
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        if (i == self.currentPage) dot.image = activeImage;
        else dot.image = inactiveImage;
    }
}
-(void) setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    //    [self updateDots];
    
    //IOS7已经不是UIImageView了，所以不能这样用了
    if (isIOS7){
        return;
    }
    if (!activeImage || !inactiveImage) {
        return;
    }
    
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        CGSize size;
        size.height = 8;
        size.width = 8;
        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
                                     size.width,size.height)];
        if (subviewIndex == page) {
            [subview setImage:activeImage];
        }else{
            [subview setImage:inactiveImage];
        }
    }
    
}






/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
