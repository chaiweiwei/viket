//
//  ALDButton.h
//  NetBusiness
//
//  Created by yulong chen on 12-7-5.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALDButton : UIButton
@property (retain,nonatomic) NSDictionary *userInfo;
@property (retain,nonatomic) UIColor *selectBgColor;
@property (nonatomic) CGRect imageRect;

@end
