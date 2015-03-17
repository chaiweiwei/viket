//
//  ALDSegmentedControl.m
//  ZYClub
//
//  Created by chen yulong on 14-3-21.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "ALDSegmentedControl.h"
#import "ALDButton.h"
#import "ALDUtils.h"

@interface ALDSegmentedControl ()
@property (nonatomic) NSInteger selectedIndex;

@property (retain,nonatomic) UIColor *borderColor;
@property (retain,nonatomic) UIColor *normalBgColor;
@property (retain,nonatomic) UIColor *selectedBgColor;
@property (retain,nonatomic) UIColor *normalTitleColor;
@property (retain,nonatomic) UIColor *selectedTitleColor;

@end

@implementation ALDSegmentedControl

#define kTAG_OFSET 1000
#define kBorderWidth 1.5f

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _onlyEnableIndex=-1;
        self.selectedIndex=0;
        self.needResponseCurrentClick=NO;
//        self.borderColor=RGBCOLOR(174, 120, 40);
        self.borderColor=[UIColor blackColor];
        self.layer.borderColor=_borderColor.CGColor;
        self.layer.borderWidth=kBorderWidth;
        self.layer.masksToBounds=YES;
        self.layer.cornerRadius=4;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withTitleItems:(NSArray*)items{
    self=[self initWithFrame:frame];
    if (self) {
        self.items=items;
    }
    return self;
}

-(void) setItems:(NSArray *)items{
    if (_items) {
        ALDRelease(_items);
    }
    _items=ALDReturnRetained(items);
    NSArray *subViews=self.subviews;
    for (UIView *view in subViews) {
        [view removeFromSuperview];
    }
    
    NSInteger count=items.count;
    CGFloat btnWidth=(self.frame.size.width-(count-1)*kBorderWidth)/count;
    CGFloat btnHeight=self.frame.size.height-2*kBorderWidth;
    CGFloat startX=0;
    for (int i=0; i<count; i++) {
        NSString *title=[items objectAtIndex:i];
        ALDButton *button=[ALDButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setFrame:CGRectMake(startX, kBorderWidth, btnWidth, btnHeight)];
        button.tag=kTAG_OFSET+i;
        if (_onlyEnableIndex!=-1 && _onlyEnableIndex!=i) {
            button.enabled=NO;
        }
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font=[UIFont boldSystemFontOfSize:13];
        [self addSubview:button];
        startX+=btnWidth;
        if (i<count-1) {
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(startX, kBorderWidth, kBorderWidth, btnHeight)];
            lineView.backgroundColor=_borderColor;
            [self addSubview:lineView];
            ALDRelease(lineView);
            startX+=kBorderWidth;
        }
    }
    [self setSelectAtIndex:_selectedIndex];
}

-(void) setOnlyEnableIndex:(NSInteger)onlyEnableIndex{
    _onlyEnableIndex=onlyEnableIndex;
    NSArray *subViews=self.subviews;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[ALDButton class]]) {
            ALDButton *button=(ALDButton*)view;
            NSInteger bindex=button.tag-kTAG_OFSET;
            if (_onlyEnableIndex!=-1 && _onlyEnableIndex!=bindex) {
                button.enabled=NO;
            }else{
                button.enabled=YES;
            }
        }
    }
}

-(void) setSelectAtIndex:(NSInteger)index{
    self.selectedIndex=index;
    NSArray *subViews=self.subviews;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[ALDButton class]]) {
            ALDButton *button=(ALDButton*)view;
            NSInteger bindex=button.tag-kTAG_OFSET;
            if (bindex==_selectedIndex) {
                [button setBackgroundColor:_selectedBgColor];
                [button setTitleColor:_selectedTitleColor forState:UIControlStateNormal];
//                [self onButtonClicked:button];
            }else{
                [button setBackgroundColor:_normalBgColor];
                [button setTitleColor:_normalTitleColor forState:UIControlStateNormal];
            }
        }
    }
}

-(void) setViewBorderColor:(UIColor *)color{
    self.borderColor=color;
    self.layer.borderColor=_borderColor.CGColor;
    NSArray *subViews=self.subviews;
    for (UIView *view in subViews) {
        if (![view isKindOfClass:[ALDButton class]]) {
            view.backgroundColor=color;
        }
    }
}

-(void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState) state{
    if (state==UIControlStateNormal) {
        self.normalBgColor=backgroundColor;
    }else{
        self.selectedBgColor=backgroundColor;
    }
    [self setSelectAtIndex:_selectedIndex];
}

-(void) setTitleColor:(UIColor *) textColor forState:(UIControlState) state{
    if (state==UIControlStateNormal) {
        self.normalTitleColor=textColor;
    }else{
        self.selectedTitleColor=textColor;
    }
    [self setSelectAtIndex:_selectedIndex];
}

-(void) setTitleFont:(UIFont *)font{
    NSArray *subViews=self.subviews;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[ALDButton class]]) {
            ALDButton *btn=(ALDButton*)view;
            btn.titleLabel.font=font;
        }
    }
}

-(void) onButtonClicked:(ALDButton*) sender{
    NSInteger tag=sender.tag;
    NSInteger touchIndex=tag-kTAG_OFSET;
    if (touchIndex!=_selectedIndex || _needResponseCurrentClick) {
        if (touchIndex!=_selectedIndex) {
            [self setSelectAtIndex:touchIndex];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(segmentedControl:changedSelectedAtIndex:)]) {
            [_delegate segmentedControl:self changedSelectedAtIndex:touchIndex];
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

- (void)dealloc
{
    self.items=nil;
    self.borderColor=nil;
    self.normalBgColor=nil;
    self.selectedBgColor=nil;
    self.normalTitleColor=nil;
    self.selectedTitleColor=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
