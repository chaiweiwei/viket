//
//  CommentViewController.h
//  Vike_1018
//
//  Created by chaiweiwei on 14/11/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController

@property (nonatomic,retain) NSNumber *typeId;
@property (nonatomic,retain) UIViewController *parentController;
-(void) setViewShowing:(BOOL) isShow;

@end
