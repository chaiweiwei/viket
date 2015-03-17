//
//  MessagePushViewController.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/13.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDDataChangedDelegate.h"

@interface MessagePushViewController : BaseViewController

@property (nonatomic,assign) id<ALDDataChangedDelegate> dataDelgate;
@end
