//
//  ALDImageView.h
//  npf
//
//  Created by yulong chen on 12-5-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALDAsyncLoadImage.h"

@interface ALDImageView : UIImageView<AsyncLoadImageDelegate>{
    UIControlEvents _touchType; //需要响应的事件
    int _currTouchType; //当前触控类型，1:单击，2：双击，3：移动
    UIView *_coverView;
    BOOL _hasClickResponded; //是否已响应点击
}

@property (nonatomic,retain) NSString *imageUrl;
@property (nonatomic,retain) UIImage *defaultImage;
@property (nonatomic) BOOL needAutoCenter;
/** 是否可点击 **/
@property (nonatomic) BOOL clickAble;
@property (nonatomic) BOOL needShowBigImage;

/** 如果图片长宽比例不合适，是否需要将图片裁剪 **/
@property (nonatomic) BOOL needCropImage;
//@property (nonatomic) BOOL minCropImage; //根据小边裁剪
//自动缩放图片
@property (nonatomic) BOOL autoResize; 
//填充
@property (nonatomic) BOOL fitImageToSize; 
@property (nonatomic) int actIndicatorViewStyle;
/** 图片缩放比例 **/
@property (nonatomic) CGFloat scale;

@property (nonatomic,retain) NSDictionary *userInfo;
//目前只支持单击
-(void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@property (assign,nonatomic) id delegate;

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

- (UIImage *)autoScaleImage:(UIImage *)image;

//添加大图浏览
- (void)addBigImageShow:(NSString*)bigImageUrl;

- (void)imageTap;
@end
