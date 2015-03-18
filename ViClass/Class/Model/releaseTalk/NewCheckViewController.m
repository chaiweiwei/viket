//
//  NewCheckViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/25.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "NewCheckViewController.h"
#import "QuestionBean.h"
#import "HttpClient.h"
#import "AnswerBean.h"
#import "ScoreBean.h"
#import "ALDButton.h"

@interface NewCheckViewController()<UITableViewDataSource,UITableViewDelegate>
{
    
}
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) UITableViewCell *selectCell;
@property (nonatomic,retain) OptionBean *selectBean;

@end
@implementation NewCheckViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    if(!self.num)
        [self loadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(self.num>0)
    {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
}
-(void)initUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    _tableView.backgroundColor = KTableViewBackgroundColor;
    _tableView.dataSource       = self;
    _tableView.delegate         = self;
    _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
}
-(void)loadData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getQuestionList:self.chapterId];
}
#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    QuestionBean *bean = self.tableData[self.num];
    
    return bean.options.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    QuestionBean *bean = self.tableData[self.num];
    
    CGSize size = [ALDUtils captureTextSizeWithText:bean.name textWidth:CGRectGetWidth(self.view.frame)-20 font:kFontSize32px];
    
    return size.height+30+22;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionBean *bean = self.tableData[self.num];
    OptionBean *ob = bean.options[indexPath.row];
    
    CGSize size = [ALDUtils captureTextSizeWithText:ob.name textWidth:CGRectGetWidth(self.view.frame)-35 font:kFontSize32px];
    
    return size.height+30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 75;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        CGFloat cellWidth = CGRectGetWidth(self.view.frame);
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        ALDButton *select = [[ALDButton alloc] initWithFrame:CGRectMake(0 , 0,cellWidth, 44)];
//        select.backgroundColor = [UIColor whiteColor];
//        select.tag = 0x10;
//        [select addTarget:select action:@selector(cellClicked:) forControlEvents:UIControlStateNormal];
//        [cell addSubview:select];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.view.frame)-35, 44)];
        label.textColor = KWordBlackColor;
        label.backgroundColor = [UIColor clearColor];
        label.font = kFontSize32px;
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.tag = 0x11;
        label.numberOfLines = 0;
        [cell addSubview:label];
        
        UIView *cir = [[UIView alloc] initWithFrame:CGRectMake(cellWidth-35, 12, 20, 20)];
        cir.layer.masksToBounds =YES;
        cir.layer.cornerRadius = 10;
        cir.backgroundColor = [UIColor clearColor];
        cir.layer.borderWidth = 1;
        cir.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cir.tag = 0x12;
        [cell addSubview:cir];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43,cellWidth, 0.5)];
        line.backgroundColor = RGBACOLOR(204, 204, 204, 1);
        line.tag = 0x13;
        [cell addSubview:line];
    }
    QuestionBean *qb = self.tableData[self.num];
    OptionBean *ob = qb.options[indexPath.row];
    
    CGSize size = [ALDUtils captureTextSizeWithText:ob.name textWidth:CGRectGetWidth(self.view.frame)-35 font:kFontSize32px];
    
    UILabel *label = (UILabel *)[cell viewWithTag:0x11];
    label.text = ob.name;
    CGRect rect = label.frame;
    rect.size.height = size.height;
    label.frame = rect;
    
    UIView *cir = (UIView *)[cell viewWithTag:0x12];
    rect =cir.frame;
    rect.origin.y = (size.height+10)/2.0;
    cir.frame = rect;
    
    UIView *line = (UIView *)[cell viewWithTag:0x13];
    rect =line.frame;
    rect.origin.y = size.height+29.5;
    line.frame = rect;
    
//    ALDButton *btn = (ALDButton *)[cell viewWithTag:0x10];
//    rect =btn.frame;
//    rect.size.height = size.height+30;
//    btn.frame = rect;
    
    return cell;
}

/**
 *  返回每一组需要显示的头部标题(字符出纳)
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    QuestionBean *bean = self.tableData[self.num];
    
    CGSize size = [ALDUtils captureTextSizeWithText:bean.name textWidth:CGRectGetWidth(self.view.frame)-20 font:kFontSize32px];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), size.height+30+22)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, CGRectGetWidth(self.view.frame)-20, size.height)];
    label.textColor = KWordBlackColor;
    label.font = kFontSize32px;
    label.textAlignment = TEXT_ALIGN_LEFT;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    label.text = bean.name;
    
    UIView *gray = [[UIView alloc] initWithFrame:CGRectMake(0, size.height+30, CGRectGetWidth(self.view.frame), 22)];
    gray.backgroundColor = KTableViewBackgroundColor;
    [view addSubview:gray];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 0.5)];
    line.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    [gray addSubview:line];

    line = [[UIView alloc] initWithFrame:CGRectMake(0, 21.5,CGRectGetWidth(self.view.frame), 0.5)];
    line.backgroundColor = RGBACOLOR(204, 204, 204, 1);
    [gray addSubview:line];
    
    return view;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 75)];
    
    NSString *text;
    if(self.num<_tableData.count-1)
        text = @"下一题";
    else
        text = @"提交";
    ALDButton *btn = [[ALDButton alloc] initWithFrame:CGRectMake(20, 30, CGRectGetWidth(self.view.frame)-40, 45)];
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5;
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btn];
    
    return view;
    
}
-(void)viewClicked:(UIButton *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)clicked:(ALDButton *)sender
{
    if(_selectBean == nil)
    {
        [ALDUtils showToast:@"请选择"];
        return;
    }
    if(_askArrayM == nil)
        _askArrayM = [NSMutableArray array];
    //记录答案
    QuestionBean *bean = _tableData[_num];
    
    NSMutableDictionary *ab = [NSMutableDictionary dictionary];
    [ab setObject:bean.sid forKey:@"questionId"];
    [ab setObject:_selectBean.sid forKey:@"optionId"];
    [_askArrayM addObject:ab];
    
    if (self.num<_tableData.count- 1) {//下一题
        NewCheckViewController *controller = [[NewCheckViewController alloc] init];
        controller.title = [NSString stringWithFormat:@"题目%i",_num+1];
        controller.chapterId = self.chapterId;
        controller.tableData = _tableData;
        controller.num = ++self.num;
        controller.askArrayM = [NSMutableArray arrayWithArray:_askArrayM];
        [self.navigationController pushViewController:controller animated:YES];

    }
    else
    {
        //提交
        HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
        [httpClient sendAnswer:self.chapterId answers:_askArrayM];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *cir;
    if(_selectCell)
    {
        cir = (UIView *)[_selectCell viewWithTag:0x12];
        cir.backgroundColor = [UIColor whiteColor];
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cir = (UIView *)[cell viewWithTag:0x12];
    cir.backgroundColor = [UIColor redColor];
    _selectCell = cell;
    
    QuestionBean *bean = _tableData[_num];
    
    _selectBean = bean.options[indexPath.row];
    
}
-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForQuestionList){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    } if(requestPath==HttpRequestPathForSubmitAsk){
        [ALDUtils addWaitingView:self.view withText:@"练习审阅中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    
    if(requestPath == HttpRequestPathForQuestionList)
    {
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[NSArray class]]){
                
                NSArray *array=(NSArray *)obj;
                _tableData=[NSMutableArray arrayWithArray:array];
                [self.tableView reloadData];
                
            }
        }
    }
    else if(requestPath == HttpRequestPathForSubmitAsk)
    {
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[ScoreBean class]]){
                
                ScoreBean *bean = (ScoreBean *)obj;

                UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
                bgView.backgroundColor = [UIColor whiteColor];
                bgView.alpha = 0.8;
                [self.view addSubview:bgView];
                
                CGFloat height = _tableData.count*40+35+40;
                CGFloat width = CGRectGetWidth(self.view.frame)-40;
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2.0, (CGRectGetHeight(self.view.frame)-64)/2.0, 0, 0)];
                view.layer.masksToBounds = YES;
                view.layer.cornerRadius = 5;
                view.backgroundColor = [UIColor blackColor];
                [bgView addSubview:view];
                
                NSString *text ;
                if(!bean.answered)
                    text = [NSString stringWithFormat:@"答题成功，获得积分%i",bean.integral];
                else
                   text = result.errorMsg;
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width, 35)];
                label.text = text;
                label.font = kFontSize32px;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = KWordWhiteColor;
                [view addSubview:label];
                

                for(int i = 0; i<_tableData.count;i++)
                {
                    //答案
                    NSMutableDictionary *ab = _askArrayM[i];
//                    [ab setObject:bean.sid forKey:@"questionId"];
//                    [ab setObject:_selectBean.sid forKey:@"optionId"];
//                    [_askArrayM addObject:ab];
    
                    QuestionBean *bean = _tableData[i];
                    UIColor *color;
                    for(OptionBean *temp in bean.options)
                    {
                        if([temp.sid isEqualToString:[ab objectForKey:@"optionId"]])
                        {
                            if(temp.correct)
                            {
                                text = [NSString stringWithFormat:@"问题%i 回答正确",i+1];
                                color = [UIColor greenColor];
                            }
                            else
                            {
                                text = [NSString stringWithFormat:@"问题%i 回答错误",i+1];
                                color = [UIColor redColor];
                            }
                            
                            label = [[UILabel alloc] initWithFrame:CGRectMake(10, 35+40*i, width, 40)];
                            label.font = kFontSize32px;
                            label.textAlignment = TEXT_ALIGN_LEFT;
                            label.backgroundColor = [UIColor clearColor];
                            label.textColor = color;
                            label.text = text;
                            [view addSubview:label];
                            break;
                        }
                    }
                    
                }
                
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, height-40, width, 40)];
                [btn setBackgroundColor: [UIColor clearColor]];
                [btn setTitle:@"确定" forState:UIControlStateNormal];
                [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(viewClicked:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
                
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, height-40,CGRectGetWidth(self.view.frame), 0.5)];
                line.backgroundColor = KWordWhiteColor;
                [view addSubview:line];
                
                [UIView animateWithDuration:0.6 animations:^{
                    CGRect frame = view.frame;
                    frame.size.height = height;
                    frame.size.width = width;
                    view.frame = frame;
                    
                    CGPoint point = view.frame.origin;
                    view.center = point;
                    
                }];
                
            }
        }
    }
    [ALDUtils removeWaitingView:self.view];
}

@end
