//
//  NewsTabViewController.h
//  WhbApp
//
//  首页入口、滑动Tab
//
//  Created by chen yulong on 13-9-4.
//  Copyright (c) 2013年 Bibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALDTabsView.h"
#import "ALDTabStyle.h"
#import "BaseViewController.h"

@protocol ALDTabsViewControllerDelegate <NSObject>
@optional

- (BOOL)shouldMakeTabCurrentAtIndex:(NSUInteger)index
                         controller:(UIViewController *)viewController
                   tabBarController:(UIViewController *)tabBarController;

- (void)didMakeTabCurrentAtIndex:(NSUInteger)index
                      controller:(UIViewController *)viewController
                tabBarController:(UIViewController *)tabBarController;

@end

@interface NewsTabViewController : BaseViewController<UIScrollViewDelegate>{
    NSArray *_viewControllers;
//    UIView *_contentView;
    UIScrollView *contentView;
    ALDTabsView *_tabsContainerView;
    ALDTabStyle *_tabStyle;
    NSUInteger currentTabIndex;
}

//@property (nonatomic, assign, readonly) UIView *contentView;
@property (nonatomic, assign, readonly) UIScrollView                  *contentView;
@property (nonatomic, retain          ) ALDTabStyle                   *tabStyle;
@property (nonatomic, assign          ) id <ALDTabsViewControllerDelegate> delegate;

@end
