//
//  DetailViewController.h
//  Vike_1018
//
//  Created by chaiweiwei on 14/11/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChapterBean.h"

@protocol DetailViewDelegate <NSObject>

-(void)courseChange:(ChapterBean *)selectedCourse;

@end

@interface DetailViewController : UIViewController

@property (nonatomic,retain) NSNumber *typeId;
@property (nonatomic,assign) int classId;
@property (nonatomic,retain) UIViewController *parentController;
@property (nonatomic,assign) id<DetailViewDelegate> delegate;
@property (nonatomic,strong) UITableView *myTableView; //表格
-(void) setViewShowing:(BOOL) isShow;



@end
