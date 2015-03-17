//
//  ALDDataChangedDelegate.h
//  feiyoo
//
//  Created by alidao on 14-6-18.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALDDataChangedDelegate <NSObject>

@required
/**
 * 数据改变委托接口调用方法
 * @param from 数据改变发起者
 * @param source 被改变的源数据
 * @param opt 操作类型，-1：删除，1：新增，2：修改
 **/
-(void) dataChangedFrom:(id) from widthSource:(id) source byOpt:(int) opt;

@end
