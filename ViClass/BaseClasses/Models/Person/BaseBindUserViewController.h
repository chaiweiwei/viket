//
//  BaseBindUserViewController.h
//  carlife
//  绑定已有账号
//  Created by alidao on 15/1/21.
//  Copyright (c) 2015年 chen yulong. All rights reserved.
//

#import "BaseViewController.h"
#import "BasicsLoginView.h"

@interface BaseBindUserViewController : BaseViewController<LoginControllerDelegate>

@property (nonatomic,retain) UITextField *nameField;
@property (nonatomic,retain) UITextField *pwdField;

@property (nonatomic,retain) NSString *sid; //第三方平台id
@property (assign,nonatomic) id<LoginControllerDelegate> delegate;

-(void)clickBtn:(UIButton *)sender;

@end
