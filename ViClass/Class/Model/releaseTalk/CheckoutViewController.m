//
//  CheckoutViewController.m
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/16.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "CheckoutViewController.h"
#import "QuestionBean.h"
#import "HttpClient.h"
#import "AnswerBean.h"
#import "ScoreBean.h"

@interface CheckoutViewController()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL subAndcheck;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,retain) NSArray *tableData;
@property (nonatomic,retain) QuestionBean *selectedBean;
@property (nonatomic,retain) NSMutableArray *anskArray;//提交的答案数组
@property (nonatomic,retain) NSMutableArray *selectAnskArray;//选择的答案数组
@property (nonatomic,retain) UILabel *scoreText;
@property (nonatomic,retain) UIButton *submitBtn;
@end

@implementation CheckoutViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgImg"]];
    
    CGRect frame                    = self.view.frame;
    frame.size.height -= 15+30;
    
    _tableView                  = [[UITableView alloc] initWithFrame:frame];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource       = self;
    _tableView.delegate         = self;
    _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor clearColor];
    // 每一行cell的高度
    _tableView.rowHeight = 40;
    // 每一组头部控件的高度
    _tableView.sectionHeaderHeight = 44;
    [self.view addSubview:_tableView];
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-70-15, CGRectGetHeight(self.view.frame)-15-30-64, 70, 30)];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submit.backgroundColor = [UIColor redColor];
    submit.layer.masksToBounds = YES;
    submit.layer.cornerRadius = 3;
    [submit addTarget:self action:@selector(submitAns) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submit];
    _submitBtn = submit;
    
    //
    UILabel *score = [[UILabel alloc] init];
    score.frame = CGRectMake(10, CGRectGetHeight(self.view.frame)-15-30-64, CGRectGetWidth(self.view.frame)-80, 30);
    score.textAlignment = TEXT_ALIGN_LEFT;
    score.textColor = KWordWhiteColor;
    score.font = kFontSize32px;
    score.backgroundColor = [UIColor clearColor];
    _scoreText = score;
    score.hidden = YES;
    [self.view addSubview:score];
    
    [self loadData];

}
-(void)loadData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getQuestionList:self.chapterId];
}
-(void)submitAns
{
    if([_submitBtn.titleLabel.text isEqualToString:@"提交"])
    {
        int i=1;
        if(_anskArray == nil || _anskArray.count<=0)
        {
            [ALDUtils showToast:[NSString stringWithFormat:@"请完成答题"]];
            return;
        }
        for(NSMutableDictionary *bean in _anskArray)
        {
            if([[bean objectForKey:@"questionId"] isEqualToString:@"0"])
            {
                [ALDUtils showToast:[NSString stringWithFormat:@"第%i题没有回答完整",i]];
                return;
            }
            i++;
        }
        subAndcheck = YES;
        HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
        [httpClient sendAnswer:self.chapterId answers:_anskArray];
    }
    else if([_submitBtn.titleLabel.text isEqualToString:@"重做"])
    {
        [_anskArray removeAllObjects];
        
        _scoreText.hidden = YES;
        
        [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
        
        subAndcheck = NO;
        for(QuestionBean *bean in _tableData)
        {
            bean.selectedAsk = @"";
        }
        [_tableView reloadData];
    }

}
#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    QuestionBean *bean = self.tableData[section];
    
    return (bean.isOpened ? bean.options.count: 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
//        cell.layer.masksToBounds = YES;
//        cell.layer.cornerRadius = 3;
//        cell.layer.borderWidth = 1;
//        cell.layer.borderColor = [UIColor orangeColor].CGColor;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(11, 0, CGRectGetWidth(self.view.frame)-22, 34)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 2;
        view.alpha = 0.3;
        [cell addSubview:view];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.view.frame)-20, 35)];
        label.textColor = [UIColor whiteColor];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 2;
        label.layer.borderWidth = 1;
        label.layer.borderColor = [UIColor clearColor].CGColor;
        label.tag = 0x10;
        [cell addSubview:label];
    }
    QuestionBean *qb = self.tableData[indexPath.section];
    OptionBean *ob = qb.options[indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:0x10];
    label.text = ob.name;
    if(subAndcheck && ob.correct)
    {
        label.textColor = [UIColor greenColor];
    }
    return cell;
}

/**
 *  返回每一组需要显示的头部标题(字符出纳)
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    QuestionBean *bean = self.tableData[section];
    NSArray *options = bean.options;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 3;
    [view setBackgroundColor:[UIColor clearColor]];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(view.frame)-20, 35)];
    [button addTarget:self action:@selector(headerViewDidClickedNameView:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    button.tag = section;
    [view addSubview:button];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(button.frame), 35)];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.text = bean.name;
    title.textAlignment = TEXT_ALIGN_LEFT;
    [button addSubview:title];
    
    UILabel *ask = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(button.frame)-10, 35)];
    ask.textColor = [UIColor whiteColor];
    
    NSString *text = bean.selectedAsk?bean.selectedAsk:@"";
    //记录答案
    if(subAndcheck && _selectAnskArray == nil)
    {
        _selectAnskArray = [NSMutableArray array];
    }
    [_selectAnskArray addObject:text];
    
    //提交后的验证
    if(subAndcheck)
    {
        //判断是否正确 改变内容和颜色
        int selectMask;
        if([text isEqualToString:@"A"])
            selectMask = 0;
        else if([text isEqualToString:@"B"])
            selectMask = 1;
        else if([text isEqualToString:@"C"])
            selectMask = 2;
        else if([text isEqualToString:@"D"])
            selectMask = 3;
        else if([text isEqualToString:@"E"])
            selectMask = 4;
        else if([text isEqualToString:@"F"])
            selectMask = 5;
        else if([text isEqualToString:@"G"])
            selectMask = 6;

        OptionBean *ob = options[selectMask];
        if(!ob.correct)
           text = @"错误";
    }
    ask.text = text;
    ask.textAlignment = TEXT_ALIGN_Right;
    [button addSubview:ask];
    

    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 38, CGRectGetWidth(view.frame)-20, 1)];
    line.backgroundColor = [UIColor whiteColor];
    line.alpha = 0.3;
    [view addSubview:line];
    
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionBean *bean = self.selectedBean;
    OptionBean *ob = bean.options[indexPath.row];
    
    NSString *abcd;
    switch (indexPath.row+1) {
        case 1:
            abcd = @"A";
            break;
        case 2:
            abcd = @"B";
            break;
        case 3:
            abcd = @"C";
            break;
        case 4:
            abcd = @"D";
            break;
        case 5:
            abcd = @"E";
            break;

        case 6:
            abcd = @"F";
            break;

        case 7:
            abcd = @"G";
            break;

        default:
            break;
    }
    bean.selectedAsk = [NSString stringWithFormat:@"%@",abcd];
    //选择后关闭选项
    self.selectedBean.opened = 0;
    
    //记录答案
    NSMutableDictionary *ab = [NSMutableDictionary dictionary];
    [ab setObject:bean.sid forKey:@"questionId"];
    [ab setObject:ob.sid forKey:@"optionId"];
    
    if(_anskArray == nil)
    {
        NSMutableDictionary *test = [NSMutableDictionary dictionary];
        [test setObject:@"0" forKey:@"questionId"];
        
        _anskArray = [NSMutableArray arrayWithCapacity:bean.options.count];
        for(int i =0;i<_tableData.count;i++)
        {
            [_anskArray addObject:test];
        }
    }
    [_anskArray replaceObjectAtIndex:indexPath.section withObject:ab];
    
    [self.tableView reloadData];
}
#pragma mark - headerView的代理方法
/**
 *  点击了headerView上面的名字按钮时就会调用
 */
- (void)headerViewDidClickedNameView:(UIButton *)sender
{
    if(self.selectedBean.opened == 1)
        self.selectedBean.opened = 0;
    QuestionBean *bean = self.tableData[sender.tag];
    self.selectedBean = bean;
    // 1.修改组模型的标记(状态取反)
    self.selectedBean.opened = !self.selectedBean.isOpened;
    
    [self.tableView reloadData];
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
                if(!bean.answered)
                    [ALDUtils showToast:[NSString stringWithFormat:@"答题成功，获得积分%i",bean.integral]];
                else
                    [ALDUtils showToast:result.errorMsg];
                
                _scoreText.text = [NSString stringWithFormat:@"答对题数:%i  最终成绩：%i",bean.correctCount,bean.score];
                _scoreText.hidden = NO;
                
                //改变按钮的类型颜色
                if([_submitBtn.titleLabel.text isEqualToString:@"提交"])
                {
                    [_submitBtn setTitle:@"重做" forState:UIControlStateNormal];
                }
                //改变颜色
                [_tableView reloadData];
            }
        }
    }
    [ALDUtils removeWaitingView:self.view];
}
@end
