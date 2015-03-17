//
//  StartViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/2.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "StartViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@implementation StartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //隐藏导航栏
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}
//绘制
-(void)initUI
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"startBg"]];
    
    CGRect frame = self.view.frame;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame)-300)/2.0, 270, 300, 53)];
    [btn setBackgroundColor:RGBACOLOR(24, 142, 112, 1)];
    [btn setTitle:@"登陆" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.titleLabel.font = KFontSizeBold32px;
    btn.tag = 1;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame)-300)/2.0, 270+53+10, 300, 53)];
    [btn setBackgroundColor:RGBACOLOR(244, 124, 40, 1)];
    [btn setTitle:@"注册" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.titleLabel.font = KFontSizeBold32px;
    btn.tag = 2;
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
-(void)clicked:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {
            LoginViewController *controller = [[LoginViewController alloc] init];
            controller.title = @"登陆";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 2:
        {
            RegisterViewController *controller = [[RegisterViewController alloc] init];
            controller.title = @"注册";
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
