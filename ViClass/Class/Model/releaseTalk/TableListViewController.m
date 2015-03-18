//
//  ReleaseTalkViewController.m
//  WeTalk
//
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "TableListViewController.h"
#import "ALDButton.h"
#import "ClassRoomBean.h"
#import "ChapterBean.h"
#import "ButtonView.h"
#import "ShowViewController.h"
#import "QuestionBean.h"
#import "CheckoutViewController.h"
#import "HttpClient.h"
#import "PullingRefreshTableView.h"
#import "ALDImageView.h"
#import "ShowViewController.h"
#import "BaseViewDocViewController.h"

@interface TableListViewController ()<UITableViewDataSource,UITableViewDelegate,ButtonDelegate,PullingRefreshTableViewDelegate,UIActionSheetDelegate>
{
    int  _iPage;             //列表页码
    int  _iPageSize;         //列表行数
    BOOL _bDataListHasNext;  //是否还有下拉数据
    NSIndexPath *delIndex;
}
@property (nonatomic,retain) NSMutableArray *tableData;
@property (nonatomic,retain) NSMutableArray *monthData;
@property (nonatomic,retain) NSMutableDictionary *monthDayDic;
@property (nonatomic,retain) PullingRefreshTableView *pullTableView;
@property (nonatomic,retain) NSArray *colors;
@property (nonatomic,retain) NSArray *finishColors;
@property (nonatomic,retain) ClassRoomBean *selectedBean;

@property (nonatomic        ) BOOL                    bRefreshing;


@end

@implementation TableListViewController
- (void)dealloc
{
    
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = KTableViewBackgroundColor;
    
    CGRect frame               = self.view.frame;
//    CGFloat viewWidth          = CGRectGetWidth(frame);
//    CGFloat viewHeight         = CGRectGetHeight(frame);
    
//    //自定义导航栏
//    UINavigationBar *bar=[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 64)];
//    
//    UINavigationItem *item=[[UINavigationItem alloc] initWithTitle:@"我的课表"];
//    
//    [bar pushNavigationItem:item animated:YES]; //把导航条推入到导航栏
//    
//    [self.view addSubview:bar]; //添加导航条视图
//    
//    //返回按钮
//    ALDButton *btn        = [ALDButton buttonWithType:UIButtonTypeCustom];
//    btn.frame             = CGRectMake(0, 0, 35, 40);
//    btn.tag     =  0x010;
//    btn.backgroundColor   = [UIColor clearColor];
//    [btn setTitle:@"取消" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    btn.titleLabel.font = kFontSize32px;
//    btn.selectBgColor = [UIColor clearColor];
//    [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    [item setLeftBarButtonItem:leftBtn animated:YES];
    
    [self initParams];
    [self loadData];
    [self initUI];
    
}
//==============
// 初始化参数
//==============
- (void)initParams
{
    _iPage            = 1;
    _iPageSize        = 20;
    _bDataListHasNext = NO;
}

-(void)initUI
{
    CGRect frame                    = self.view.frame;
    
    _pullTableView                  = [[PullingRefreshTableView alloc] initWithFrame:frame pullingDelegate:self];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_pullTableView];

    _colors = [NSArray arrayWithObjects:RGBACOLOR(77, 167, 226, 1),RGBACOLOR(80, 100, 142, 1),RGBACOLOR(130, 93, 75, 1),RGBACOLOR(144, 194, 90, 1),RGBACOLOR(213, 47, 70, 1),RGBACOLOR(209, 209, 209, 1),RGBACOLOR(242, 52, 132, 1), nil];
    _finishColors = [NSArray arrayWithObjects:[UIColor lightGrayColor],[UIColor redColor],[UIColor yellowColor],[UIColor greenColor], nil];
}
-(void)loadData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getMyCourse:_iPage pageCount:_iPageSize];
}

- (void)clickButton:(ALDButton *)sender {
    switch (sender.tag) {
        case 0x010: { //返回按钮
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
            break;
        case 0x1003:
        {
            NSDictionary *dic = sender.userInfo;
            ClassRoomBean *bean = [dic objectForKey:@"data"];
            NSInteger i = 0;
            for(ClassRoomBean *temp in _tableData)
            {
                if([temp.sid isEqualToString:bean.sid])
                {
                    break;
                }
                i++;
            }

            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"取消课程的报名" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"确定", nil];
            action.tag = 0x3000+i;
            [action showInView:self.view];
            
        }
            break;
        case 0x2001:
        {
            
        }
        default:
            break;
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(!buttonIndex)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:actionSheet.tag - 0x3000];
        delIndex = index;
        ClassRoomBean *bean = _tableData[index.section];
        
        HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
        [httpClient courseCancel:bean.sid];
    }

}
#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ClassRoomBean *bean = self.tableData[section];
    
    return (bean.isOpened ? bean.chapters.count: 0);
}
/**
 *  返回每一组需要显示的头部标题(字符出纳)
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = CGRectGetWidth(self.view.frame)-210-25;

    ClassRoomBean *bean = self.tableData[section];
    CGFloat completeness = bean.completeness;
    CGFloat addWidth = width * completeness;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 65)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 200+addWidth, 55)];
    bgView.backgroundColor = RGBACOLOR(57, 186, 238, 1);
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 8;
    [view addSubview:bgView];
    
    ALDImageView *icon = [[ALDImageView alloc] initWithFrame:CGRectMake(15, 20, 15, 15)];
    icon.image = [UIImage imageNamed:@"icon_arrow"];
    [bgView addSubview:icon];
    
    CGSize size = [ALDUtils captureTextSizeWithText:bean.name textWidth:200 font:KFontSizeBold30px];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(icon.right+5, 5, 100, 25)];
    content.backgroundColor = [UIColor clearColor];
    content.textColor = RGBACOLOR(65, 83, 89, 1);
    content.font = KFontSizeBold30px;
    content.textAlignment = TEXT_ALIGN_LEFT;
    content.text = bean.name;
    if(CGRectGetWidth(bgView.frame)-105>size.width)
    {
        CGRect frame = content.frame;
        frame.size.width += size.width;
        content.frame = frame;
    }
    [bgView addSubview:content];
    
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(icon.right+5, 25, 100, 25)];
    count.backgroundColor = [UIColor clearColor];
    count.textColor = RGBACOLOR(231, 248, 253, 1);
    count.font = KFontSizeBold30px;
    count.textAlignment = TEXT_ALIGN_LEFT;
    count.text = [NSString stringWithFormat:@"%i章节",bean.chapterCount];
    [bgView addSubview:count];

    ALDButton *deleBtn = [[ALDButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    deleBtn.center = CGPointMake(CGRectGetMaxX(bgView.frame), CGRectGetMinY(bgView.frame)+27.5);
    deleBtn.tag = 0x1003;
    deleBtn.layer.cornerRadius = 15;
    deleBtn.backgroundColor = [UIColor whiteColor];
    deleBtn.layer.shadowColor = KWordBlackColor.CGColor;
    deleBtn.layer.shadowOffset = CGSizeMake(0, 1);
    deleBtn.layer.shadowRadius = 2.0;
    deleBtn.layer.shadowOpacity = 0.8;
    deleBtn.userInfo = [NSDictionary dictionaryWithObject:bean forKey:@"data"];
    [deleBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:deleBtn];
    
    icon = [[ALDImageView alloc] initWithFrame:CGRectMake(9, 9, 12, 12)];
    icon.image = [UIImage imageNamed:@"cross"];
    [deleBtn addSubview:icon];
    
    UILabel *press = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(bgView.frame)-40, 35)];
    press.backgroundColor = [UIColor clearColor];
    press.textColor = RGBACOLOR(195, 234, 250, 1);
    press.font = KFontSizeBold34px;
    press.textAlignment =TEXT_ALIGN_Right;
    press.tag = 0x1004;
    press.text = [NSString stringWithFormat:@"%.0f",completeness*100];
    if(completeness == 0)
        press.text = @"未开始";
    [bgView addSubview:press];
    
    press = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, CGRectGetMaxX(bgView.frame)-40, 15)];
    press.backgroundColor = [UIColor clearColor];
    press.textColor = RGBACOLOR(50, 144, 198, 1);
    press.font = KFontSizeBold26px;
    press.textAlignment =TEXT_ALIGN_Right;
    press.tag = 0x1005;
    press.text = @"%";
    [bgView addSubview:press];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(bgView.frame)-15, 55)];
    [button addTarget:self action:@selector(headerViewDidClickedNameView:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    button.tag = section;
    [view addSubview:button];

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 65;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 90;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 60;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60)];
//    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-170)/2.0,10, 170, 40)];
//    btn.layer.masksToBounds = YES;
//    btn.layer.cornerRadius = 20;
//    [btn setBackgroundColor:RGBACOLOR(237, 34, 34, 1)];
//    [btn setTitle:@"全部取消" forState:UIControlStateNormal];
//    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
//    btn.tag = 0x2001;
//    [view addSubview:btn];
//    [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//    
//    return view;
//}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat cellView = self.view.width;
        
        ALDImageView *imageView = [[ALDImageView alloc] initWithFrame:CGRectMake(10, 5, 145, 80)];
        imageView.defaultImage = [UIImage imageNamed:@"class_default"];
        imageView.imageUrl = @"";
        imageView.tag = 0x0010;
        [cell addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+5, imageView.top,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize30px;
        label.textColor = RGBACOLOR(65, 83, 89, 1);
        label.tag = 0x0011;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+5, label.bottom+10,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize28px;
        label.textColor = KWordGrayColor;
        label.tag = 0x0012;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+5, label.bottom+5,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize28px;
        label.textColor = KWordGrayColor;
        label.numberOfLines = 0;
        label.tag = 0x0013;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(label.right+5, label.right+15,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize28px;
        label.textColor = [UIColor redColor];
        label.tag = 0x0014;
        [cell addSubview:label];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 89, cell.width-30, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        //[cell addSubview:line];
        
        
    }

    ClassRoomBean *bean = _tableData[indexPath.section];
    ChapterBean *cb = bean.chapters[indexPath.row];
    
    ALDImageView *img = (ALDImageView *)[cell viewWithTag:0x0010];
    img.imageUrl =cb.logo;
    
    UILabel *label = (UILabel *)[cell viewWithTag:0x0011];
    label.text = cb.name;
    
    UILabel *size = (UILabel *)[cell viewWithTag:0x0012];
    AttachmentBean *at = cb.attachments[0];
    size.text =[NSString stringWithFormat:@"类型：%@",[at.type intValue]==3?@"视频":@"文档"];
    
    UILabel *num = (UILabel *)[cell viewWithTag:0x0013];
    
    //1小时内显示分钟，8小时以上显示具体时间(日期+时间)
    num.text = [NSString stringWithFormat:@"时间：%@",[ALDUtils delRealTimeData:cb.createTime]];
    

//    label = (UILabel *)[cell viewWithTag:0x0012];
//    label.text = [NSString stringWithFormat:@"分类: %@",cb.categoryName];
//    
//    label = (UILabel *)[cell viewWithTag:0x0013];
//    label.text = [NSString stringWithFormat:@"集数 : %i",cb.chapterCount];
//    
//    CGSize size = [ALDUtils captureTextSizeWithText:label.text textWidth:200 font:kFontSize28px];
//    UILabel *tag = (UILabel *)[cell viewWithTag:0x0014];
//    tag.frame = CGRectMake(label.left+size.width+5,label.top, 200, 15);
//    tag.text = cb.status ? @"已完结":@"未完结";


    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClassRoomBean *bean = _tableData[indexPath.section];
    ChapterBean *cb = bean.chapters[indexPath.row];
    AttachmentBean *at = cb.attachments[0];
    
    if([at.type intValue] == 3)
    {//视频
        ShowViewController *controller = [[ShowViewController alloc] init];
        controller.title = @"章节详情";
        controller.chapterId = cb.sid;
        controller.url = [self chineseToUTf8Str:at.url];
        controller.toController = 2;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if([at.type intValue] == 4)
    {
        BaseViewDocViewController *controller = [[BaseViewDocViewController alloc] init];
        controller.docUrl=[self chineseToUTf8Str:at.url];
        controller.docName=bean.name;
        controller.fileType = [at.url pathExtension];
        controller.docSize=[at.size longValue];
        controller.title=@"文档详情";
        controller.type = FinishStyleWithSave;
        [self.navigationController pushViewController:controller animated:YES];
        
    }
}
-(NSString *)chineseToUTf8Str:(NSString*)chineseStr
{
    chineseStr = [chineseStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return chineseStr;
}
/**
 *  点击了headerView上面的名字按钮时就会调用
 */
- (void)headerViewDidClickedNameView:(UIButton *)sender
{

    ClassRoomBean *bean = self.tableData[sender.tag];
    if(bean == self.selectedBean)
    {
        self.selectedBean.opened = !self.selectedBean.opened;
    }
    else
    {
        self.selectedBean.opened = 0;
        self.selectedBean = bean;
        // 1.修改组模型的标记(状态取反)
        self.selectedBean.opened = 1;
    }
    [self.pullTableView reloadData];
}

#pragma mark - Scroll Action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullTableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullTableView tableViewDidEndDragging:scrollView];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    self.bRefreshing = YES;
    [self performSelector:@selector(scrollLoadData) withObject:[NSNumber numberWithInt:1] afterDelay:1.f];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(scrollLoadData) withObject:[NSNumber numberWithInt:1] afterDelay:1.f];
}
- (void)scrollLoadData
{
    if (self.bRefreshing == YES)
    {
        _iPage=1;
    }
    else
    {
        _iPage++;
    }
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForMyCourse){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }else if (requestPath ==HttpRequestPathForCourseCancel)
    {
        [ALDUtils addWaitingView:self.view withText:@"操作处理中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if(requestPath == HttpRequestPathForCourseCancel)
    {
        [ALDUtils showToast:result.errorMsg];
        if(code == KOK)
        {
            [self.tableData removeObjectAtIndex:delIndex.section];
//            [self.pullTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:<#(id), ...#>, nil] withRowAnimation:UITableViewRowAnimationFade];
            [_pullTableView reloadData];
        }
    }
    else if(requestPath==HttpRequestPathForMyCourse){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *array=(NSArray *)obj;
                if(_iPage==1){
                    _tableData=[NSMutableArray arrayWithArray:array];
                }else{
                    [_tableData addObjectsFromArray:array];
                }
                
                _bDataListHasNext = result.hasNext;
                if (!_bDataListHasNext){
                    [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                    _pullTableView.reachedTheEnd = YES;
                }else{
                    [_pullTableView tableViewDidFinishedLoading];
                    _pullTableView.reachedTheEnd = NO;
                }
                [_pullTableView reloadData];
            }
            [ALDUtils hiddenTips:self.view];
        }else if(code==kNO_RESULT){
            _bDataListHasNext = NO;
            if(_iPage==1){
                self.tableData=nil;
                [self.pullTableView reloadData];
            }
            if (!_tableData || _tableData.count < 1){
                [_pullTableView tableViewDidFinishedLoading];
                _pullTableView.reachedTheEnd = NO;
                //[self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"抱歉，暂无会务数据!"]];
            }else{
                [ALDUtils hiddenTips:self.view];
                [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                _pullTableView.reachedTheEnd = YES;
            }
        }else if(code==kHOST_ERROR) {
            NSString *errMsg=result.errorMsg;
            //            [ALDUtils showTips:self.view text:errMsg];
            //            [ALDUtils showToast:errMsg];
            NSString *text=[NSString stringWithFormat:@"该%@，请重新登录。",errMsg];
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:text delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alertView.tag=0x550;
            [alertView show];
            
        }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
            if (!_tableData || _tableData.count < 1){
                //[self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"网络异常，请确认是否已连接!"]];
            }
            [_pullTableView tableViewDidFinishedLoading];
            if (_iPage>1) {
                _iPage--;
            }
        }else{
            NSString *errMsg=result.errorMsg;
            if (!_tableData || _tableData.count < 1)
            {
                errMsg=@"抱歉，获取数据失败！下拉刷新！";
            } else {
                errMsg=@"抱歉，获取数据失败！";
            }
            [ALDUtils showToast:errMsg];
            [_pullTableView tableViewDidFinishedLoading];
            _pullTableView.reachedTheEnd = YES;
            if (_iPage>1) {
                _iPage--;
            }
        }
    }
    [ALDUtils removeWaitingView:self.view];
}


@end
