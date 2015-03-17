//
//  ShowTips.h
//  FunCat
//
//  Created by alidao on 14-10-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TipsViewDelegate <NSObject>

@required

-(void) retry;

@end

@interface ShowTips : UIView

@property (nonatomic,assign) id<TipsViewDelegate> delegate;

+(void) showTips:(UIView *) parentView text:(NSString *)text delegate:(id)delegate;

+(void) showTips:(UIView *) parentView text:(NSString *)text delegate:(id)delegate needRetry:(BOOL) needRetry;

+(void) showTips:(UIView *) parentView frame:(CGRect)frame text:(NSString *)text delegate:(id)delegate;

+(void) showTips:(UIView *) parentView frame:(CGRect)frame text:(NSString *)text delegate:(id)delegate needRetry:(BOOL) needRetry;

+(void) hiddenTips:(UIView *)parentView;

+(void) addWaitView:(UIView *)parentView msg:(NSString *)msg;
+(void) addWaitView:(UIView *)parentView frame:(CGRect )frame msg:(NSString *)msg;
+(void) removeWaitView:(UIView *)parentView;


@end
