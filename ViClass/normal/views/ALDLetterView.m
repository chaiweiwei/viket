//
//  ALDLetterView.m
//  npf
//
//  Created by yulong chen on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDLetterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ALDLetterView
@synthesize rootView;
@synthesize showTimes;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = frame.size.width/2.0f; 
        self.layer.masksToBounds = YES;
        self.alpha=0.9;
        self.showTimes=1.0f;
        self.backgroundColor=[UIColor blueColor];
        self.textColor=[UIColor whiteColor];
        self.font=[UIFont boldSystemFontOfSize:25];
        self.textAlignment=TEXT_ALIGN_CENTER;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.center=self.superview.center;
    isShowing=YES;
    [super drawRect:rect];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:self.showTimes];
}

-(void) show{
    if (isShowing) {
        return;
    }
    isShowing=YES;
    if (rootView) {
        [rootView addSubview:self];
    }else {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window)
        {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        [window addSubview:self];
    } 
}

-(void) dismiss{
    isShowing=NO;
    [self removeFromSuperview];
}

- (void)dealloc
{
    self.rootView=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
