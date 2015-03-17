//
//  ALDChoiseAlertView.h
//  BFEC
//
//  Created by chen yulong on 14-1-3.
//  Copyright (c) 2014年 alidao. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    ALDChoiseTypeMultiCheck, //default type
    ALDChoiseTypeRadio = 2,
}ALDChoiseType;

@class ALDChoiseAlertView;

@protocol ALDChoiseAlertViewDelegate <NSObject>

@optional
- (void)alertView:(ALDChoiseAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface ALDChoiseAlertView : UIView<UITableViewDelegate,UITableViewDataSource>{
    
}

@property (nonatomic,retain) NSArray *data;

@property (retain,nonatomic) UIView *contentView;
/**
 *the value used when the choiseType is ALDChoiseTypeMultiCheck
 **/
@property (nonatomic,retain) NSMutableDictionary *selectedData;
@property (nonatomic) ALDChoiseType choiseType;

@property (assign,nonatomic) id<ALDChoiseAlertViewDelegate> delegate;
/**
 *the value used when the choiseType is ALDChoiseTypeRadio
 **/
@property (nonatomic) NSInteger selectedIdx;

-(id) initWithTitle:(NSString *)title delegate:(id<ALDChoiseAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

-(void) showToView:(UIView*) rootView;

-(void) dismiss;

@end
