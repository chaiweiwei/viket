//
//  EmbedButton.h
//  Zenithzone
//
//  Created by alidao on 14-11-8.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALDImageView.h"

typedef enum {
    KEdgeInsetNo =0,
    KEdgeInsetTop = 1,
    KEdgeInsetLeft = 2,
    KEdgeInsetRight = 3,
    KEdgeInsetBottom = 4
} KEdgeInset;

@interface EmbedButton : UIButton

@property (nonatomic) CGRect iconFrame;
@property (nonatomic) CGSize arrowViewSize;
@property (nonatomic) CGFloat iconTextDis; //图标与文本的距离
@property (nonatomic,readonly,retain) ALDImageView *iconView;
@property (nonatomic,retain) UIColor *selectBgColor;

@property (nonatomic,retain) NSDictionary *userInfo;
@property (nonatomic,assign) KEdgeInset edgeState;
@property (nonatomic) UIEdgeInsets titleEdgeInset;
@property (nonatomic) BOOL isCenter;

/**
 * 设置背景图片
 **/
-(void) setButtonBgImage:(UIImage *)bgImage;

/**
 * 设置按钮选择或点击时的背景图片
 **/
-(void) setButtonSelectBgImage:(UIImage*) selectBgImage;

@end
