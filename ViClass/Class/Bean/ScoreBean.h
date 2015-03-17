//
//  ScoreBran.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreBean : NSObject

@property (nonatomic,assign) int score;//获得分数
@property (nonatomic,assign) int integral;//获得积分
@property (nonatomic,assign) int correctCount;//答对题数
@property (nonatomic,assign) Boolean answered;//是否已答题
@end
