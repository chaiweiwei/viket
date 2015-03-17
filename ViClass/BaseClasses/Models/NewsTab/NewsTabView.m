//
//  AgendaTabView.m
//  ipna
//
//  Created by chen yulong on 13-7-31.
//  Copyright (c) 2013年 chen yulong. All rights reserved.
//

#import "NewsTabView.h"
#import "ALDTabStyle.h"

#define kHorizontalSectionCount           4
#define kGridWidthInSection               16
#define kGridHeight                       20
#define kTabHeightInGridUnits             17
#define kBottomControlPointDXInGridUnits  8
#define kBottomControlPointDYInGridUnits  1
#define kTopControlPointDXInGridUnits     10
#define kLeftDes 15

static inline CGFloat radians(CGFloat degrees) {
    return degrees * M_PI/180;
}

@interface NewsTabView ()
@property (nonatomic, retain) UIView  *selectTagView;
@property (nonatomic, retain, readwrite) UILabel *titleLabel;
@property (nonatomic,retain) UILabel *bageLabel; //数字标示

@end

@implementation NewsTabView
@synthesize titleLabel, delegate, selected, style;
@synthesize selectTagView=_selectTagView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        
        self.opaque = NO;
        self.backgroundColor = RGBCOLOR(240, 240, 240);
        self.style = [ALDTabStyle defaultStyle];
        
        CGFloat fStartY = 5;
        UIFont *font=[UIFont systemFontOfSize:22.0f];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, fStartY, frame.size.width, frame.size.height-14)];
        label.font=font;
        label.textAlignment = TEXT_ALIGN_CENTER;
        label.lineBreakMode = LineBreakModeTailTruncation;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = self.style.unselectedTitleTextColor;
        label.shadowColor = self.style.unselectedTitleShadowColor;
        label.shadowOffset = self.style.unselectedTitleShadowOffset;
        [self addSubview:label];
        self.titleLabel=label;
        fStartY = fStartY + label.frame.size.height + 5;
        
        UIView *redBlockView         = [[UIView alloc] initWithFrame:CGRectMake(0, fStartY, frame.size.width, 3)];
        redBlockView.backgroundColor = KWordRedColor;
        [self addSubview:redBlockView];
        redBlockView.hidden=NO;
        self.selectTagView=redBlockView;
        
        //数字标示
        label=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 16, 16)];
        label.backgroundColor=KWordRedColor;
        label.font=[UIFont systemFontOfSize:12.0f];
        label.textColor=[UIColor whiteColor];
        label.textAlignment=TEXT_ALIGN_CENTER;
        label.layer.masksToBounds=YES;
        label.layer.cornerRadius=8;
        label.hidden=YES;
        [self addSubview:label];
        self.bageLabel=label;
        
        [self setTitle:title];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(_onTap:)]];
    }
    
    return self;
}

- (void)_configureTitleLabel {
    if (self.selected) {
        self.titleLabel.textColor    = self.style.selectedTitleTextColor;
        self.titleLabel.shadowColor  = self.style.selectedTitleShadowColor;
        self.titleLabel.shadowOffset = self.style.selectedTitleShadowOffset;
        self.titleLabel.font         = self.style.selectedTitleFont;
    } else {
        self.titleLabel.textColor    = self.style.unselectedTitleTextColor;
        self.titleLabel.shadowColor  = self.style.unselectedTitleShadowColor;
        self.titleLabel.shadowOffset = self.style.unselectedTitleShadowOffset;
        self.titleLabel.font         = self.style.unselectedTitleFont;
    }
}

- (void)_onTap:(UIGestureRecognizer *)gesture {
    UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *) gesture;
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(didTapTabView:)]) {
            [self.delegate didTapTabView:self];
        }
    }
}

-(void) setTitle:(NSString *)title{
    titleLabel.text=title;
    CGSize size=[ALDUtils captureTextSizeWithText:title textWidth:2000 font:titleLabel.font];
//    size.width=110;
    CGRect titleFrame=titleLabel.frame;
    titleFrame.size.width=size.width/*+2*kLeftDes*/;
    titleLabel.frame=titleFrame;
    titleLabel.adjustsFontSizeToFitWidth=YES;
    
    CGRect tagFrame=_selectTagView.frame;
    tagFrame.size.width=titleFrame.size.width;
    _selectTagView.frame=tagFrame;
    
    CGRect frame=self.frame;
    frame.size.width=tagFrame.size.width;
    self.frame=frame;
}

-(void) setTitleFrame:(CGRect) titleFrame
{
    CGRect subFrame=titleLabel.frame;
    if(subFrame.size.width<titleFrame.size.width){
        CGFloat bageX=subFrame.size.width+(titleFrame.size.width-subFrame.size.width)/2-8;
        CGRect bageFrame=self.bageLabel.frame;
        bageFrame.origin.x=bageX;
        self.bageLabel.frame=bageFrame;
        subFrame.size.width=titleFrame.size.width;
    }else{
        CGFloat bageX=subFrame.size.width;
        CGRect bageFrame=self.bageLabel.frame;
        bageFrame.origin.x=bageX;
        self.bageLabel.frame=bageFrame;
    }
    titleLabel.frame=subFrame;
    
    CGRect tagFrame=_selectTagView.frame;
    tagFrame.size.width=titleFrame.size.width;
    _selectTagView.frame=tagFrame;
    
    CGRect frame=self.frame;
    frame.size.width=tagFrame.size.width;
    self.frame=frame;
}

-(void) setBageCount:(int)bageCount
{
    NSString *text=@"";
    if(bageCount>0){
        if(bageCount>99){
            text=@"99";
        }else{
            text=[NSString stringWithFormat:@"%d",bageCount];
        }
        self.bageLabel.hidden=NO;
    }else{
        self.bageLabel.hidden=YES;
    }
    self.bageLabel.text=text;
}

-(NSString*) title{
    return titleLabel.text;
}

-(void) layoutSubviews{
    [self _configureTitleLabel];
    UIColor *tabColor = (self.selected ? self.style.selectedTabColor : self.style.unselectedTabColor);
    self.backgroundColor=tabColor;
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)isSelected {
    selected = isSelected;
    if (isSelected) {
        _selectTagView.hidden=NO;
        titleLabel.textColor=self.style.selectedTitleTextColor;
//        titleLabel.font=self.style.selectedTitleFont;
    }else{
        _selectTagView.hidden=YES;
        titleLabel.textColor=self.style.unselectedTitleTextColor;
//        titleLabel.font=self.style.unselectedTitleFont;
    }
    [self setNeedsDisplay];
}

- (void)dealloc {
    self.titleLabel = nil;
    self.style = nil;
    self.delegate=nil;
    self.selectTagView=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
