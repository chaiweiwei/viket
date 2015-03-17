//
//  NewCheckViewController.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/25.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "BaseViewController.h"

@interface NewCheckViewController : BaseViewController

//0:第一页 1:next
@property (nonatomic,assign) int num;
@property (nonatomic,copy) NSString *chapterId;
@property(nonatomic,retain) NSMutableArray *askArrayM;//答案
@property (nonatomic,retain) NSMutableArray *tableData;

@end
