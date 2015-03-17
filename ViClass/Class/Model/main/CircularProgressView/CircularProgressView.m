//
//  CircularProgressView.m
//  CircularProgressView
//
//  Created by nijino saki on 13-3-2.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://www.nijino.cn

#import "CircularProgressView.h"
#import <QuartzCore/QuartzCore.h>

@interface CircularProgressView ()<AVAudioPlayerDelegate>

@property (nonatomic) CADisplayLink *displayLink;//牵涉到画面的更新，动画过程的演变，我们通常会用CADisplayLink
@property (nonatomic) AVAudioPlayer *player;//an AVAudioPlayer instance
@property (nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) float progress;
@property (nonatomic) CGFloat angle;//angle between two lines

@end

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth
           audioURL:(NSURL *)audioURL {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
        _backColor = backColor;
        _progressColor = progressColor;
        self.lineWidth = lineWidth;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        _audioURL = audioURL;
        _player.delegate = self;
        [_player prepareToPlay];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}
//手势
- (void)setUp{
    self.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}
//设置宽度
- (void)setLineWidth:(CGFloat)lineWidth{
    //打底的进度条背景
    CAShapeLayer *backgroundLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.backColor];
    _lineWidth = lineWidth;
    [self.layer addSublayer:backgroundLayer];
    //运行过程中的背景
    _progressLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.progressColor];
    //进度条的百分比是通过CAShapeLayer的strokeEnd属性来实现
    _progressLayer.strokeEnd = 0;
    [self.layer addSublayer:_progressLayer];
}

- (void)setAudioURL:(NSURL *)audioURL{
    if (audioURL) {
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        self.player.delegate = self;
        self.duration = self.player.duration;
        [self.player prepareToPlay];
    }
    _audioURL = audioURL;
}

- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:- M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
    //原理是CAShapeLayer可以通过指定Path的方式实现生成一个图形
    CAShapeLayer *slice = [CAShapeLayer layer];//创建一个track shape layer  
    slice.contentsScale = [[UIScreen mainScreen] scale];
    slice.frame = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    slice.fillColor = [UIColor clearColor].CGColor;
    slice.strokeColor = color.CGColor;////指定path的渲染颜色
    slice.lineWidth = lineWidth;
    slice.lineCap = kCALineJoinBevel;////指定线的边缘是圆的
    slice.lineJoin = kCALineJoinBevel;
    slice.path = smoothedPath.CGPath;///把path传递給layer，然后layer会处理相应的渲染，整个逻辑和CoreGraph是一致的。
    return slice;
}

- (void)setProgress:(float)progress{
    if (progress == 0) {
        self.progressLayer.hidden = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressLayer.strokeEnd = 0;
        });
    }else {
        self.progressLayer.hidden = NO;
        self.progressLayer.strokeEnd = progress;
    }
}

- (void)updateProgressCircle{
    //update progress value
    self.progress = (float) (self.player.currentTime / self.player.duration);
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
        [self.delegate updateProgressViewWithPlayer:self.player];
    }
}

- (void)play{
    if (!self.player.playing) {
        if (!self.displayLink) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressCircle)];
            self.displayLink.frameInterval = 6;//改变每秒运行帧数
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        } else {
            self.displayLink.paused = NO;//不停止
        }
        [self.player play];
    }
}

- (void)pause{
    if (self.player.playing) {
        self.displayLink.paused = YES;//定时器停止
        [self.player pause];
    }
}

- (void)stop{
    [self.player stop];
    self.progress = 0;
    self.player.currentTime = 0;
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark AVAudioPlayerDelegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        //restore progress value
        self.progress = 0;
        [self.delegate playerDidFinishPlaying];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer{
    CGPoint point = [recognizer locationInView:self];
    self.angle = [self angleFromStartToPoint:point];
    self.player.currentTime = self.player.duration * (self.angle / (2 * M_PI));
    if (!self.player.playing) {
        [self play];
    }
    [self.delegate updatePlayOrPauseButton];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.displayLink.paused = YES;
        CGPoint point = [recognizer locationInView:self];
        self.angle = [self angleFromStartToPoint:point];
        self.progress = self.angle/(M_PI * 2);
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
            [self.delegate updateProgressViewWithPlayer:self.player];
        }
    }

    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.player.currentTime = self.player.duration * (self.angle / (2 * M_PI));
        if (!self.player.playing) [self play];
        else
            self.displayLink.paused = NO;
        [self.delegate updatePlayOrPauseButton];
    }
}

//calculate angle between start to point
- (CGFloat)angleFromStartToPoint:(CGPoint)point{
    CGFloat angle = [self angleBetweenLinesWithLine1Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                 Line1End:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2 - 1)
                                               Line2Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
                                                 Line2End:point];
    if (CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)), point)) {
        angle = 2 * M_PI - angle;
    }
    return angle;
}

//calculate angle between 2 lines
- (CGFloat)angleBetweenLinesWithLine1Start:(CGPoint)line1Start
                                  Line1End:(CGPoint)line1End
                                Line2Start:(CGPoint)line2Start
                                  Line2End:(CGPoint)line2End{
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    return acos(((a * c) + (b * d)) / ((sqrt(a * a + b * b)) * (sqrt(c * c + d * d))));
}

@end