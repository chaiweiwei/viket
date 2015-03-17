//
//  BaseViewController.h
//  TZAPP
//
//  基类视图控制器
//
//  Created by x-Alidao on 14-8-13.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicsHttpClient.h"

@protocol LoginControllerDelegate <NSObject>

@required
-(void) loginView:(UIViewController*) loginView doneWithCode:(int) code withUser:(id)user;

@end

@interface BaseViewController : UIViewController<DataLoadStateDelegate>

@property (assign,nonatomic ) UIViewController *rootController;
@property (retain, nonatomic) id               background;
@property (assign, nonatomic) CGFloat baseStartY;

-(void) onBackClicked;

-(BOOL) isLogined;

-(void) drawBackground;

-(void) showLoginView;

-(UIView *)createLine:(CGRect) frame;
-(UILabel *) createLabel:(CGRect) frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont;

@end
