//
//  UIBarButtonItem+ALDBackBarButtonItem.m
//  hyapp_V5
//
//  Created by chen yulong on 13-12-28.
//  Copyright (c) 2013年 chen yulong. All rights reserved.
//

#import "UIBarButtonItem+ALDBackBarButtonItem.h"

@implementation UIImage (BackButtonIOS7)

+ (UIImage *) backButtonImageWithIOS7StyleWithChevronColor:(UIColor *) aColor
                                                barMetrics:(UIBarMetrics) aMetrics {
    CGSize size = aMetrics == UIBarMetricsDefault ? CGSizeMake(50, 30) : CGSizeMake(60, 23);
    
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, aColor.CGColor);
    CGContextSetLineWidth(context, 3.0f);
    
    /*** UNEXPECTED *****
     
     - not tested on portrait rotation (non-default bar metrics)
     
     *******************/
    
    static CGFloat const k_tip_x = 3;
    static CGFloat const k_wing_x = 13;
    static CGFloat const k_wing_y_offset = 6;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPoint tip = CGPointMake(k_tip_x, CGRectGetMidY(rect));
    CGPoint top = CGPointMake(k_wing_x, CGRectGetMinY(rect) + k_wing_y_offset);
    CGPoint bottom = CGPointMake(k_wing_x, CGRectGetMaxY(rect) - k_wing_y_offset);
    CGContextMoveToPoint(context, top.x, top.y);
    CGContextAddLineToPoint(context, tip.x, tip.y);
    CGContextAddLineToPoint(context, bottom.x, bottom.y);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // avoid tiling by stretching from the right-hand side only
    UIEdgeInsets insets = UIEdgeInsetsMake(k_wing_y_offset + 1, k_wing_x + 1,
                                           k_wing_y_offset + 1, 1);
    if ([image respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)]) {
        return [image resizableImageWithCapInsets:insets
                                     resizingMode:UIImageResizingModeStretch];
    } else {
        return [image resizableImageWithCapInsets:insets];
    }
}

@end

@implementation UIBarButtonItem (ALDBackBarButtonItem)

+ (UIColor *) colorForIOS7BackButton {
    static UIColor *ios7_blue_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ios7_blue_singleton = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:245/255.0f alpha:1.0f];
    });
    
    return ios7_blue_singleton;
}

+ (UIFont *) fontForIOS7BackButton {
    // font is not quiet right
    static UIFont *ios7_navbar_font_singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static NSString *const fontName = @"HelveticaNeue";
        ios7_navbar_font_singleton = [UIFont fontWithName:fontName size:17];
    });
    return ios7_navbar_font_singleton;
}

- (id)initBackButtonWithTitle:(NSString*)aTitleOrNil color:(UIColor*)aColorOrNil{
    return [self initBackButtonWithTitle:aTitleOrNil color:aColorOrNil target:nil action:nil];
}


- (id)initBackButtonWithTitle:(NSString*)aTitleOrNil
                        color:(UIColor*)aColorOrNil
                       target:(id) target
                       action:(SEL)action{
    NSString *title = aTitleOrNil;
    if (title == nil || [title length] == 0) {
        title = NSLocalizedString(@"Back", @"bar button title: touching brings you back to where you where");
    }
    
    self=[self initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    if (self) {
        UIColor *ios7Blue = [UIBarButtonItem colorForIOS7BackButton];
        UIColor *chevronColor = aColorOrNil ? aColorOrNil : ios7Blue;
        
        // on iOS 7 it looks like the highlight color is a transparency of the title color
        UIColor *titleColor = aColorOrNil ? aColorOrNil : ios7Blue;
        UIColor *highlightColor = [titleColor colorWithAlphaComponent:0.5f];
        
        
        [self setTitleColor:titleColor highlighted:highlightColor removeShadow:YES];
        [self setTitleFontBackButton:[UIBarButtonItem fontForIOS7BackButton]];
        
        [self configureIOS7StyleBackButtonItemOrProxy:chevronColor];
    }
    return self;
}

- (void) removeTitleShadow {
    NSArray *states = [NSArray arrayWithObjects:[NSNumber numberWithInt:UIControlStateNormal],[NSNumber numberWithInt:UIControlStateHighlighted],nil];
    for (NSNumber *state in states) {
        UIControlState controlState = [state unsignedIntegerValue];
        NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[self titleTextAttributesForState:controlState]];
        if (!titleTextAttributes) {
            titleTextAttributes = [NSMutableDictionary dictionary];
        }
        
        /*** UNEXPECTED ***
         UITextAttributeShadowOffset is deprecated in 5.0 - replaced with NSShadow
         - tried using NSShadow, but the shadow on the title remained
         - shadowOffset <== {0,0}, shadowColor <== nil (shadow not drawn according to docs)
         ******************/
        [titleTextAttributes setValue:[NSValue valueWithUIOffset:UIOffsetZero] forKey:UITextAttributeTextShadowOffset];
        [titleTextAttributes setObject:[UIColor clearColor] forKey:UITextAttributeTextShadowColor];
        [self setTitleTextAttributes:titleTextAttributes forState:controlState];
    }
}

- (void) setTitleColor:(UIColor *) aColor
           highlighted:(UIColor *) aHighlightedColor
          removeShadow:(BOOL) aRemoveShadow {
    NSArray *states = [NSArray arrayWithObjects:[NSNumber numberWithInt:UIControlStateNormal],[NSNumber numberWithInt:UIControlStateHighlighted],nil];
    for (NSNumber *state in states) {
        UIControlState controlState = [state unsignedIntegerValue];
        
        NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[self titleTextAttributesForState:controlState]];
        if (!titleTextAttributes) { titleTextAttributes = [NSMutableDictionary dictionary]; }
        
        UIColor *color = controlState == UIControlStateNormal ? aColor : aHighlightedColor;
        [titleTextAttributes setObject:color forKey:UITextAttributeTextColor];
        [self setTitleTextAttributes:titleTextAttributes forState:controlState];
    }
    if (aRemoveShadow == YES) { [self removeTitleShadow]; }
}

- (void) setTitleFontBackButton:(UIFont *) aTitleFont {
    NSArray *states =[NSArray arrayWithObjects:[NSNumber numberWithInt:UIControlStateNormal],[NSNumber numberWithInt:UIControlStateHighlighted],nil];
    for (NSNumber *state in states) {
        UIControlState controlState = [state unsignedIntegerValue];
        NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionaryWithDictionary:[self titleTextAttributesForState:controlState]];
        if (!titleTextAttributes) {
            titleTextAttributes = [NSMutableDictionary dictionary];
        }
        
        /*** UNEXPECTED ***
         UITextAttributeShadowOffset is deprecated in 5.0 - replaced with NSFontAttributeName
         - tried using NSFontAttributeName but the font does not change
         ******************/
        [titleTextAttributes setObject:aTitleFont forKey:UITextAttributeFont];
        [self setTitleTextAttributes:titleTextAttributes forState:controlState];
    }
}

-(void) configureIOS7StyleBackButtonItemOrProxy:(UIColor *) aCheveronColor {
    
    // normal and highlighted are the same
    UIImage *metricsDefaultImage = [UIImage backButtonImageWithIOS7StyleWithChevronColor:aCheveronColor
                                                                                 barMetrics:UIBarMetricsDefault];
    UIImage *metricsLandscapeImage =  [UIImage backButtonImageWithIOS7StyleWithChevronColor:aCheveronColor
                                                                                    barMetrics:UIBarMetricsLandscapePhone];
    
    
    [self setBackgroundImage:metricsDefaultImage
                          forState:UIControlStateNormal
                        barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:metricsLandscapeImage
                          forState:UIControlStateNormal
                        barMetrics:UIBarMetricsLandscapePhone];
    [self setBackgroundImage:metricsDefaultImage
                          forState:UIControlStateHighlighted
                        barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:metricsLandscapeImage
                          forState:UIControlStateHighlighted
                        barMetrics:UIBarMetricsLandscapePhone];
    
    [self setTitlePositionAdjustment:UIOffsetMake(10.0f, 0) forBarMetrics:UIBarMetricsDefault];
    [self setTitlePositionAdjustment:UIOffsetMake(10.0f, 0) forBarMetrics:UIBarMetricsLandscapePhone];
}

@end
