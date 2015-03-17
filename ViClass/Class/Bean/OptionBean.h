//
//  OptionBean.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/1.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionBean : NSObject

@property(nonatomic,copy) NSString *sid;//选项ID
@property(nonatomic,copy) NSString *code; //选项编号
@property(nonatomic,copy) NSString *name; //选项名称
@property (nonatomic,assign) Boolean correct;//是否正确
@end
