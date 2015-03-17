//
//  ALDSegmentedControl.h
//  ZYClub
//
//  Created by chen yulong on 14-3-21.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALDSegmentedControl;

@protocol ALDSegmentedControlDelegate <NSObject>

-(void) segmentedControl:(ALDSegmentedControl*) segmentedControl changedSelectedAtIndex:(NSInteger) index;

@end

@interface ALDSegmentedControl : UIView

@property (retain,nonatomic) NSArray *items;
@property (assign,nonatomic) id<ALDSegmentedControlDelegate> delegate;

@property (nonatomic) NSInteger onlyEnableIndex;

@property (nonatomic) BOOL needResponseCurrentClick;

- (id)initWithFrame:(CGRect)frame withTitleItems:(NSArray*)items;

-(void) setSelectAtIndex:(NSInteger) index;

-(void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState) state;

-(void) setTitleColor:(UIColor *) textColor forState:(UIControlState) state;

-(void) setViewBorderColor:(UIColor*) color;

-(void) setTitleFont:(UIFont*) font;

@end
