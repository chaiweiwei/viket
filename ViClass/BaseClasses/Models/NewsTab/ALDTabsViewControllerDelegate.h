//
//  ALDTabsViewControllerDelegate.h
//  Basics
//
//  Created by alidao on 14/12/1.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALDTabsViewControllerDelegate <NSObject>
@optional

- (BOOL)shouldMakeTabCurrentAtIndex:(NSUInteger)index
                         controller:(UIViewController *)viewController
                   tabBarController:(UIViewController *)tabBarController;

- (void)didMakeTabCurrentAtIndex:(NSUInteger)index
                      controller:(UIViewController *)viewController
                tabBarController:(UIViewController *)tabBarController;

@end