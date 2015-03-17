//
//  WaitingView.h
//  hyt
//
//  Created by 陈 小静 on 11-12-29.
//  Copyright (c) 2011年 chen xiaojing. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef kWaitingViewTag
#define kWaitingViewTag 1999 //等待
#endif

typedef enum {
    WaitingActivityInLeft,
    WaitingActivityInTop,
} WaitingActivityPosition;

@interface WaitingView : UIView{
    UIView *_panelView;
    UILabel *_textView;
    BOOL isShowing; //是否已显示
}

@property(nonatomic,assign) WaitingActivityPosition activityPosition;
@property(nonatomic,retain)NSString *showMessage;
@property(nonatomic,retain)UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic,retain)UIImageView *warningView;
@property(nonatomic,assign)UIView *rootView;

-(void) show; //显示
-(void) hide; //隐藏
@end
