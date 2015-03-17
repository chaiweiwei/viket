//
//  MessagePushViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/13.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "MessagePushViewController.h"
#import "PullingRefreshTableView.h"
#import "HttpClient.h"
#import "NewBean.h"
#import "MessageDao.h"

@interface MessagePushViewController()<UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>
{
    int  _iPage;             //列表页码
    int  _iPageSize;         //列表行数
    BOOL _bDataListHasNext;  //是否还有下拉数据
    BOOL first;
}
@property (nonatomic,retain) PullingRefreshTableView *pullTableView;
@property (nonatomic,retain) NSMutableArray *tableData;
@property (nonatomic        ) BOOL                    bRefreshing;
@property(nonatomic,retain) NSArray *daoData;
@property(nonatomic,retain) NSMutableArray *allTableData;
@end
@implementation MessagePushViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self initParams];
    [self loadData];
    
    CGRect frame                    = self.view.frame;
    
    _pullTableView                  = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) pullingDelegate:self];
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.dataSource       = self;
    _pullTableView.delegate         = self;
    _pullTableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _pullTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _pullTableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_pullTableView];

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
-(void)loadData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getUserNews:_iPage pageCount:_iPageSize];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _allTableData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewBean *bean = _allTableData[indexPath.row];
    CGSize size = [ALDUtils captureTextSizeWithText:bean.content textWidth:CGRectGetWidth(self.view.frame)-50 font:kFontSize32px];
    CGFloat height = 50;
    if(size.height+20>height)
        return size.height+20;
    return height;
}
#pragma mark - TableViewDataSource, TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellID];
    
    CGRect frame      = self.view.frame;
    CGFloat viewWidth = CGRectGetWidth(frame);

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellID];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *cir = [self createCirViewNew:CGPointMake(15, 14)];
        cir.tag = 0x1004;
        [cell addSubview:cir];
        
        UIView *cirold = [self createCirViewOld:CGPointMake(15, 14)];
        cirold.tag = 0x1005;
        [cell addSubview:cirold];
        
        UILabel *title =[[UILabel alloc] initWithFrame:CGRectMake(50, 0, viewWidth-50, 30)];
        title.tag = 0x1001;
        title.font = kFontSize32px;
        title.text = TEXT_ALIGN_LEFT;
        title.textColor = KWordGrayColor;
        title.backgroundColor = [UIColor clearColor];
        title.numberOfLines = 0;
        [cell addSubview:title];
        
        UILabel *time =[[UILabel alloc] initWithFrame:CGRectMake(50, 30, viewWidth-50, 20)];
        time.tag = 0x1002;
        time.font = kFontSize22px;
        time.textAlignment = TEXT_ALIGN_LEFT;
        time.backgroundColor = [UIColor clearColor];
        time.textColor = RGBACOLOR(255, 150, 3, 1);
        [cell addSubview:time];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(50, 49.5, viewWidth-50, 0.5)];
        line.backgroundColor = RGBACOLOR(204, 204, 204, 1);
        line.tag = 0x1003;
        [cell addSubview:line];
    }
    NewBean *bean = _allTableData[indexPath.row];
    
    UIView *cirnew = (UIView *)[cell viewWithTag:0x1004];
    UIView *cirold = (UIView *)[cell viewWithTag:0x1005];
    
    if(indexPath.row<_daoData.count)
    {
        cirnew.hidden = YES;
        cirold.hidden = NO;
    }
    else
    {
        cirnew.hidden = NO;
        cirold.hidden = YES;
    }
    
    CGSize size = [ALDUtils captureTextSizeWithText:bean.content textWidth:CGRectGetWidth(self.view.frame)-50 font:kFontSize32px];
    UILabel *title = (UILabel *)[cell viewWithTag:0x1001];
    title.text = bean.content;
    CGRect rect = title.frame;
    if(size.height>30)
    {
        rect.size.height = size.height;
        title.frame = rect;
    }
    
    UILabel *time = (UILabel *)[cell viewWithTag:0x1002];
    time.text = bean.createTime;
    rect = time.frame;
    if(size.height>30)
    {
        rect.origin.y = CGRectGetMaxY(title.frame);
        time.frame = rect;
    }
    
    UIView *line = (UIView *)[cell viewWithTag:0x1003];
    rect = line.frame;
    if(size.height>30)
    {
        rect.origin.y = CGRectGetMaxY(time.frame)-0.5;
        line.frame = rect;
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 75;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame      = self.view.frame;
    CGFloat viewWidth = CGRectGetWidth(frame);
    CGFloat viewHeight = CGRectGetHeight(frame);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    view.backgroundColor = KTableViewBackgroundColor;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, viewWidth, 35)];
    title.text = @"提醒";
    title.backgroundColor = [UIColor clearColor];
    title.textColor = RGBACOLOR(255, 149, 0, 1);
    title.textAlignment = TEXT_ALIGN_LEFT;
    title.font = [UIFont boldSystemFontOfSize:30];
    [view addSubview:title];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(15,45, viewWidth, 30)];
    title.text = @"最新";
    title.backgroundColor = [UIColor clearColor];
    title.textColor = RGBACOLOR(255, 150, 3, 1);
    title.textAlignment = TEXT_ALIGN_LEFT;
    title.font = kFontSize30px;
    [view addSubview:title];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(15,45, viewWidth-30, 30)];
    title.text = @"编辑";
    title.backgroundColor = [UIColor clearColor];
    title.textColor = RGBACOLOR(0, 122 , 255, 1);
    title.textAlignment = TEXT_ALIGN_Right;
    title.font = kFontSize34px;
    [view addSubview:title];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 74.5, viewWidth, 0.5)];
    line.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    [view addSubview:line];

    return view;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewBean *bean = _allTableData[indexPath.row];
    
    MessageDao *messageDao = [[MessageDao alloc] init];
    if([messageDao deleteMeaasgeData:bean.sid])
    {
        [self.allTableData removeObjectAtIndex:indexPath.row];
        [self.pullTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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
-(UIView *)createCirViewNew:(CGPoint)point
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, 22, 22)];
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = 11;
    view.layer.borderWidth =1;
    view.layer.borderColor = RGBACOLOR(180, 128, 57, 1).CGColor;
    view.layer.shadowColor = KWordBlackColor.CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 0.4;
    
    
    UIView *neiCir = [[UIView alloc] initWithFrame:CGRectMake(4, 4, 14, 14)];
    neiCir.backgroundColor = RGBACOLOR(254, 167, 45, 1);
    neiCir.layer.masksToBounds = YES;
    neiCir.layer.cornerRadius = 7;
    [view addSubview:neiCir];
    
    UIView *waiCir = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    
    waiCir.layer.masksToBounds = YES;
    
    return view;
}
-(UIView *)createCirViewOld:(CGPoint)point
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, 22, 22)];
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = 11;
    view.layer.borderWidth =1;
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.shadowColor = KWordBlackColor.CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowRadius = 1;
    view.layer.shadowOpacity = 0.4;
    
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForUserNews){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if(requestPath== HttpRequestPathForUserNewsRead)
    {
        if(code == KOK)
        {
            
        }
    }
    else if(requestPath==HttpRequestPathForUserNews){
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *array=(NSArray *)obj;
                if(_iPage==1){
                    //_tableData=[NSMutableArray arrayWithArray:array];
                    first = NO;
                }
//                }else{
//                    [_tableData addObjectsFromArray:array];
//                }
                _tableData=[NSMutableArray arrayWithArray:array];
                _bDataListHasNext = result.hasNext;
                if (!_bDataListHasNext){
                    [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                    _pullTableView.reachedTheEnd = YES;
                }else{
                    [_pullTableView tableViewDidFinishedLoading];
                    _pullTableView.reachedTheEnd = NO;
                }
                if(!first)
                {
                    //得到缓存的数据
                    MessageDao *messageDao = [[MessageDao alloc] init];
                    _daoData = [messageDao queryMeaasgeData];
                    _allTableData = [NSMutableArray arrayWithArray:_daoData];
                    
                    first = YES;
                }
                [_allTableData addObjectsFromArray:_tableData];
                [_pullTableView reloadData];
                
                //存储
                MessageDao *messageDao = [[MessageDao alloc] init];
                for(NewBean *bean in _tableData)
                {
                    [messageDao addMeaasgeData:bean];
                }
                
                //_tableData标注为已读
                NSMutableArray *arrayM = [NSMutableArray array];

                for(NewBean *bean in _tableData)
                {
                    [arrayM addObject:bean.sid];
                }
                HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
                [httpClient setUserNewsRead:arrayM];
            }
            //消除未读标记
            if (self.dataDelgate && [self.dataDelgate respondsToSelector:@selector(dataChangedFrom:widthSource:byOpt:)]) {
                [self.dataDelgate dataChangedFrom:self widthSource:nil byOpt:2];
            }
            [ALDUtils hiddenTips:self.view];
        }else if(code==kNO_RESULT){
            _bDataListHasNext = NO;
            //得到缓存的数据
            MessageDao *messageDao = [[MessageDao alloc] init];
            _daoData = [messageDao queryMeaasgeData];
            _allTableData = [NSMutableArray arrayWithArray:_daoData];
//            if(_iPage==1){
//                self.tableData=nil;
//                [self.pullTableView reloadData];
//            }
//            if (!_tableData || _tableData.count < 1){
//                [_pullTableView tableViewDidFinishedLoading];
//                _pullTableView.reachedTheEnd = NO;
//                //[self showTips:[NSString stringWithFormat:@"%@ 下拉刷新！",@"抱歉，暂无会务数据!"]];
//            }else{
//                [ALDUtils hiddenTips:self.view];
//                [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
//                _pullTableView.reachedTheEnd = YES;
//            }
            [_pullTableView reloadData];
            [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
            _pullTableView.reachedTheEnd = YES;
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
