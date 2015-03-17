//
//  ALDToastView.h
//  why
//
//  Created by yulong chen on 12-4-11.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef kWaitingViewTag
#define kToastTag 2001 //提示
#endif
//提示信息view
@interface ALDToastView : UIView{
    NSString *_message; //显示的文本
}

@property (nonatomic) int fontSize; //显示文本大小
@property (nonatomic) float showTimes; //显示时长，即显示多长时间后消失,单位秒

- (void) setTipsMessage:(NSString *) message; //显示的文本
@end
