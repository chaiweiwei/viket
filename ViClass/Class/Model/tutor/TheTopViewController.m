//
//  TutorListViewController.m
//  WeTalk
//  排行榜
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "TheTopViewController.h"
#import "ALDImageView.h"
#import "ALDButton.h"
#import "UIViewExt.h"
#import "ShowListCell.h"
#import "TalkListViewController.h"
#import "CustomBean.h"
#import "HttpClient.h"

#define kTableColumns      2
#define kTableRowHeight    132

@interface TheTopViewController ()

@end

@implementation TheTopViewController
@synthesize pullTableView  = _pullTableView;
@synthesize bRefreshing    = _bRefreshing;

- (void)dealloc
{
    self.pullTableView.dataSource      = nil;
    self.pullTableView.delegate        = nil;
    self.pullTableView.pullingDelegate = nil;
    self.pullTableView                 = nil;
    self.tableData                     = nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initParams];
    [self initUI];
    [self loadData];
}

-(void) launchRefreshing{
    if ([self isViewLoaded]) {
        [self.pullTableView launchRefreshing];
    }
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

//==============
// 初始化界面
//==============
- (void)initUI
{
    //-------------------
    // 列表
    //-------------------
    CGRect frame       = self.view.frame;
    
    _pullTableView                  = [[PullingRefreshTableView alloc] initWithFrame:frame pullingDelegate:self];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.pullingDelegate  = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_pullTableView];
    
    
}

-(void)loadData{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getRecordsRankingList:_iPage pageCount:_iPageSize];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellID = @"CellID";
    UITableViewCell *cell      = [tableView dequeueReusableHeaderFooterViewWithIdentifier:strCellID];
    
    CGRect frame                    = self.view.frame;
    CGFloat viewWidth              = CGRectGetWidth(frame);
    if(cell ==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellID];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(25/2.0,16, 25, 20)];
        icon.tag = 0x13;
        [cell addSubview:icon];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        label.tag = 0x10;
        label.textColor = [UIColor blackColor];
        label.textAlignment = TEXT_ALIGN_CENTER;
        label.font = KFontSizeBold32px;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, cell.frame.size.width-50, 50)];
        label.tag = 0x11;
        label.textColor = [UIColor blackColor];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize32px;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth-20-50, 0, 50, 50)];
        label.tag = 0x12;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = TEXT_ALIGN_Right;
        label.textColor = [UIColor lightGrayColor];
        label.font = kFontSize32px;
        [cell addSubview:label];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49, viewWidth, 1)];
        line.backgroundColor = RGBACOLOR(214, 214, 214, 1);
        [cell addSubview:line];
        
    }
    CustomBean *bean = self.tableData[indexPath.row];
    if([bean.name isEqualToString:@"张三"])
    {
        cell.backgroundColor = RGBACOLOR(255, 231, 222, 1);
    }
    if(indexPath.row == 0)
    {
        UIImageView *icon = (UIImageView *)[cell viewWithTag:0x13];
        icon.image = [UIImage imageNamed:@"king01"];
    }
    else  if(indexPath.row == 1)
    {
        UIImageView *icon = (UIImageView *)[cell viewWithTag:0x13];
        icon.image = [UIImage imageNamed:@"king02"];
    }
    else  if(indexPath.row == 2)
    {
        UIImageView *icon = (UIImageView *)[cell viewWithTag:0x13];
        icon.image = [UIImage imageNamed:@"king03"];
    }
    else
    {
        UILabel *label = (UILabel *)[cell viewWithTag:0x10];
        label.text = [NSString stringWithFormat:@"%li. ",indexPath.row+1];
    }

    UILabel *label = (UILabel *)[cell viewWithTag:0x11];
    label.text = bean.name;
    
    label = (UILabel *)[cell viewWithTag:0x12];
    label.text = [NSString stringWithFormat:@"%i",bean.integral];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)clickCell:(id)sender
{
    
}

//申请导师
- (void)ClickBtn {
    
}

-(UILabel *)createLabel:(CGRect )frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) showTips:(NSString *) text{
    _pullTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [ALDUtils showTips:self.view text:text];
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForRecordsRanking){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if(requestPath == HttpRequestPathForRecordsRanking)
    {
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


@end
