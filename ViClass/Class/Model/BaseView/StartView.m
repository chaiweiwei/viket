//
//  StartView.m
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "StartView.h"
#import "KGModal.h"
#import "HttpClient.h"

#define TAG_BTN_STAR1  0x11
#define TAG_BTN_STAR2  0x12
#define TAG_BTN_STAR3  0x13
#define TAG_BTN_STAR4  0x14
#define TAG_BTN_STAR5  0x15
#define TAG_BTN_OK     0x16
#define TAG_BTN_CANCEL 0x17
@interface StartView()<DataLoadStateDelegate>
{
    UIView *startView;
    long score;
}

@end

@implementation StartView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        CGFloat viewWidth = CGRectGetWidth(self.frame);
        CGFloat viewHeight= CGRectGetHeight(self.frame);
    
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, viewWidth, 15)];
        label.textAlignment = TEXT_ALIGN_CENTER;
        label.textColor = KWordWhiteColor;
        label.text = @"请打分";
        
        [self addSubview:label];
        
        startView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth-145)/2.0, 20, 200, 35)];
        startView.backgroundColor = [UIColor clearColor];
        [self addSubview:startView];

        UIButton *btn = [self createBtn:CGRectMake(5,10, 25, 25) tag:TAG_BTN_STAR1];
        [startView addSubview:btn];
        
        btn = [self createBtn:CGRectMake(35,10, 25, 25) tag:TAG_BTN_STAR2];
        [startView addSubview:btn];
        
        btn = [self createBtn:CGRectMake(65,10, 25, 25) tag:TAG_BTN_STAR3];
        [startView addSubview:btn];
        
        btn = [self createBtn:CGRectMake(95,10, 25, 25) tag:TAG_BTN_STAR4];
        [startView addSubview:btn];
        
        btn = [self createBtn:CGRectMake(125,10, 25, 25) tag:TAG_BTN_STAR5];
        [startView addSubview:btn];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(startView.frame), CGRectGetMaxY(startView.frame)+10, viewWidth, 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.textColor = KWordWhiteColor;
        label.text = @"PS: 感谢您的支持";
        [self addSubview:label];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight-49, viewWidth, 1)];
        line.backgroundColor = KWordWhiteColor;
        [self addSubview:line];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(0, viewHeight-49, (viewWidth-1)/2.0, 49)];
        btn.tag = TAG_BTN_CANCEL;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        
        line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), viewHeight-49, 1, 49)];
        line.backgroundColor = KWordWhiteColor;
        [self addSubview:line];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake((viewWidth-1)/2.0+1, viewHeight-49, (viewWidth-1)/2.0, 49)];
        btn.tag = TAG_BTN_OK;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
        
    }
    return self;
}
-(UIButton *)createBtn:(CGRect)rect tag:(int)tag
{
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    [btn setBackgroundImage:[UIImage imageNamed:@"icon_star"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"icon_star_sel"] forState:UIControlStateSelected];
    btn.tag = tag;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
//处理start标记
-(void)clicked:(UIButton *)sender
{
    if(!sender.selected)
    {
        for (long i=1; i<=sender.tag - 0x10; i++) {
            long tag = 0x10+i;
            UIButton *btn =(UIButton *) [startView viewWithTag:tag];
            btn.selected = YES;
            score = i;
        }
    }
    else if(sender.selected)
    {
        score = sender.tag - 0x10 - 1;

        for (long i=sender.tag - 0x10; i<=5; i++) {
            long tag = 0x10+i;
            UIButton *btn =(UIButton *) [startView viewWithTag:tag];
            btn.selected = NO;
        }
    }
}
-(void)btnClicked:(UIButton *)sender
{
    switch (sender.tag) {
        case TAG_BTN_CANCEL:
        {
            
        }
            break;
        case TAG_BTN_OK:
        {
            if([self.delegate respondsToSelector:@selector(btnOKCallBack:)])
            {
                [self.delegate btnOKCallBack:(int)score];
            }
        }
            break;
    
        default:
            break;
    }
    [[KGModal sharedInstance] hide];
}
-(void)show
{
    [[KGModal sharedInstance] showWithContentView:self andAnimated:YES];
}

@end
