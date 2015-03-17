//
//  ShowTips.m
//  FunCat
//
//  Created by alidao on 14-10-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "ShowTips.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kTipsAnimationTag 21543 //提示信息tag
#define KWaitTag 21544

@interface ShowTips ()
{
    CGImageSourceRef gif;
    NSDictionary *gifProperties;
    size_t index;
    size_t count;
    NSTimer *timer;
    int tag_Index;
}
@property (weak,nonatomic) UILabel  *msgLabel;
@property (weak,nonatomic) UIButton *retryBtn;

@end

@implementation ShowTips

- (id)initWithFrame:(CGRect )frame
{
    self = [super initWithFrame:frame];
    
    if(self){
        
    }
    return self;
}

+(void) showTips:(UIView *) parentView text:(NSString *)text delegate:(id)delegate
{
    [ShowTips showTips:parentView text:text delegate:delegate needRetry:YES];
}

+(void) showTips:(UIView *)parentView text:(NSString *)text delegate:(id)delegate needRetry:(BOOL)needRetry{
    [ShowTips showTips:parentView frame:parentView.frame text:text delegate:delegate needRetry:needRetry];
}

+(void) showTips:(UIView *) parentView frame:(CGRect)frame text:(NSString *)text delegate:(id)delegate
{
    [ShowTips showTips:parentView frame:frame text:text delegate:delegate needRetry:YES];
}

+(void) showTips:(UIView *)parentView frame:(CGRect)frame text:(NSString *)text delegate:(id)delegate needRetry:(BOOL)needRetry{
    ShowTips *animationView=(ShowTips *)[parentView viewWithTag:kTipsAnimationTag];

    CGFloat startX = 10.0f;
    CGFloat startY = 100.0f;
    if(isIOS7){
        startY+=64.0f;
    }
    CGFloat width    = CGRectGetWidth(frame)-2*startX;
    CGFloat height   = 150;
    CGRect tipsFrame = CGRectMake(startX, startY, width, height);
    if(animationView == nil){
        animationView = [[ShowTips alloc] initWithFrame:tipsFrame];
        animationView.backgroundColor = [UIColor clearColor];
        [animationView initView:tipsFrame text:text delegate:self];
        animationView.tag = kTipsAnimationTag;
        
    }else{
        animationView.frame         = tipsFrame;
        animationView.msgLabel.text = text;
    }
    if (needRetry) {
        animationView.retryBtn.hidden = NO;
    }else{
        animationView.retryBtn.hidden = YES;
    }
    animationView.delegate = delegate;
    [parentView addSubview:animationView];
}

-(void)initView:(CGRect)frame text:(NSString *)text delegate:(id)delegate
{
    CGFloat startX = 10.0f;
    CGFloat width  = CGRectGetWidth(frame)-2*startX;
    CGFloat startY = 0;
    
    UIImage *image = [UIImage imageNamed:kAnimationImg];
    CGSize imgSize = CGSizeMake(image.size.width/2, image.size.height/2);
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((width-imgSize.width)/2, startY, imgSize.width, imgSize.height)];
    imgView.image  = image;
    [self addSubview:imgView];
    startY += (imgSize.height+10);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, startY, width, 15.0f)];
    label.text          = text;
    label.textColor     = KWordGrayColor;
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textAlignment = TEXT_ALIGN_CENTER;
    label.backgroundColor=[UIColor clearColor];
    [self addSubview:label];
    self.msgLabel = label;
    startY += 15.0f;
    
    CGFloat btnWidth = 50.0f;
    CGFloat btnHeigh = 30.0f;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((width-btnWidth)/2, startY, btnWidth, btnHeigh);
    [btn setBackgroundImage:[UIImage imageNamed:@"shuaxin"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    self.retryBtn = btn;
}

+(void) hiddenTips:(UIView *)parentView
{
    ShowTips *animationView = (ShowTips *)[parentView viewWithTag:kTipsAnimationTag];
    if(animationView){
        [animationView removeFromSuperview];
        animationView = nil;
    }
}

-(void)clickBtn:(UIButton *)sender
{
    if(_delegate && [_delegate respondsToSelector:@selector(retry)]){
        [_delegate retry];
    }
}

-(void) initGifView:(CGRect )frame filePath:(NSString*)filePath msg:(NSString *)msg
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 105, CGRectGetWidth(frame), 20)];
    label.text          = msg;
    label.textAlignment = TEXT_ALIGN_CENTER;
    label.textColor     = KWordGrayColor;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];

    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame)-100)/2, 0, 100, 100)];
    NSArray *gifArray = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"img_cat1"],
                         [UIImage imageNamed:@"img_cat2"],
                         [UIImage imageNamed:@"img_cat3"],
                         [UIImage imageNamed:@"img_cat4"],
                         [UIImage imageNamed:@"img_cat3"],
                         [UIImage imageNamed:@"img_cat2"],
                         [UIImage imageNamed:@"img_cat1"],nil];
    gifImageView.animationImages = gifArray; //动画图片数组
    gifImageView.animationDuration = 0.5; //执行一次完整动画所需的时长
    gifImageView.animationRepeatCount = 0;  //动画重复次数
    [gifImageView startAnimating];
    gifImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:gifImageView];
    /*
    gifProperties= [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]forKey:(NSString*)kCGImagePropertyGIFLoopCount]  forKey:(NSString*)kCGImagePropertyGIFDictionary];
    gif=CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], (__bridge CFDictionaryRef)gifProperties);
    count=CGImageSourceGetCount(gif);
    timer=  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(play) userInfo:nil repeats:YES];
    [timer fire];  //通过动态播放来实现的
     */
}

//加载中
+(void) addWaitView:(UIView *)parentView msg:(NSString *)msg
{
    CGRect frame = parentView.frame;
    [self addWaitView:parentView frame:frame msg:msg];
}

+(void) addWaitView:(UIView *)parentView frame:(CGRect )frame msg:(NSString *)msg
{
    ShowTips *gifView = (ShowTips *)[parentView viewWithTag:KWaitTag];
    CGFloat viewWidth = CGRectGetWidth(frame)-20;
    CGFloat startX    = 10.0f;
    if(gifView == nil){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"playGif" ofType:@"gif"];
        gifView = [[ShowTips alloc] initWithFrame:CGRectMake(startX, 100, viewWidth, 100)];
        [gifView initGifView:CGRectMake(startX, 100, viewWidth, 100) filePath:filePath msg:msg];
        gifView.backgroundColor = [UIColor clearColor];
    }else{
        gifView.frame = CGRectMake(startX, 100, viewWidth, 100);
    }
    gifView.tag = KWaitTag;
    [parentView addSubview:gifView];
}

+(void) removeWaitView:(UIView *)parentView
{
    ShowTips *gifView = (ShowTips *)[parentView viewWithTag:KWaitTag];
    if(gifView){
        [gifView stopView];
        [gifView removeFromSuperview];
        gifView = nil;
    }
}

-(void)play {
    index++;
    index = index%count;
    CGImageRef ref = CGImageSourceCreateImageAtIndex(gif,index, (__bridge CFDictionaryRef)gifProperties);
    // 获取每一帧数的image
    self.layer.contents = (__bridge id)ref;
}

-(void)stopView {
    [timer invalidate];
    timer = nil;
}


@end
