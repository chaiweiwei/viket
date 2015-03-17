//
//  ViewController.h
//  bo
//
//  Created by chaiweiwei on 14/12/19.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface PlayViewController:UIViewController
{
    MPMoviePlayerController *mp;
    NSURL *movieURL;                        //视频地址
    UIActivityIndicatorView *loadingAni;    //加载动画
    UILabel *label;                            //加载提醒
}
@property (nonatomic,retain) NSURL *movieURL;

//准备播放
- (void)readyPlayer;

@end
