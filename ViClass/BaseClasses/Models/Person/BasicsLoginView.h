//
//  LoginView.h
//  BFEC
//
//  Created by alidao on 13-6-5.
//  Copyright (c) 2013年 alidao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicsHttpClient.h"
#import "BaseViewController.h"

@interface BasicsLoginView : UIView<UITextFieldDelegate,DataLoadStateDelegate>{
    CGRect _realFrame;
}

@property (assign,nonatomic) CGFloat contentHeight;
@property (retain,nonatomic) UITextField *userNameText;
@property (retain,nonatomic) UITextField *pwdText;
@property (assign,nonatomic) id<LoginControllerDelegate> delegate;
@property (assign,nonatomic) UIViewController *rootController;
//1.登录 2.绑定
@property (assign,nonatomic) int type;

- (id)initWithFrame:(CGRect)frame withRoot:(UIViewController*)root;

-(void) onLoginClicked;

-(void)hiddenKeyBorad;
-(void)btnPressed:(UIButton *)sender;

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder;
@end
