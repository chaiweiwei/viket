//
//  ArrowButton.m
//  HezuoHz
//
//  Created by yulong chen on 13-3-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "ArrowButton.h"
#import <QuartzCore/QuartzCore.h>

@interface ArrowButton ()
@property (retain,nonatomic) UIColor *preBgColor;
@property (retain,nonatomic) UIImage *preBgImage;

@property (retain,nonatomic) UIImageView *bgView;

@property (nonatomic,retain) UIImage *bgImage;
@property (nonatomic,retain) UIImage *bgSelectImage;
@end

@implementation ArrowButton
@synthesize iconFrame=_iconFrame;
@synthesize iconView=_iconView;
@synthesize textView=_textView;
@synthesize noteView=_noteView;
@synthesize arrowView=_arrowView;
@synthesize selectBgColor=_selectBgColor;
@synthesize preBgColor=_preBgColor;
@synthesize noteAtLeft=_noteAtLeft;
@synthesize bgView=_bgView;
@synthesize iconTextDis=_iconTextDis;
@synthesize arrowViewSize=_arrowViewSize;

@synthesize bgImage=_bgImage,bgSelectImage=_bgSelectImage;
@synthesize preBgImage=_preBgImage;
@synthesize userInfo=_userInfo;

#define kArrowWith 8.8
#define kArrowHeight 12.7
#define kNoteWith 50
#define kIconWith 24
#define kIconHeight 22

- (void)dealloc
{
    self.userInfo=nil;
    self.bgView=nil;
    self.preBgImage=nil;
    self.selectBgColor=nil;
    self.preBgColor=nil;
    self.bgImage=nil;
    self.bgSelectImage=nil;
    
    ALDRelease(_iconView);
    ALDRelease(_textView);
    ALDRelease(_noteView);
    ALDRelease(_arrowView);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
        self.layer.masksToBounds=YES;
        self.layer.cornerRadius=3;
        self.noteAtLeft=NO;
        // Initialization code
        self.arrowViewSize=CGSizeMake(kArrowWith, kArrowHeight);
        self.iconFrame=CGRectMake(20, (self.frame.size.height-kIconHeight)/2.f, kIconWith, kIconHeight);
        _iconView =[[ALDImageView alloc] initWithFrame:CGRectZero];
        _iconView.autoResize=YES;
        [self addSubview:_iconView];
        _textView=[[UILabel alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor=[UIColor clearColor];
        _textView.textAlignment=TEXT_ALIGN_LEFT;
        _textView.numberOfLines=1;
        _textView.textColor=[UIColor grayColor];
        _textView.font=[UIFont boldSystemFontOfSize:15];
        [self addSubview:_textView];
        _noteView=[[UILabel alloc] initWithFrame:CGRectZero];
        _noteView.backgroundColor=[UIColor clearColor];
        _noteView.textAlignment=TEXT_ALIGN_CENTER;
        _noteView.font=[UIFont systemFontOfSize:13];
        _noteView.textColor=[UIColor lightGrayColor];
        [self addSubview:_noteView];
        _arrowView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cell_arrow"]];
        [self addSubview:_arrowView];
    }
    return self;
}

/**
 * 设置背景图片
 **/
-(void) setButtonBgImage:(UIImage *)bgImage{
    self.bgImage=bgImage;
    if (bgImage) {
        if (!_bgView) {
            self.bgView=ALDReturnAutoreleased([[UIImageView alloc] initWithImage:bgImage]);
            [self insertSubview:_bgView atIndex:0];
        }else{
            [_bgView setImage:bgImage];
        }
    }else{
        if (_bgView && !_bgSelectImage) {
            [_bgView removeFromSuperview];
            self.bgView=nil;
        }
    }
}

/**
 * 设置按钮选择或点击时的背景图片
 **/
-(void) setButtonSelectBgImage:(UIImage*) selectBgImage{
    self.bgSelectImage=selectBgImage;
    if (selectBgImage) {
        if (!_bgView) {
            self.bgView=ALDReturnAutoreleased([[UIImageView alloc] initWithFrame:CGRectZero]);
            [self insertSubview:_bgView atIndex:0];
        }
    }else{
        if (_bgView && !_bgImage) {
            [_bgView removeFromSuperview];
            self.bgView=nil;
        }
    }
}

-(void) layoutSubviews{
    if (_bgView) {
        CGRect bgFrame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _bgView.frame=bgFrame;
    }
    CGFloat x=20;
    if (_iconView.image) {
        _iconView.hidden=NO;
        _iconView.frame=_iconFrame;
        if (_iconTextDis>0) {
            x=_iconFrame.origin.x+_iconFrame.size.width+_iconTextDis;
        }else{
            x=_iconFrame.origin.x+_iconFrame.size.width+5;
        }
    }else {
        _iconView.hidden=YES;
        if (_iconTextDis>0) {
            x=_iconTextDis;
        }
    }
    CGSize size=[ALDUtils captureTextSizeWithText:_noteView.text textWidth:2000 font:_noteView.font];
    CGFloat noteWidth=size.width;
    CGRect frame=self.bounds;
    CGFloat width;
    CGFloat arrowW=_arrowViewSize.width;
    if (_arrowView.hidden) {
        arrowW=0;
    }
    if (_noteAtLeft) {
        _noteView.textAlignment=TEXT_ALIGN_LEFT;
        size=[ALDUtils captureTextSizeWithText:_textView.text textWidth:2000 font:_textView.font];
        width=size.width+10;
    }else{
        width=frame.size.width-x-arrowW-2-noteWidth-10;
    }
    CGFloat height=frame.size.height;
    width=MIN(width, frame.size.width-x-noteWidth);
    _textView.frame=CGRectMake(x, 0, width, height);
    x=x+width;
    _noteView.frame=CGRectMake(x, 0, noteWidth, height);
    if (!_arrowView.hidden) {
        CGFloat y=(height-_arrowViewSize.height)/2.f;
        x=frame.size.width-arrowW-10;
        _arrowView.frame=CGRectMake(x, y, arrowW,_arrowViewSize.height);
    }
    [super layoutSubviews];
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_bgView) {
        self.preBgImage=_bgView.image;
        if (_bgSelectImage) {
            _bgView.image=_bgSelectImage;
        }
    }else{
        self.preBgColor=self.backgroundColor;
        if (_selectBgColor) {
            self.backgroundColor=_selectBgColor;
        }else {
            self.backgroundColor=[UIColor brownColor];
        }
    }
    return YES;
}

-(void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_bgView) {
        _bgView.image=_preBgImage;
    }else{
        self.backgroundColor=self.preBgColor;
    }
}

-(void) cancelTrackingWithEvent:(UIEvent *)event{
    if (_bgView) {
        _bgView.image=_preBgImage;
    }else{
        self.backgroundColor=self.preBgColor;
    }
}

@end
