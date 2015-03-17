//
//  ButtonView.h
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/16.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ButtonDelegate <NSObject>

-(void)btnCickedDelegate:(UIButton *)button;

@end
@interface ButtonView : UIView
{
}
@property (nonatomic,retain) NSArray *array;
@property (nonatomic,assign) id<ButtonDelegate> delegate;
@end
