//
//  CheckViewController.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "BaseViewController.h"

@interface CheckViewController : BaseViewController

@property (nonatomic,copy) NSString *phoneNum;
@property (nonatomic,copy) NSString *passWord;
@property (nonatomic,copy) NSString *userName;

@property (nonatomic,assign) int type;//0注册 1 重置密码
@end
