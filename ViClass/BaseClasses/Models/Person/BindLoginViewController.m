//
//  BindViewController.m
//  Basics
//  第三方登录绑定app账号
//  Created by alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BindLoginViewController.h"
#import "BasicsLoginView.h"
#import "ALDButton.h"

#import "BasicsRegisterViewController.h"

@interface BindLoginViewController ()<LoginControllerDelegate>

@end

@implementation BindLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)initUI
{
    CGFloat startY=self.baseStartY;
    CGRect viewFrame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(viewFrame);
    CGFloat viewHeigh=CGRectGetHeight(viewFrame);
    CGRect frame=CGRectMake(0, startY, viewWidth, viewHeigh-startY);
    BasicsLoginView *loginView=[[BasicsLoginView alloc] initWithFrame:frame withRoot:self];
    loginView.type=2;
    loginView.delegate=self;
    loginView.backgroundColor=[UIColor clearColor];
    loginView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:loginView];
    
    startY+=loginView.contentHeight+20;
    //忘记密码
    CGRect btnFrame=CGRectMake(250, startY, 60, 15);
    ALDButton *forgetPwdBtn=[[ALDButton alloc] initWithFrame:btnFrame];
    [forgetPwdBtn setTitle:@"找回密码?" forState:UIControlStateNormal];
    [forgetPwdBtn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
    forgetPwdBtn.titleLabel.font=[UIFont boldSystemFontOfSize:15.0f];
    forgetPwdBtn.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    forgetPwdBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    [forgetPwdBtn setBackgroundColor:[UIColor clearColor]];
    forgetPwdBtn.tag=0x11;
    [forgetPwdBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetPwdBtn];
    CGSize size=[ALDUtils captureTextSizeWithText:[forgetPwdBtn titleForState:UIControlStateNormal] textWidth:2000.f font:forgetPwdBtn.titleLabel.font];
    CGFloat startX=CGRectGetWidth(viewFrame)-10-size.width;
    btnFrame.origin.x=startX;
    btnFrame.size.width=size.width;
    forgetPwdBtn.frame=btnFrame;
    
    startY+=btnFrame.size.height;
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(startX-2, startY, size.width+2, 1)];
    lineView.backgroundColor=KWordBlackColor;
    [self.view addSubview:lineView];

}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //找回密码
            BasicsRegisterViewController *controller=[[BasicsRegisterViewController alloc] init];
            controller.title=@"找回密码";
            controller.type=2;
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem=backItem;
            [self.navigationController pushViewController:controller animated:YES];

        }
            break;
            
        default:
            break;
    }
}

-(void) loginView:(BasicsLoginView *)loginView doneWithCode:(int)code withUser:(id)user{
    if (code==KOK) {
        [self.parentViewController dismissViewControllerAnimated:YES completion:^{
            NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
            NSString *uid=[config stringForKey:kUidKey];
            if(uid && ![uid isEqualToString:@""]){
                [config setObject:@"true" forKey:kNeedSendTokenKey];
                [config synchronize];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
