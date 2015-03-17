//
//  BoothBean.h
//  carlife
//
//  Created by chaiweiwei on 15/1/21.
//  Copyright (c) 2015年 chen yulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoothBean : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,retain) UIColor *color;
@property (nonatomic,assign) BOOL selecttag;//选中标记
@end
