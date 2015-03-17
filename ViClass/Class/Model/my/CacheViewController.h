//
//  CacheViewController.h
//  ViKeTang
//  课件缓存
//  Created by chaiweiwei on 15/1/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "BaseViewController.h"
#import "ClassRoomBean.h"

@interface CacheViewController : BaseViewController
/**
 *  1:文件夹缓存 2：个体缓存  3.课件缓存
 */
@property(nonatomic,assign) int type;
@property(nonatomic,retain) NSString *sid;

@end
