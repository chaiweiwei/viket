//
//  ALDLetterView.h
//  npf
//
//  Created by yulong chen on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALDLetterView : UILabel{
    BOOL isShowing;
}

@property(nonatomic,retain) UIView *rootView;
@property(nonatomic) int showTimes;
-(void) show;
-(void) dismiss;
@end
