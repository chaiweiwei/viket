//
//  MianViewController.m
//  WeTalk
//
//  主页
//
//  Created by x-Alidao on 14/11/29.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "MainViewController.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "UIViewExt.h"
#import "AppDelegate.h"
#import "ShowListCell.h"
#import "ClassListViewController.h"
#import "TalkListViewController.h"
#import "ClassRoomBean.h"
#import "HttpClient.h"

#define TAG_LABLE_TITLE    0x001
#define TAG_LABLE_TIME     0x002
#define TAG_LABLE_CONTENT  0x003
#define TAG_LABLE_LOCATION 0x004
#define TAG_IMAGE_LOGO     0x005
#define TAG_IMAGE_LOCATION 0x006
#define TAG_IMAGE_TIME     0x007
#define TAG_LABLE_STATUS   0x008
#define TAG_IMAGE_STATUS   0x009
#define TAG_LABLE_ENDTIME  0x0010

#define kTableColumns      2
#define kTableRowHeight    132

@interface MainViewController ()<UIAlertViewDelegate>
{
    BOOL _needRefrash,_isShowing;
    int selectType;
    
    BOOL _isShow;
}
@property (retain,nonatomic) NSNumber       *currConfid;
@property (retain,nonatomic) NSMutableArray *overseasList;

@end

@implementation MainViewController
@synthesize currConfid     = _currConfid;
@synthesize pullTableView  = _pullTableView;
@synthesize bRefreshing    = _bRefreshing;
@synthesize parentController = _parentController;

- (void)dealloc
{
    self.currConfid                    = nil;
    self.pullTableView.dataSource      = nil;
    self.pullTableView.delegate        = nil;
    self.pullTableView.pullingDelegate = nil;
    self.pullTableView                 = nil;
    self.tableData                     = nil;
    self.parentController              = nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.hidesBackButton = YES;
        _isShow=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    [self initUI];
}

-(void) launchRefreshing{
    if ([self isViewLoaded]) {
        [self.pullTableView launchRefreshing];
    }
}

-(void) setViewShowing:(BOOL) isShow{
    if (!_isShow) {
        [self performSelectorInBackground:@selector(loadData) withObject:nil];
    }
    _isShow=isShow;
}

-(void) loadData{
    
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    if([self.typeId intValue] == 1)
        [httpClient getrSubjectList:_iPage pageCount:_iPageSize keyword:nil categoryId:nil hot:0 top:1 new:0];
    else if([self.typeId intValue] == 2)
        [httpClient getrSubjectList:_iPage pageCount:_iPageSize keyword:nil categoryId:nil hot:0 top:0 new:1];
    else if([self.typeId intValue] == 3)
        [httpClient getrSubjectList:_iPage pageCount:_iPageSize keyword:nil categoryId:nil hot:1 top:0 new:0];
}

//==============
// 初始化参数
//==============
- (void)initParams
{
    _iPage            = 1;
    _iPageSize        = 20;
    _bDataListHasNext = NO;
    selectType=self.type;
}

//==============
// 初始化界面
//==============
- (void)initUI
{
    //-------------------
    // 列表
    //-------------------
    CGRect frame                    = self.view.frame;
    CGFloat viewHeight              = CGRectGetHeight(frame);
    if (viewHeight == 736) {
        frame.size.height              -= 220/3.f - 24 - 2;
    }else {
        frame.size.height              -= 70 - 21 - 2;
    }
    
    _pullTableView                  = [[PullingRefreshTableView alloc] initWithFrame:frame pullingDelegate:self];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.pullingDelegate  = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_pullTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.tableData.count;
    if (count>0) {
        return count/kTableColumns+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellID = @"CellID";
    UITableViewCell *cell      = nil;
    
    CGRect frame                    = self.view.frame;
    CGFloat viewWidth              = CGRectGetWidth(frame);
    NSInteger tagOffSet = 100;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellIDFirst"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIDFirst"];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            
            //图片
            ALDImageView *bookPic = [[ALDImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 150)];
            bookPic.tag = 0x0011;
            bookPic.fitImageToSize = NO;
            bookPic.autoResize = NO;
            bookPic.backgroundColor = [UIColor clearColor];
            bookPic.defaultImage=[UIImage imageNamed:@"bg_vshuo"];
            [cell addSubview:bookPic];
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, bookPic.height - 30, viewWidth, 30)];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.3;
            [cell addSubview:view];
            
            //标题
            UILabel *label = [self createLabel:CGRectMake(5, bookPic.height - 30, viewWidth - 10, 30) textColor:KWordWhiteColor textFont:kFontSize30px];
            label.textAlignment = TEXT_ALIGN_LEFT;
            label.tag = 0x0012;
            [cell addSubview:label];
            
            ALDButton *button = [ALDButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, viewWidth, 150);
            button.tag = 0x0010;
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(clickCell:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            
            //冠军标志
            if ([self.typeId integerValue] != 2) {
                ALDImageView *championPic = [[ALDImageView alloc] initWithFrame:CGRectMake(viewWidth - 128/2.f - 15, 15.0f, 128/2.f, 86/2.f)];
                championPic.image = [UIImage imageNamed:@"champion"];
                if (viewWidth == 414) {
                    championPic.frame = CGRectMake(viewWidth - 192/3.f - 15, 15.0f, 192/3.f, 128/3.f);
                    championPic.image = [UIImage imageNamed:@"champion@3x"];
                }
                championPic.backgroundColor = [UIColor clearColor];
                [cell addSubview:championPic];
            }
        }
        
        ClassRoomBean *bean = [self.tableData objectAtIndex:indexPath.row];
        
        ALDButton *button = (ALDButton *)[cell viewWithTag:0x0010];
        button.userInfo = [NSDictionary dictionaryWithObject:bean forKey:@"data"];
        
        //用户名称
        UILabel *label = (UILabel *)[cell viewWithTag:0x0012];
        NSString *text = bean.name;
        text=text==nil?@"":text;
        if([text isEqualToString:@""]) {
            label.text = @"1. ";
            label.hidden = NO;
        }else {
            text = [NSString stringWithFormat:@"1. %@", text];
            label.text = text;
            label.hidden = NO;
        }
        
        //用户头像
        ALDImageView *img = (ALDImageView *)[cell viewWithTag:0x0011];
        text = bean.logo;
        text=text==nil?@"":text;
        if([text isEqualToString:@""]) {
            img.image = [UIImage imageNamed:@"bg_vshuo"];
        }else {
            img.imageUrl = text;
        }
        
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellID];
        
        NSInteger tagOffSet2 = 200;
        NSInteger tagOffSet3 = 300;
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGFloat x = 0;
            CGFloat space = 2;
            CGFloat width = (viewWidth - space)/2.f;
            
            for (int i=0; i<kTableColumns; i++) {
                
                //图片
                ALDImageView *bookPic = [[ALDImageView alloc] initWithFrame:CGRectMake(x, 0, width, kTableRowHeight - 2)];
                bookPic.tag = tagOffSet2+i+1;
                bookPic.fitImageToSize = NO;
                bookPic.autoResize = NO;
                bookPic.backgroundColor = [UIColor clearColor];
                bookPic.defaultImage=[UIImage imageNamed:@"bg_vshuo"];
                [cell addSubview:bookPic];
                
                //用户名称
                UILabel *label = [self createLabel:CGRectMake(x+5, bookPic.height - 5 - 15, width - 10, 15) textColor:KWordWhiteColor textFont:kFontSize30px];
                label.tag = tagOffSet3+i+1;
                label.backgroundColor = [UIColor clearColor];
                [cell addSubview:label];
                
                ALDButton *button = [ALDButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(x, 0, width, kTableRowHeight - 2);
                button.tag = tagOffSet+i+1;
                button.backgroundColor = [UIColor clearColor];
                [button addTarget:self action:@selector(clickCell:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:button];
                
                x += width+space;
            }
        }
        
        for (int i=0; i<kTableColumns; i++) {
            long num = kTableColumns*indexPath.row+i;
            long index = kTableColumns*indexPath.row+i-1;
            
            if (index<self.tableData.count) {
                ClassRoomBean *bean = [self.tableData objectAtIndex:index];
                
                ALDButton *button = (ALDButton *)[cell viewWithTag:tagOffSet+i+1];
                button.hidden = NO;
                button.userInfo = [NSDictionary dictionaryWithObject:bean forKey:@"data"];
                
                //用户名称
                UILabel *label = (UILabel *)[cell viewWithTag:tagOffSet3+i+1];
                NSString *text = bean.name;
                text=text==nil?@"":text;
                if([text isEqualToString:@""]) {
                    text = [NSString stringWithFormat:@"%ld.", num];
                    label.text = text;
                    label.hidden = NO;
                }else {
                    text = [NSString stringWithFormat:@"%ld. %@", num, text];
                    label.text = text;
                    label.hidden = NO;
                }
                
                //图片
                ALDImageView *img = (ALDImageView *)[cell viewWithTag:tagOffSet2+i+1];
                text = bean.logo;
                text=text==nil?@"":text;
                if([text isEqualToString:@""]) {
                    img.image = [UIImage imageNamed:@"bg_vshuo"];
                    img.hidden = NO;
                }else {
                    img.imageUrl = text;
                    img.hidden = NO;
                }
            }else {
                //用户名称
                UILabel *label = (UILabel *)[cell viewWithTag:tagOffSet3+i+1];
                label.text = nil;
                label.hidden = YES;
                
                //用户头像
                ALDImageView *img = (ALDImageView *)[cell viewWithTag:tagOffSet2+i+1];
                img.image = nil;
                img.hidden = YES;
                
                ALDButton *button = (ALDButton *)[cell viewWithTag:tagOffSet+i+1];
                button.hidden = YES;
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = kTableRowHeight;
    if (indexPath.row == 0) {
        cellHeight = 152.0f;
    }
    
    return cellHeight;
}

-(void)clickCell:(ALDButton *)sender
{
    NSDictionary *dic = sender.userInfo;
    ClassRoomBean *bean = [dic objectForKey:@"data"];
    
    ClassListViewController *controller = [[ClassListViewController alloc] init];
    controller.title = @"课程详情";
    controller.courseId = bean.sid;
    
    if (_parentController) {
            [_parentController.navigationController pushViewController:controller animated:YES];
        }else{
            [self.navigationController pushViewController:controller animated:YES];
    }
}

-(UILabel *)createLabel:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}

-(UIView *)createLine:(CGRect)frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
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
-(void) showTips:(NSString *) text{
    _pullTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [ALDUtils showTips:self.view text:text];
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

- (void)refrashClick
{
    _bDataListHasNext = NO;
    self.pullTableView.reachedTheEnd  = NO;
    self.bRefreshing = NO;
    _iPage = 1;
}

- (void)getMore
{
    if (!_bDataListHasNext)
    {
        [self.pullTableView tableViewDidFinishedLoading];
        self.pullTableView.reachedTheEnd = YES;
        return;
    }
    _iPage++;
}

- (void)btnPressed:(id)sender
{
    
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForSubjectList){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if(requestPath==HttpRequestPathForSubjectList){
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
                [self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"抱歉，暂无会务数据!"]];
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
                [self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"网络异常，请确认是否已连接!"]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

