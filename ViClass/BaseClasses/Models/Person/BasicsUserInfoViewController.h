//
//  UserInfoViewController.h
//  Glory
//  完善信息/个人信息
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDDataChangedDelegate.h"
#import "UserBean.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "BasicsHttpClient.h"
#import "UserDao.h"

@interface BasicsUserInfoViewController : BaseViewController<UITextFieldDelegate>
{
    BOOL backClicked;
    NSArray *incomeArray; //收入数组
    UIView *View;
    UIView *view2;
    NSArray *sexArray; //性别数组
}

@property (retain,nonatomic) UIScrollView *scrollView;
@property (retain,nonatomic) ALDImageView *headImgView;
@property (retain,nonatomic) UITextField *nameField; //姓名
@property (retain,nonatomic) UITextField *sexField; //性别
@property (retain,nonatomic) UITextField *positionField; //职业
@property (retain,nonatomic) UITextField *birthdayField; //生日
@property (retain,nonatomic) UITextField *incomeField; //收入
@property (retain,nonatomic) UITextField *hobbyField; //爱好
@property (retain,nonatomic) UITextField *addressField; //所在地
@property (retain,nonatomic) UITextField *currenField;
@property (retain,nonatomic) UIDatePicker *datePickerView;
@property (retain,nonatomic) ALDButton *mobileBtn;

@property (nonatomic) BOOL needUploadHead;
@property (retain,nonatomic) NSString *avatar;
@property (retain,nonatomic) UserBean *userBean;
@property (retain,nonatomic) NSString *openApiAvatar; //第三方平台头像
@property (retain,nonatomic) NSString *openApiNickName; //第三方平台昵称


/** 是否修改用户信息 **/
@property (assign,nonatomic) BOOL isEditInfo;
/** 是否可跳过 **/
@property (assign,nonatomic) BOOL cannotToNext;

@property (assign,nonatomic) id<ALDDataChangedDelegate> dataChangeDelegate;
@property (assign,nonatomic) id<LoginControllerDelegate> loginDelegate;

-(void)datePickClick:(ALDButton *)sender;

-(void)hiddenKeyBorad;
-(void)updateHeadImg:(ALDImageView *)sender;

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder;

@end
