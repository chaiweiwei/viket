//
//  WelcomeViewController.h
//  TZAPP
//  欢迎界面/引导页
//  Created by alidao on 14-9-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"

@class WelcomeViewController;

@protocol WelcomeViewDelegate <NSObject>

@required
/** 当欢迎/引导界面完成时调用 **/
-(void) onWelcomeLoadDone:(WelcomeViewController*) controller;

@end

@interface WelcomeViewController : BaseViewController

/** 欢迎界面图片(默认就一张Default图片) **/
@property (retain,nonatomic) NSArray *welcomeImages;
/** 是否自动切换滑动(Bool),默认NO,如果只有一张则默认为YES **/
@property (retain,nonatomic) NSNumber *autoScroll;
/** 单页停留时间,单位秒,默认2s **/
@property (assign,nonatomic) NSInteger onePageTimes;

/** 委托 **/
@property (assign,nonatomic) id<WelcomeViewDelegate> delegate;

@end
