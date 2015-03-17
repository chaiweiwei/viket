//
//  SendCommentViewController.h
//  Zenithzone
//  发布评论
//  Created by alidao on 14-11-7.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDDataChangedDelegate.h"

@interface FeedBackViewController : BaseViewController

//1.问题反馈 2.课程反馈
@property (nonatomic,assign) int type;
@property (nonatomic,retain) NSString *sourceId;
@property (nonatomic,retain) NSNumber *sid;
//@property (nonatomic,assign) id<ALDDataChangedDelegate> dataChangedDelegate;
@property (nonatomic,retain) UIViewController *parentVController;

@end
