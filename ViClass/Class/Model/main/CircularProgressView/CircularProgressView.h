//
//  CircularProgressView.h
//  CircularProgressView
//
//  Created by nijino saki on 13-3-2.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://www.nijino.cn

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CircularProgressViewDelegate <NSObject>

@optional

- (void)updateProgressViewWithPlayer:(AVAudioPlayer *)player;
- (void)updatePlayOrPauseButton;
- (void)playerDidFinishPlaying;

@end

@interface CircularProgressView : UIView

@property (nonatomic) UIColor *backColor;  //圆环的颜色
@property (nonatomic) UIColor *progressColor;  //进度条的颜色
@property (nonatomic) NSURL *audioURL;   //播放的音乐
@property (nonatomic) CGFloat lineWidth;   //圆环的宽度
@property (nonatomic) NSTimeInterval duration;  //时间间隔
@property (nonatomic) BOOL playOrPauseButtonIsPlaying;
@property (nonatomic) id <CircularProgressViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor  //圆环的颜色
      progressColor:(UIColor *)progressColor   //进度条的颜色
          lineWidth:(CGFloat)lineWidth    //圆环的宽度
           audioURL:(NSURL *)audioURL;    //播放的音乐

- (void)play;
- (void)pause;
- (void)stop;

@end