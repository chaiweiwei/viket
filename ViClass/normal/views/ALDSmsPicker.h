//
//  ALDSmsPicker.h
//  hyt_ios
//
//  Created by yulong chen on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface ALDSmsPicker : NSObject<MFMessageComposeViewControllerDelegate>

@property (nonatomic,retain) UIViewController *rootViewController;

/**
 * 发送短信,调用该方法前必须设置rootViewController
 */
- (void)sendsms:(NSString *)message;
@end
