//
//  UIBarButtonItem+ALDBackBarButtonItem.h
//  hyapp_V5
//
//  Created by chen yulong on 13-12-28.
//  Copyright (c) 2013年 chen yulong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (ALDBackBarButtonItem)

- (id)initBackButtonWithTitle:(NSString*)aTitleOrNil color:(UIColor*)aColorOrNil;

- (id)initBackButtonWithTitle:(NSString*)aTitleOrNil
                        color:(UIColor*)aColorOrNil
                       target:(id) target
                       action:(SEL)action;
@end
