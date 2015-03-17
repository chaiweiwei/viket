//
//  StartView.h
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartViewDelegate <NSObject>

-(void)btnOKCallBack:(int)score;
-(void)btnCancellCallBack;

@end
@interface StartView : UIView

@property(nonatomic,assign) id<StartViewDelegate> delegate;
-(void)show;

@end
