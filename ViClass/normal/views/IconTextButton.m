//
//  IconTextButton.m
//  hyt_pro
//
//  Created by yulong chen on 12-7-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IconTextButton.h"

@interface IconTextButton (private)
//点击效果
-(void) clickEffect;
//清除效果
-(void) clearEffect;
-(CGSize) captureTextSize:(NSString *) text font:(UIFont*)font;
@end

@implementation IconTextButton
@synthesize iconSize=_iconSize;
@synthesize iconTextDis=_iconTextDis;
@synthesize padding=_padding;
@synthesize alignment=_alignment;
@synthesize text=_text;
@synthesize loginTag=_loginTag;

#define kIconTextDis 1
#define kIconWidth 22.5f

- (void)dealloc
{
    ALDRelease(_textView);
    ALDRelease(_iconView);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect)frame text:(NSString*)text icon:(UIImage*)icon
{
    self = [super initWithFrame:frame];
    if (self) {
        UIFont *font=[UIFont boldSystemFontOfSize:17.f];
        self.iconSize=CGSizeMake(kIconWidth,kIconWidth);
        self.iconTextDis=kIconTextDis;
        self.padding=20;
        self.loginTag=NO;
        self.alignment=TEXT_ALIGN_CENTER;
        _iconView=[[UIImageView alloc] initWithImage:icon];
        _iconView.backgroundColor=[UIColor clearColor];
        [self addSubview:_iconView];
        _textView=[[UILabel alloc] initWithFrame:CGRectZero];
        _textView.text=text;
        _textView.numberOfLines=1;
        _textView.textAlignment=TEXT_ALIGN_LEFT;
        _textView.textColor=[UIColor whiteColor];
        _textView.font=font;
        _textView.backgroundColor=[UIColor clearColor];
        [self addSubview:_textView];
    }
    return self;
}

//计算文本占用高度和宽度
-(CGSize) captureTextSize:(NSString *) text font:(UIFont*)font{
    //self.frame.size.width-kAcWidth-kDistance - (kLeft * 2)
    CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:self.frame.size.width-kIconWidth-kIconTextDis font:font];
    return size;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) setText:(NSString *)text{
    _textView.text=text;
}

-(NSString*) text{
    return  _textView.text;
}

-(void) layoutSubviews{
    CGRect frame=self.frame;
    CGSize size=[self captureTextSize:_textView.text font:_textView.font];
    CGFloat width=size.width;
    CGFloat iconWidth=_iconSize.width;
    CGFloat iconHeight=_iconSize.height;
    CGFloat textDis=_iconTextDis;
    
    CGFloat contentWidth=iconWidth+width+textDis;
    
    CGFloat frameWidth=frame.size.width;
    CGFloat frameHeight=frame.size.height;
    CGFloat x;
    if (contentWidth>frameWidth) {
        contentWidth=frameWidth-_padding;
        width=contentWidth-iconWidth-textDis;
    }
    
    switch (_alignment) {
        case TEXT_ALIGN_LEFT:{
            x=_padding;
        }
            break;
        case TEXT_ALIGN_CENTER:{
            x=(frameWidth-contentWidth)/2.0f;
        }
            break;
        case TEXT_ALIGN_Right:{
            x=frameWidth-contentWidth-_padding;
        }
            break;
            
        default:{
            x=(frameWidth-contentWidth)/2.0f;
        }
            break;
    }
    
    _iconView.frame=CGRectMake(x,(frameHeight-iconHeight)/2.0f,iconWidth,iconHeight);
    _textView.frame=CGRectMake(x+textDis+iconWidth, 5, width, frameHeight-10);
    [super layoutSubviews];
}

-(UIImageView*) getIconView{
    return _iconView;
}

-(UILabel*) getTextView{
    return _textView;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clickEffect];
    [super touchesBegan:touches withEvent:event];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clearEffect];
    [super touchesCancelled:touches withEvent:event];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clearEffect];
    [super touchesEnded:touches withEvent:event];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clearEffect];
    [super touchesMoved:touches withEvent:event];
}

-(void) clearEffect{
//    self.backgroundColor=[UIColor clearColor];
}

-(void) clickEffect{
//    self.backgroundColor=[UIColor orangeColor];
}

@end
