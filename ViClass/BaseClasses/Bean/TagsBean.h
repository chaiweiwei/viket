//
//  TagsBean.h
//  Zenithzone
//  标签Bean
//  Created by alidao on 14-11-6.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsBean : NSObject

/** id **/
@property (nonatomic,retain) NSString *sid;
/** 标题 **/
@property (nonatomic,retain) NSString *name;

@property (nonatomic) BOOL isSelected;

@end
