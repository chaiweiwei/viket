//
//  MyInfomationViewController.h
//  WeTalk
//
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDDataChangedDelegate.h"

@interface MyInfomationViewController : BaseViewController

@property (weak,nonatomic) id<ALDDataChangedDelegate> dataChangedDelegate;
@end
