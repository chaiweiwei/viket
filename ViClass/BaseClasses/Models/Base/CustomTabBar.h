//
//  CustomTabBar.h
//  why
//
//  Created by aaa a on 11-4-6.
//  Copyright (c) 2011年 qw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBar : UITabBarController<UITabBarControllerDelegate> {
    
}
@property (assign,nonatomic) NSInteger preSelectedIndex;
@property (retain,nonatomic) UIView *tabbarView;
@property (retain,nonatomic) NSArray *titles;
@property (retain,nonatomic) NSArray *icons;
@property (retain,nonatomic) NSArray *selectedIcons;

-(void) reSetView;

-(void) setBarItems:(NSArray*) items;

- (void)customTabBar;

- (void)bringCustomTabBarToFront;

- (void)hideCustomTabBar;

- (void)changedTab:(NSInteger) selectIndx;

//-(void) changeNewsDataState;
//
//-(void) changeNewSessionState;


@end