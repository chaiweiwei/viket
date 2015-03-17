//
//  AddressBean.h
//  FunCat
//  地址数据bean
//  Created by chen yulong on 14-10-11.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBean : NSObject
/** 地址id(long) **/
@property (retain,nonatomic) NSString *sid;
/** 省 **/
@property (retain,nonatomic) NSString *province;
/** 市 **/
@property (retain,nonatomic) NSString *city;
/** 区 **/
@property (retain,nonatomic) NSString *area;
/** 详细地址 **/
@property (retain,nonatomic) NSString *detail;
/** 经度 **/
@property (retain,nonatomic) NSString *lng;
/** 维度 **/
@property (retain,nonatomic) NSString *lat;
/** 邮编 **/
@property (retain,nonatomic) NSString *postcode;

@end
