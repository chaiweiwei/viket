//
//  IconTextButton.h
//  hyt_pro
//
//  Created by yulong chen on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIGlossyButton.h"
@interface IconTextButton : UIGlossyButton{
    @private 
    UIImageView *_iconView;
    UILabel *_textView;
}
@property (nonatomic) CGFloat padding;
@property (nonatomic) UITextAlignment alignment;
@property (nonatomic) CGSize iconSize;
@property (nonatomic) CGFloat iconTextDis;
@property (nonatomic) BOOL loginTag;

@property (nonatomic,readonly,getter = getIconView) UIImageView *iconView;
@property (nonatomic,readonly,getter = getTextView) UILabel *textView;

@property (assign,nonatomic) NSString *text;

- (id)initWithFrame:(CGRect)frame text:(NSString*)text icon:(UIImage*)icon;
@end
