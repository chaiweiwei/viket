//
//  AgendaTabView.h
//  ipna
//
//  Created by chen yulong on 13-7-31.
//  Copyright (c) 2013年 chen yulong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALDTabStyle;

@protocol ALDTabViewDelegate <NSObject>
- (void)didTapTabView:(UIView *)tabView;
@end

@interface NewsTabView : UIView
@property (nonatomic, retain, readonly) UILabel *titleLabel;
@property (nonatomic, assign) id <ALDTabViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) ALDTabStyle *style;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) int bageCount;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

-(void) setTitleFrame:(CGRect) titleFrame;

@end
