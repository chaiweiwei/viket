//
//  ArrowButton.h
//  HezuoHz
//
//  Created by yulong chen on 13-3-22.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALDImageView.h"

@interface ArrowButton : UIButton{
    //    UILabel *_titleView;
}
@property (nonatomic) CGRect iconFrame;
@property (nonatomic) CGSize arrowViewSize;
@property (nonatomic) BOOL noteAtLeft;
@property (nonatomic) CGFloat iconTextDis; //图标与文本的距离
@property (nonatomic,readonly,retain) ALDImageView *iconView;
@property (nonatomic,readonly,retain) UILabel *textView;
@property (nonatomic,readonly,retain) UILabel *noteView;
@property (nonatomic,readonly,retain) UIImageView *arrowView;
@property (nonatomic,retain) UIColor *selectBgColor;

@property (nonatomic,retain) NSDictionary *userInfo;

/**
 * 设置背景图片
 **/
-(void) setButtonBgImage:(UIImage *)bgImage;

/**
 * 设置按钮选择或点击时的背景图片
 **/
-(void) setButtonSelectBgImage:(UIImage*) selectBgImage;

@end
