//
//  MyInfomationViewController.m
//  WeTalk
//  个人资料
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "MyInfomationViewController.h"
#import "ALDButton.h"
#import "ALDImageView.h"
#import "UIViewExt.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "HttpClient.h"
#import "UserBean.h"
#import "ALDPopupView.h"

#define TAG_LABEL_NAME   0x0100
#define TAG_LABEL_MOBILE  0x0101
#define TAG_LABEL_OCCO    0x0102
#define TAG_LABEL_RIGHT   0x0103
@interface MyInfomationViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UITextFieldDelegate,PopupViewDelegate>
{
    UIScrollView *scroller;
    ALDImageView *icon;
    NSString *avatar;
    UIPageControl *pageController;
    UITextField *nameTextField;
    UIButton *tagBtn;
    UIButton *submitBtn;
    CGRect startRect;
}
@property (nonatomic,retain) ALDPopupView *popupView;
@property (nonatomic,retain) NSArray *popuItems;
@property (nonatomic,retain) UserBean *ub;
@end
@implementation MyInfomationViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient viewUserInfo:uid];
}
-(void)initUI
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"startBg"]];
    
    CGFloat startX = 0;
    CGFloat starty = 0;
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(startX, starty, viewWidth,viewHeight)];
    scroller.backgroundColor = [UIColor clearColor];
    scroller.delegate = self;
    scroller.contentSize = CGSizeMake(viewWidth*3, viewHeight);
    scroller.pagingEnabled = YES;
    scroller.userInteractionEnabled = YES;
    [self.view addSubview:scroller];
    
    pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(0, viewHeight-100, viewWidth, 30)];
    pageController.numberOfPages = 3;
    pageController.currentPageIndicatorTintColor = [UIColor blackColor];
    pageController.pageIndicatorTintColor = [UIColor whiteColor];
    [self.view addSubview:pageController];
    
    //头像
    ALDImageView *logo = [[ALDImageView alloc] initWithFrame:CGRectMake((viewWidth-80)/2.0, 80, 80, 80)];
    logo.layer.cornerRadius = 40;
    logo.layer.masksToBounds = YES;
    logo.defaultImage = [UIImage imageNamed:@"user_default"];
    logo.imageUrl = _ub.userInfo.avatar;
    icon = logo;
    [scroller addSubview:logo];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((viewWidth-100)/2.0, 200, 100, 45)];
    [btn setBackgroundColor:RGBACOLOR(24, 142, 112, 1)];
    [btn setTitle:@"上传头像" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.titleLabel.font = KFontSizeBold32px;
    btn.tag = 1;
    [btn addTarget:self action:@selector(theNext:) forControlEvents:UIControlEventTouchUpInside];
    [scroller addSubview:btn];
    
    //透明大按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =  CGRectMake(viewWidth, 0, viewWidth, viewHeight);
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(exitBtn) forControlEvents:UIControlEventTouchUpInside];
    [scroller addSubview:button];
    
    //昵称
    CGSize size = [ALDUtils captureTextSizeWithText:@"昵  称" textWidth:200 font:KFontSizeBold32px];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth + 50, 80, size.width,  35)];
    if(viewWidth == 414)
        name.frame = CGRectMake(viewWidth + 100, 80, size.width,  35);
    
    name.text = @"昵  称";
    name.textAlignment = TEXT_ALIGN_CENTER;
    name.font = KFontSizeBold32px;
    name.textColor = [UIColor whiteColor];
    name.backgroundColor = [UIColor clearColor];
    [scroller addSubview:name];
    
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame)+10, 80, 150, 35)];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.layer.masksToBounds = YES;
    nameTextField.layer.borderWidth = 1;
    nameTextField.layer.cornerRadius = 5;
    nameTextField.textColor = [UIColor whiteColor];
    nameTextField.text = _ub.userInfo.nickname;
    [nameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    nameTextField.delegate = self;
    nameTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 35)];
    view.backgroundColor = [UIColor clearColor];
    nameTextField.leftView = view;
    nameTextField.leftViewMode = UITextFieldViewModeAlways;
    [scroller addSubview:nameTextField];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth + (viewWidth-100)/2.0, 200, 100, 45)];
    [btn setBackgroundColor:RGBACOLOR(24, 142, 112, 1)];
    [btn setTitle:@"下一步" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.titleLabel.font = KFontSizeBold32px;
    btn.tag = 2;
    [btn addTarget:self action:@selector(theNext:) forControlEvents:UIControlEventTouchUpInside];
    [scroller addSubview:btn];
    
    //身份
    BoothBean *bean1 = [[BoothBean alloc] init];
    bean1.title = @"在读学生";
    bean1.color = [UIColor whiteColor];
    
    BoothBean *bean2 = [[BoothBean alloc] init];
    bean2.title = @"在职员工";
    bean2.color = [UIColor whiteColor];
    
    BoothBean *bean3 = [[BoothBean alloc] init];
    bean3.title = @"教师";
    bean3.color = [UIColor whiteColor];
    
    _popuItems = [NSArray arrayWithObjects:bean1,bean2,bean3, nil];
    name = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth*2 + 50, 80, size.width,  35)];
    if(viewWidth == 414)
        name.frame = CGRectMake(viewWidth*2 + 100, 80, size.width,  35);
    
    name.text = @"身  份";
    name.textAlignment = TEXT_ALIGN_CENTER;
    name.font = KFontSizeBold32px;
    name.textColor = [UIColor whiteColor];
    name.backgroundColor = [UIColor clearColor];
    [scroller addSubview:name];
    
    tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(name.frame)+10, 80, 150, 35)];
    tagBtn.backgroundColor = [UIColor clearColor];
    tagBtn.layer.masksToBounds = YES;
    tagBtn.layer.borderWidth = 1;
    tagBtn.layer.cornerRadius = 5;
    tagBtn.tag = 4;
    [tagBtn setTitle:_ub.userInfo.occupation forState:UIControlStateNormal];
    [tagBtn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    tagBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [tagBtn addTarget:self action:@selector(theNext:) forControlEvents:UIControlEventTouchUpInside];
    [scroller addSubview:tagBtn];
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth*2 + (viewWidth-100)/2.0, 200, 100, 45)];
    [btn setBackgroundColor:RGBACOLOR(24, 142, 112, 1)];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.titleLabel.font = KFontSizeBold32px;
    btn.tag = 3;
    [btn addTarget:self action:@selector(theNext:) forControlEvents:UIControlEventTouchUpInside];
    submitBtn = btn;
    [scroller addSubview:btn];
    
    startRect = submitBtn.frame;
}
-(void)exitBtn
{
    [self.view endEditing:YES];
}
-(void)theNext:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
            [self updateHeadImg:nil];
            break;
        case 2:
        {
            [self scrollerNextPage];
        }
            break;
        case 3://完成
        {
            UserInfoBean *bean = [[UserInfoBean alloc] init];
            bean.nickname = nameTextField.text;
            bean.avatar = avatar;
            bean.occupation = tagBtn.titleLabel.text;
            
            HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
            [httpClient modifyUserInfo:bean username:_ub.username mobile:_ub.userInfo.mobile extra:nil];
        }
            break;
        case 4:
        {
            if (!_popupView)
            {
                _popupView = [[ALDPopupView alloc] initWithFrame:CGRectMake(CGRectGetMinX(tagBtn.frame), 125, 150, 45*3)];
                _popupView.delegate = self;
                
                [_popupView.tableView setBackgroundColor:[UIColor clearColor]];
                _popupView.tableView.layer.masksToBounds = YES;
                _popupView.tableView.layer.cornerRadius = 3;
                _popupView.tableView.layer.borderColor = [UIColor whiteColor].CGColor;
                _popupView.tableView.layer.borderWidth = 1;
                
                _popupView.listData = _popuItems;
                [scroller addSubview:_popupView];
            }
            
            if(_popupView.isOpen)
            {
                [_popupView viewClose:YES];
                
                //按钮动画
                [UIView animateWithDuration:1 animations:^{
                    submitBtn.frame = startRect;
                }];
            }
            else
            {
                [_popupView viewOpenWithView:tagBtn :NO];
                
                //按钮动画
                [UIView animateWithDuration:1 animations:^{
                    CGRect frame = submitBtn.frame;
                    frame.origin.y += 100;
                    submitBtn.frame = frame;
                }];
            }
            
        }
            break;
        default:
            break;
    }
}
-(void)itemDidSelected:(ALDPopupView *)popupView selecedAt:(NSInteger)selectedIndex
{
    BoothBean *bean = _popuItems[selectedIndex];
    [tagBtn setTitle:bean.title forState:UIControlStateNormal];
    
    if(_popupView.isOpen)
    {
        [_popupView viewClose:YES];
        
        //按钮动画
        [UIView animateWithDuration:1 animations:^{
            submitBtn.frame = startRect;
        }];
    }
}
-(void)scrollerNextPage
{
    CGPoint point = scroller.contentOffset;
    
    [UIView animateWithDuration:1 animations:^{
        [scroller setContentOffset:CGPointMake(point.x + CGRectGetWidth(self.view.frame), 0)];
    }];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat viewWidth = CGRectGetWidth(scrollView.frame);
    int page = (scrollView.contentOffset.x + viewWidth *0.5) / viewWidth;
    pageController.currentPage = page;
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
        
        icon.image = image;
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
        [ALDUtils addWaitingView:self.view withText:@"数据加载中,请稍候..."];
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
                avatar=thumbUrl;
                
                NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
                [config setObject:thumbUrl forKey:KIconKey];
                [config synchronize];
                
                [self scrollerNextPage];
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
            [config setObject:nameTextField.text forKey:KNickNameKey];
            [config synchronize];
            
            if (self.dataChangedDelegate && [self.dataChangedDelegate respondsToSelector:@selector(dataChangedFrom:widthSource:byOpt:)]) {
                [self.dataChangedDelegate dataChangedFrom:self widthSource:nil byOpt:2];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            [ALDUtils showToast:self.view withText:ALDLocalizedString(@"netError", @"网络异常，请确认是否已连接!")];
        }else{
            NSString *errMsg=result.errorMsg;
            if(!errMsg || [errMsg isEqualToString:@""]){
                errMsg=@"修改用户信息失败!";
            }
            [ALDUtils showToast:errMsg];
        }
    }else if(requestPath==HttpRequestPathForUserInfo){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[UserBean class]]){
                
                _ub = (UserBean *)obj;
                
                [self initUI];
                
            }
        }
    }
    [ALDUtils removeWaitingView:self.view];
}
@end
