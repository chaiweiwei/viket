//
//  FilterView.m
//  life918
//
//  Created by chaiweiwei on 14/12/4.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "FilterView.h"

@implementation FilterView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self loadData];
        self.backgroundColor = [UIColor blackColor];
        
        CGSize size = self.bounds.size;
        
        CGFloat cellHeight = size.height/4.0;
        CGFloat startY =0;
        int i=0;
        for(NSString *str in _letter)
        {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,(cellHeight*i), frame.size.width, cellHeight)];
            [btn setTitle:str forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self addSubview:btn];
            
            i++;
        }
    }
    return self;
}
-(void) layoutSubviews{
    CGRect frame=self.bounds;
    _selfWidth=frame.size.width;
    _filterView.frame=CGRectMake(0, 0, frame.size.width,frame.size.height);
    [super layoutSubviews];
}

-(void)loadData
{
    _letter = [NSArray arrayWithObjects:@"简介",@"课程",@"练习",@"评论", nil];
}

- (void)dealloc
{
    ALDRelease(_tableView);
    ALDRelease(_letters);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end
