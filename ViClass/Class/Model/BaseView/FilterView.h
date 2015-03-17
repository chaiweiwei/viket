//
//  FilterView.h
//  life918
//  筛选
//  Created by chaiweiwei on 14/12/4.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilterView;
@protocol FilterViewDelegate <NSObject>

-(void)onItemSelected:(FilterView *)filterView item:(UIButton *)sender;

@end
@interface FilterView : UIView
{
    UIView *_filterView;
    NSArray *_letter;
    CGFloat _selfWidth;
}
@property (nonatomic,assign) id<FilterViewDelegate> delegate;

@end
