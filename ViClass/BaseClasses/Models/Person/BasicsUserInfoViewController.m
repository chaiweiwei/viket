//
//  UserInfoViewController.m
//  Glory
//  完善信息/个人信息
//  Created by alidao on 14-7-17.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BasicsUserInfoViewController.h"
#import "ALDChoiseAlertView.h"
#import "AttachmentBean.h"

@interface BasicsUserInfoViewController ()<UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,DataLoadStateDelegate,UIAlertViewDelegate,ALDChoiseAlertViewDelegate>

@end

@implementation BasicsUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.hidesBottomBarWhenPushed){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCustomTabBar" object:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame=self.view.bounds;
    UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    bgView.backgroundColor=KBgViewColor;
    [self.view addSubview:bgView];
    
    
    if(!self.title || [self.title isEqualToString:@""]){
        if (self.isEditInfo) {
            self.title=@"修改信息";
        }else{
            self.title=@"完善信息";
        }
    }
    backClicked=NO;
    sexArray=[NSArray arrayWithObjects:@"男",@"女", nil];
    incomeArray=[NSArray arrayWithObjects:@"1000或以下",@"1001~2000",@"2001~3500",@"3501~5000",@"5001~10000",@"10000以上", nil];
    
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 40, 40);
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor clearColor];
    btn.selectBgColor=[UIColor clearColor];
    btn.tag=0x11;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem=rightBtnItem;
    
    [self initUI];
    
    if (self.isEditInfo){
        [self loadData];
    }else if(!self.isEditInfo && self.cannotToNext){
        btn=[ALDButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 0, 40, 40);
        [btn setTitle:@"跳过" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor=[UIColor redColor];
        btn.tag=0x10;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem=leftBtnItem;
    }
    
    //监听键盘高度的变换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}

-(void)loadData
{
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient viewUserInfo:nil];
}

-(void)initUI
{
    CGRect frame=self.view.frame;
    CGFloat startX=0.0f;
    CGFloat startY=0;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    CGFloat width=CGRectGetWidth(frame)-10;
    CGFloat heigh=44.0f;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,viewWidth, 30)];
    [topView setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:ALDLocalizedString(@"Cancel keyboard", @"关闭键盘") style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyBorad)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, startY, CGRectGetWidth(frame), 0)];
    scrollView.delegate=self;
    scrollView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:scrollView];
    self.scrollView=scrollView;
    
    CGFloat y=self.baseStartY+10;
    UIView *line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //头像
    UILabel *label=[self createLabel:CGRectMake(10.0f, y+27.0f, 60.0f, 20.0f) textColor:KWordBlackColor textFont:[UIFont systemFontOfSize:17.0f]];
    label.text=@"头像:";
    label.textAlignment=TEXT_ALIGN_LEFT;
    label.backgroundColor=[UIColor clearColor];
    [scrollView addSubview:label];
    
    UIImage *image=[UIImage imageNamed:@"img_morenuserface_gai"];
    CGSize imgSize=CGSizeMake(image.size.width/2+10, image.size.height/2+10);
    ALDImageView *imgView=[[ALDImageView alloc] initWithFrame:CGRectMake(viewWidth-imgSize.width-10, y+9.0f, imgSize.width, imgSize.height)];
    imgView.defaultImage=image;
    imgView.autoResize=NO;
    imgView.fitImageToSize=NO;
    imgView.layer.masksToBounds=YES;
    imgView.layer.cornerRadius=imgSize.width/2;
    imgView.layer.borderColor=[UIColor whiteColor].CGColor;
    imgView.layer.borderWidth=5.0f;
    imgView.clickAble=YES;
    [imgView addTarget:self action:@selector(updateHeadImg:) forControlEvents:UIControlEventTouchUpInside];
    imgView.backgroundColor=[UIColor redColor];
    [scrollView addSubview:imgView];
    self.headImgView=imgView;
    y+=70.0f;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //昵称
    UITextField *textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"昵称:" placeholder:@"请输入您的昵称"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.nameField=textField;
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //性别
    textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"性别:" placeholder:@"请选择您的性别"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.sexField=textField;
    
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, y, viewWidth, heigh);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=0x12;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    
    y+=heigh;

    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //生日
    textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"生日:" placeholder:@"请选择您的生日"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.birthdayField=textField;
    //选择生日
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, y, viewWidth, heigh);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=0x13;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //职业
    textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"职业:" placeholder:@"请填写您的职业"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.positionField=textField;
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //收入
    textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"收入:" placeholder:@"请选择您的收入"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.incomeField=textField;
    
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, y, viewWidth, heigh);
    btn.backgroundColor=[UIColor clearColor];
    btn.tag=0x14;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:btn];
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //爱好
    textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"爱好:" placeholder:@"请填写您的爱好"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.hobbyField=textField;
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;

    //所在地区(目前所在地保存在省份中)
    textField=[self createTextfield:CGRectMake(startX, y, width, heigh) title:@"所在地:" placeholder:@"请输入您的地址"];
    textField.returnKeyType=UIReturnKeyNext;
    textField.inputAccessoryView=topView;
    [scrollView addSubview:textField];
    self.addressField=textField;
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //灰色背景视图
    UIView *bgView=[[UIView alloc] initWithFrame:CGRectMake(startX, y, viewWidth, 10.0f)];
    bgView.backgroundColor=KBgViewColor;
    [scrollView addSubview:bgView];
    y+=10.0f;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;
    
    //手机
    label=[self createLabel:CGRectMake(10, y, 80, heigh) textColor:KWordBlackColor textFont:[UIFont systemFontOfSize:17.0f]];
    label.text=@"手机";
    [scrollView addSubview:label];
    
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(90, y, viewWidth-100, heigh);
    [btn setTitle:@"绑定手机" forState:UIControlStateNormal];
    [btn setTitleColor:RGBCOLOR(255, 136, 44) forState:UIControlStateNormal];
    btn.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    btn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    btn.tag=0x15;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor=[UIColor whiteColor];
    [scrollView addSubview:btn];
    self.mobileBtn=btn;
    y+=heigh;
    
    line=[self createLine:CGRectMake(startX, y, viewWidth, 1.0f)];
    [scrollView addSubview:line];
    y+=1.0f;

    
    CGRect scrollFrame=scrollView.frame;
    if(isIOS7){
        
    }else{
        viewHeigh-=44.0f;
    }
    if(y>viewHeigh){
        scrollFrame.size.height=viewHeigh;
        scrollView.contentSize=CGSizeMake(0, y);
    }else{
        scrollFrame.size.height=y;
    }
    scrollView.frame=scrollFrame;
    
}

-(void) updateData:(UserBean*) bean{
    //头像
    NSString *text=bean.userInfo.avatar;
    self.avatar=text;
    self.headImgView.imageUrl=text;
    
    //昵称
    text=bean.userInfo.nickname;
    self.nameField.text=text;
    
    //性别
    text=bean.userInfo.gender;
    self.sexField.text=text;
    
    //生日
    text=bean.userInfo.birthday;
    self.birthdayField.text=text;
    
    //职业
    text=bean.userInfo.position;
    self.positionField.text=text;
    
    //收入
    text=bean.userInfo.revenue;
    self.incomeField.text=text;
    
    //爱好
    text=bean.userInfo.interest;
    self.hobbyField.text=text;
    
    //所在地区(目前所在地保存在省份中)
    text=bean.userInfo.address;
    self.addressField.text=text;
    
    //手机
    text=bean.mobile;
    if (text && ![text isEqualToString:@""]) {
        self.mobileBtn.userInteractionEnabled=NO;
        [self.mobileBtn setTitle:text forState:UIControlStateNormal];
    }else{
        self.mobileBtn.userInteractionEnabled=YES;
    }
    
}

-(void)submitUserInfo{
    if (!self.userBean) {
        self.userBean=[[UserBean alloc] init];
    }
    UserInfoBean *userInfo=self.userBean.userInfo;
    if (!userInfo) {
        userInfo=[[UserInfoBean alloc] init];
        self.userBean.userInfo=userInfo;
    }
    if(self.avatar && ![self.avatar isEqualToString:@""]){
        userInfo.avatar=self.avatar;
    }
    NSString *text=self.nameField.text;
    if(!text || [text isEqualToString:@""]){
        [ALDUtils showToast:@"请输入您的昵称!"];
        return;
    }
    userInfo.nickname=text;
    
    text=self.sexField.text;
//    if(!text || [text isEqualToString:@""]){
//        [ALDUtils showToast:@"请选择您的性别!"];
//        return;
//    }
    userInfo.gender=text;
    
    text=self.birthdayField.text;
//    if(!text || [text isEqualToString:@""]){
//        [ALDUtils showToast:@"请选择您的生日!"];
//        return;
//    }
    userInfo.birthday=text;
   
    //职业
    text=self.positionField.text;
    userInfo.position=text;
    
    //收入
    text=self.incomeField.text;
    userInfo.revenue=text;
    
    //爱好
    text=self.hobbyField.text;
    userInfo.interest=text;
    
    //所在地
//    text=self.addressField.text;
//    if(text && ![text isEqualToString:@""]){
//        AddressBean *addressBean=[[AddressBean alloc] init];
//        addressBean.province=text;
//        bean.address=addressBean;
//    }
    
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    [httpClient modifyUserInfo:userInfo username:nil email:nil extra:nil];
}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x10:{ //直接跳过
            if (_loginDelegate && [_loginDelegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
                NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
                [_loginDelegate loginView:self doneWithCode:KOK withUser:uid];
            }
        }
            break;
        case 0x11:{ //完成提交用户信息
            [self hiddenKeyBorad];
            [self submitUserInfo];
        }
            break;
            
        case 0x12:{ //性别选择
            ALDChoiseAlertView *view=[[ALDChoiseAlertView alloc] initWithTitle:@"请选择性别" delegate:self cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
            NSMutableArray *data=[NSMutableArray arrayWithArray:sexArray];
            view.choiseType=ALDChoiseTypeRadio;
            view.tag=0x103;
            view.data=data;
            view.selectedIdx=0;
            [view showToView:self.view];
        }
            break;
            
        case 0x13:{ //生日日期选择
            if(!self.datePickerView){
                CGRect frame=self.view.frame;
                CGFloat viewWidth=CGRectGetWidth(frame);
                CGFloat viewHeigh=CGRectGetHeight(frame);
                UIDatePicker *datePickerView                = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, viewHeigh-193, viewWidth, 162)];
                datePickerView.backgroundColor=RGBCOLOR(246, 246, 246);
                datePickerView.datePickerMode = UIDatePickerModeDate;
                [self.view addSubview:datePickerView];
                self.datePickerView=datePickerView;
                
                View                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh-210)];
                View.backgroundColor = KBgViewColor;
                View.alpha           = 0.4;
                [self.view addSubview:View];
                
                CGFloat startY=viewHeigh-210;
                view2                = [[UIView alloc] initWithFrame:CGRectMake(0, startY, viewWidth, 40)];
                view2.backgroundColor=[UIColor whiteColor];
                [self.view addSubview:view2];
                
                ALDButton *doneBtn=[[ALDButton alloc] initWithFrame:CGRectMake(viewWidth-90, 0, 90, 40)];
                doneBtn.backgroundColor=[UIColor clearColor];
                [doneBtn setTitle:@"确定" forState:UIControlStateNormal];
                [doneBtn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
                doneBtn.titleLabel.font          = [UIFont systemFontOfSize:17.0f];
                doneBtn.titleLabel.textAlignment = TEXT_ALIGN_CENTER;
                doneBtn.tag                      = 0x11;
                [doneBtn addTarget:self action:@selector(datePickClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:doneBtn];
                
                ALDButton *cancelBtn=[[ALDButton alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
                cancelBtn.backgroundColor=[UIColor clearColor];
                [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                [cancelBtn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
                cancelBtn.titleLabel.font          = [UIFont systemFontOfSize:17.0f];
                cancelBtn.titleLabel.textAlignment = TEXT_ALIGN_CENTER;
                cancelBtn.tag                      = 0x12;
                [cancelBtn addTarget:self action:@selector(datePickClick:) forControlEvents:UIControlEventTouchUpInside];
                [view2 addSubview:cancelBtn];
            }else{
                View.hidden=NO;
                self.datePickerView.hidden=NO;
                view2.hidden=NO;
            }
        }
            break;
            
        case 0x14:{ //收入
            ALDChoiseAlertView *view=[[ALDChoiseAlertView alloc] initWithTitle:@"请选择收入" delegate:self cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
            NSMutableArray *data=[NSMutableArray arrayWithArray:incomeArray];
            view.choiseType=ALDChoiseTypeRadio;
            view.tag=0x104;
            view.data=data;
            view.selectedIdx=0;
            [view showToView:self.view];
        }
            break;
            
        case 0x15:{  //绑定手机
            [ALDUtils showToast:@"绑定手机开发中！"];
        }
            
        default:
            break;
    }
}

-(void)datePickClick:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11: { //确定
            View.hidden            = YES;
            view2.hidden           = YES;
            _datePickerView.hidden = YES;
            
            NSDate *select=[_datePickerView date];
            if(select){
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString *text=[dateFormatter stringFromDate:select];
                self.birthdayField.text=text;
            }
        }
            break;
            
        case 0x12: { //取消
            
            View.hidden            = YES;
            view2.hidden           = YES;
            self.datePickerView.hidden = YES;
        }
            break;
            
        default:
            break;
    }

}

-(void) alertView:(ALDChoiseAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 0x110:{
            //            ALDAppDelegate *appDelegate=(ALDAppDelegate *)[UIApplication sharedApplication].delegate;
            //            [appDelegate login];
        }
            break;
            
        case 0x111:{
            if(buttonIndex==1){
                //重新绑定手机
            }
        }
            break;
            
        case 0x103:{
            if (buttonIndex==1) {
                NSInteger index = alertView.selectedIdx;
                NSString *text = [sexArray objectAtIndex:index];
                self.sexField.text=text;
            }

        }
            break;
            
        case 0x104:{
            if (buttonIndex==1) {
                NSInteger index = alertView.selectedIdx;
                NSString *text = [incomeArray objectAtIndex:index];
                self.incomeField.text=text;
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currenField=textField;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hiddenKeyBorad];
}


#pragma mark -
#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration ;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [self autoMovekeyBoard:keyboardRect.size.height];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [self autoMovekeyBoard:0];
    [UIView commitAnimations];
}

-(void) autoMovekeyBoard: (float) h{
    CGRect frame=self.view.frame;
    CGFloat startY=0;
    CGFloat offset = 0.f;
    if(!isIOS7){
        startY=64.0f;
    }
    if (h<=0) {
        offset=startY;
    }else{
        offset = (self.baseStartY+10)+_currenField.frame.origin.y+_currenField.frame.size.height+h-frame.size.height;
        if(offset<0){
            offset = startY;
        }
    }
    self.scrollView.contentOffset = CGPointMake(0, offset);
}

#pragma mark - Responding to keyboard events end

-(void)hiddenKeyBorad{
    [self.nameField resignFirstResponder];
    [self.sexField resignFirstResponder];
    [self.positionField resignFirstResponder];
    [self.hobbyField resignFirstResponder];
    [self.incomeField resignFirstResponder];
    [self.birthdayField resignFirstResponder];
    [self.addressField resignFirstResponder];
}

-(UILabel *)createLabel:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}

-(UITextField *) createTextfield:(CGRect)frame title:(NSString*)title placeholder:(NSString*)placeholder{
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, frame.size.height)];
    leftView.backgroundColor=[UIColor clearColor];
    UILabel *labletitle=[[UILabel alloc]initWithFrame:CGRectMake(10,0,80,frame.size.height)];
    labletitle.font=[UIFont systemFontOfSize:17.0f];
    labletitle.text=title;
    labletitle.textAlignment=TEXT_ALIGN_LEFT;
    labletitle.numberOfLines=1;
    labletitle.adjustsFontSizeToFitWidth=YES;
    labletitle.textColor=KWordBlackColor;
    labletitle.backgroundColor=[UIColor clearColor];
    [leftView addSubview:labletitle];
    
    UITextField *textfield = [[UITextField alloc] initWithFrame:frame];
    [textfield setBorderStyle:UITextBorderStyleNone]; //外框类型
    textfield.placeholder = placeholder; //默认显示的字
    textfield.textAlignment=TEXT_ALIGN_Right;
    textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textfield.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    textfield.font=[UIFont systemFontOfSize:17];
    textfield.textColor=KWordBlackColor;
    textfield.keyboardType=UIKeyboardTypeDefault;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing; //编辑时会出现个修改X
    textfield.delegate = self;
    textfield.backgroundColor=[UIColor clearColor];
    textfield.leftView=leftView;
    textfield.leftViewMode=UITextFieldViewModeAlways;
    
    return textfield;
}

-(void) onBackClicked{
    if (backClicked) {
        return;
    }
    backClicked=YES;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma take/check a photo
//处理分享、拨号
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"btn = %d", buttonIndex);
    NSInteger tag=actionSheet.tag;
    if (tag == 0x301) {
        if (buttonIndex == 0) {//拍照
            [self takePhoto];
        }else if(buttonIndex == 1) {//用户相册
            [self LocalPhoto];
        }
    }
}

-(void)updateHeadImg:(UITapGestureRecognizer *)gestrue
{
    [self hiddenKeyBorad];
    
    NSArray *buttons=[NSArray arrayWithObjects:ALDLocalizedString(@"Camera", @"拍照"),ALDLocalizedString(@"Photos",@"用户相册"), nil];
    [ALDUtils showActionSheetWithTitle:@"" delegate:self controller:self buttons:buttons tag:0x301];
}

//开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
        ALDRelease(picker);
    }else {
        [ALDUtils showToast:ALDLocalizedString(@"Your device does not support this feature!", @"抱歉，您的设备不支持该功能!")];
    }
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
    ALDRelease(picker);
}

-(NSString *) saveImage:(UIImage*) image{
    NSData *data;
    if (UIImagePNGRepresentation(image) == nil)
    {
        data = UIImageJPEGRepresentation(image, 1.0);
    }else {
        data = UIImagePNGRepresentation(image);
    }
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [NSString stringWithFormat:@"%@%@",DocumentsPath, @"/image.png"];
    return filePath;
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSLog(@"info:%@",info);
    //当选择的类型是图片
    if ([mediaType isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSURL *imgUrl=[info objectForKey:@"UIImagePickerControllerReferenceURL"];
        if (imgUrl && [imgUrl.absoluteString hasSuffix:@"=PNG"]) {
            image.imageType=@"png";
        }else{
            image.imageType=@"jpg";
        }
        NSString *imgPath=[ALDUtils saveImage:image quality:0.75];
        image=[UIImage imageWithContentsOfFile:imgPath];

        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        //创建一个选择后图片的小图标放在下方
        
        self.headImgView.image = image;
        self.view.userInteractionEnabled=NO;
        [self performSelectorInBackground:@selector(uploadHead:) withObject:image];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel select photo");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) uploadHead:(UIImage*) image{
    image = [self scaleFromImage:image]; //图像压缩,最好在异步线程中执行
    //上传头像
    BasicsHttpClient *http=[BasicsHttpClient httpClientWithDelegate:self];
    http.needTipsNetError=YES;
    
    NSString *imageType=image.imageType;
    if (!imageType) {
        imageType=@"jpg";
    }
    MediaBean *bean=[[MediaBean alloc] init];
    bean.fileName=[NSString stringWithFormat:@"upload.%@",imageType];
    bean.type=kFileTypeOfImage;
   
    if ([imageType isEqualToString:@"png"]) {
        bean.contentType=@"image/png";
        bean.data = UIImagePNGRepresentation(image);
    }else{
        bean.contentType=@"image/jpeg";
        bean.data=UIImageJPEGRepresentation(image, 1);
    }
    NSInteger width=image.size.width;
    NSInteger height=image.size.height;
    bean.width=[NSNumber numberWithInteger:width];
    bean.height=[NSNumber numberWithInteger:height];
    [http uploadFile:bean path:@"userInfo" thumbSize:@"98x98"];
}

-(UIImage *) scaleFromImage: (UIImage *) image
{
    if (!image) {
        return nil;
    }
    CGFloat width  = image.size.width;
    CGFloat height = image.size.height;
    NSData *data= UIImagePNGRepresentation(image);
    CGFloat dataSize=data.length/1024;
    CGSize size;
    if (dataSize<=50) { //小于50k
        return image;
    }else if (dataSize<=100) { //小于100k
        size = CGSizeMake(width/2.f, height/2.f);
    }else if (dataSize<=200) { //小于200k
        size = CGSizeMake(width/4.f, height/4.f);
    }else if (dataSize<=500) { //小于500k
        size = CGSizeMake(width/4.f, height/4.f);
    }else if (dataSize<=1000) { //小于1M
        size = CGSizeMake(width/6.f, height/6.f);
    }else if (dataSize<=2000) { //小于2M
        size = CGSizeMake(width/10.f, height/10.f);
    }else { //大于2M
        size = CGSizeMake(width/12.f, height/12.f);
    }
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!newImage) {
        return image;
    }
    newImage.imageType=image.imageType;
    return newImage;
}

-(void) addWaitView{
    [ALDUtils addWaitingView:self.view withText:@"正在上传头像，请稍候..."];
}

-(void) modifyAvator:(NSString*) avatorUrl{
    [self performSelectorOnMainThread:@selector(addWaitView) withObject:nil waitUntilDone:YES];
}

-(UIView *)createLine:(CGRect )frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForUploadFile){
        [ALDUtils addWaitingView:self.view withText:@"头像上传中，请稍候..."];
    }else if(requestPath==HttpRequestPathForModifyUserInfo){
        [ALDUtils addWaitingView:self.view withText:@"正在提交,请稍候..."];
    }else if(requestPath==HttpRequestPathForUserInfo){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    if(requestPath==HttpRequestPathForUploadFile){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[AttachmentBean class]]){
                AttachmentBean *attBean=(AttachmentBean *)obj;
                NSString *thumbUrl=attBean.thumbnail;
                if (!thumbUrl || [thumbUrl isEqualToString:@""]) {
                    thumbUrl=attBean.url;
                }
                self.avatar=thumbUrl;
            }
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:self.view withText:ALDLocalizedString(@"netError", @"网络异常，请确认是否已连接!")];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"上传头像失败!";
            }
            [ALDUtils showToast:errMsg];
        }
        self.view.userInteractionEnabled=YES;
    }else if(requestPath==HttpRequestPathForModifyUserInfo){
        if(code==KOK){ //修改用户信息成功
            [ALDUtils showToast:@"修改用户信息成功!"];
            
            NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
            [config setInteger:1 forKey:KUserStatus];
            [config synchronize];
            
            UserDao *dao=[[UserDao alloc] init];
            [dao addUser:self.userBean];
            
            if (self.isEditInfo) {
                NSDictionary *dic=[NSDictionary dictionaryWithObject:self.userBean forKey:@"data"];
                [[NSNotificationCenter defaultCenter] postNotificationName:KUpdateUserInfoKey object:nil userInfo:dic];
                if(_dataChangeDelegate && [_dataChangeDelegate respondsToSelector:@selector(dataChangedFrom:widthSource:byOpt:)]){
                    [_dataChangeDelegate dataChangedFrom:self widthSource:self.userBean byOpt:2];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                if (_loginDelegate && [_loginDelegate respondsToSelector:@selector(loginView:doneWithCode:withUser:)]) {
                    NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
                    [_loginDelegate loginView:self doneWithCode:KOK withUser:uid];
                }
            }
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:self.view withText:ALDLocalizedString(@"netError", @"网络异常，请确认是否已连接!")];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"修改用户信息失败!";
            }
            [ALDUtils showToast:errMsg];
        }

    }else{
        if(requestPath==HttpRequestPathForUserInfo){
            NSString *errMsg=result.errorMsg;
            if(code==KOK){
                UserBean *bean=(UserBean *)result.obj;
                UserDao *dao=[[UserDao alloc] init];
                [dao addUser:bean];
                
                self.userBean=bean;
                self.avatar=bean.userInfo.avatar;
            }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
                errMsg=ALDLocalizedString(@"net error", @"连接失败,请检查网络!");
            }else{
                if([errMsg isEqualToString:@""]){
                    errMsg=@"获取用户信息失败!";
                }
            }
            if (!self.userBean) {
                UserDao *dao=[[UserDao alloc] init];
                NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
                self.userBean=[dao queryUser:uid];
            }
            if (code!=KOK) {
                [ALDUtils showToast:errMsg];
            }
            if (self.userBean) {
                [self updateData:self.userBean];
            }
        }
    }
    [ALDUtils removeWaitingView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidUnload{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc
{
    self.scrollView=nil;
    self.headImgView=nil;
    self.nameField=nil;
    self.sexField=nil;
    self.positionField=nil;
    self.birthdayField=nil;
    self.incomeField=nil;
    self.hobbyField=nil;
    self.addressField=nil;
    self.currenField=nil;
    self.datePickerView=nil;
    self.mobileBtn=nil;
    self.avatar=nil;
    self.userBean=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
