//
//  EmbedButton.m
//  Zenithzone
//
//  Created by alidao on 14-11-8.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "EmbedButton.h"

#define kArrowWith 8.8
#define kArrowHeight 12.7
#define kNoteWith 50
#define kIconWith 24
#define kIconHeight 22

@interface EmbedButton ()

@property (retain,nonatomic) UIColor *preBgColor;
@property (retain,nonatomic) UIImage *preBgImage;

@property (retain,nonatomic) UIImageView *bgView;

@property (nonatomic,retain) UIImage *bgImage;
@property (nonatomic,retain) UIImage *bgSelectImage;

@end

@implementation EmbedButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc
{
    self.userInfo=nil;
    self.bgView=nil;
    self.preBgImage=nil;
    self.selectBgColor=nil;
    self.preBgColor=nil;
    self.bgImage=nil;
    self.bgSelectImage=nil;

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
        // Initialization code
        self.arrowViewSize=CGSizeMake(kArrowWith, kArrowHeight);
        self.iconFrame=CGRectMake(20, (self.frame.size.height-kIconHeight)/2.f, kIconWith, kIconHeight);
        _iconView =[[ALDImageView alloc] initWithFrame:CGRectZero];
        _iconView.autoResize=YES;
        [self addSubview:_iconView];
        
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
            CGFloat viewWidth=CGRectGetWidth(self.frame);
            CGFloat viewHeigh=CGRectGetHeight(self.frame);
            CGSize imgSize=CGSizeMake(bgImage.size.width/2, bgImage.size.height/2);
            CGRect imgFrame=CGRectMake((viewWidth-imgSize.width)/2, (viewHeigh-imgSize.height)/2, imgSize.width, imgSize.height);
            if(self.edgeState==KEdgeInsetTop){
                CGFloat startY=2;
                if(self.isCenter){
                    startY=(viewHeigh-imgSize.height)/2;
                }
                imgFrame=CGRectMake((self.frame.size.width-imgSize.width)/2, startY, imgSize.width, imgSize.height);
            }else if(self.edgeState==KEdgeInsetLeft){
                CGFloat startX=(viewWidth-imgSize.width)/2;
                if(!self.isCenter){
                    startX-=imgSize.width;
                }
                imgFrame=CGRectMake(startX, (self.frame.size.height-imgSize.height)/2, imgSize.width, imgSize.height);
            }else if(self.edgeState==KEdgeInsetRight){
                CGFloat startX=(viewWidth-imgSize.width)/2;
                if(!self.isCenter){
                    startX+=10;
                }
                imgFrame=CGRectMake(startX, (self.frame.size.height-imgSize.height)/2, imgSize.width, imgSize.height);
            }else if(self.edgeState==KEdgeInsetBottom){
                CGFloat startY=(viewHeigh-imgSize.height)/2;
                if(!self.isCenter){
                    startY=viewHeigh-imgSize.height;
                }else{
                    startY+=imgSize.height/2;
                }
                imgFrame=CGRectMake((self.frame.size.width-imgSize.width)/2, startY, imgSize.width, imgSize.height);
            }else{
                imgFrame=CGRectMake((viewWidth-imgSize.width)/2, (viewHeigh-imgSize.height)/2, imgSize.width, imgSize.height);
            }

            self.bgView=ALDReturnAutoreleased([[UIImageView alloc] initWithImage:bgImage]);
            self.bgView.frame=imgFrame;
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
            CGSize imgSize=CGSizeMake(selectBgImage.size.width/2, selectBgImage.size.height/2);
            CGRect imgFrame=CGRectMake((self.frame.size.width-imgSize.width)/2, 2, imgSize.width, imgSize.height);
            self.bgView=ALDReturnAutoreleased([[UIImageView alloc] initWithFrame:imgFrame]);
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
        CGRect bgFrame=_bgView.frame;
        _bgView.frame=bgFrame;
    }
    if(self.edgeState==KEdgeInsetTop){
        self.titleEdgeInsets=UIEdgeInsetsMake(_bgView.frame.size.height+3, 0, 0, 0);
    }else if(self.edgeState==KEdgeInsetLeft){
        self.titleEdgeInsets=UIEdgeInsetsMake(0, _bgView.frame.size.width+3, 0, 0);
    }else if(self.edgeState==KEdgeInsetRight){
        self.titleEdgeInsets=UIEdgeInsetsMake(0, 0, _bgView.frame.size.width+3, 0);
    }else if(self.edgeState==KEdgeInsetBottom){
        self.titleEdgeInsets=UIEdgeInsetsMake(0, 0, 0, _bgView.frame.size.height+3);
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
