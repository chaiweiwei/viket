//
//  AllCourseViewController.m
//  Vike_1018
//
//  Created by chaiweiwei on 14/11/17.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "AllCourseViewController.h"
#import "ClassRoomBean.h"
#import "UIViewExt.h"
#import "POAPinyin.h"
#import "ClassListViewController.h"
#import "HttpClient.h"
#import "CategoryBean.h"
#import "ALDImageView.h"
#import "ALDButton.h"

@interface AllCourseViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,DataLoadStateDelegate,PullingRefreshTableViewDelegate>
{
    NSMutableArray *choose;
    NSMutableArray *classData;
    NSMutableArray *filterData;//过滤后的课程数据
    
    NSMutableArray *classSearchList;
    NSMutableArray *nameList;//搜索到的名称列表
    
    UIView *markView;
    CGFloat markStartX;//标记一下标签的起始位置
    CGFloat markStartY;//标记一下标签的起始位置
    NSString *keyWord;//关键词
}
@property (nonatomic,strong) PullingRefreshTableView *tableView;//下面的课程所有列表
@property (nonatomic,strong) UITextField *searchText;
@property (assign, nonatomic) int selecedID; //页面
@property (retain,nonatomic) NSMutableArray *tableData;
@property (nonatomic,retain) ALDButton *selectedMaskBtn;
@end

@implementation AllCourseViewController
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchText = [[UITextField alloc] initWithFrame:CGRectMake(49, 7, 230, 30)];
    _searchText.borderStyle = UITextBorderStyleRoundedRect;
    _searchText.delegate = self;
    _searchText.returnKeyType = UIReturnKeySearch;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filtere) name:UITextFieldTextDidChangeNotification object:_searchText];
//    
    self.navigationItem.titleView = _searchText;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cencel:)];
    self.navigationItem.rightBarButtonItem = item;

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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _selectedMaskBtn.selected = NO;
    
    [textField resignFirstResponder];
    //检索关键字
    [self removeAndLoad:textField.text];
    return YES;
}
-(void)removeAndLoad:(NSString *)key
{
    if(_tableData)
    {
        _tableData = nil;
    }
    keyWord = key;
    [self loadSubData];
}
-(void)loadSubData
{
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
   [httpClient getrSubjectList:_iPage pageCount:_iPageSize keyword:keyWord categoryId:nil hot:0 top:0 new:0];
}
//- (void)filtere
//{
//    NSMutableArray *result = [NSMutableArray array];
//    NSMutableArray *pyData = [[NSMutableArray alloc] init];
//    NSLog(@"%@",self.searchText.text);
//    NSString *text = [POAPinyin stringConvert:self.searchText.text];
//    if([self.searchText.text length] == 0)
//    {
//        nameList = [NSMutableArray arrayWithArray:classSearchList];
//        [self.tableView reloadData];
//    }
//    else
//    {
//        // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '.*%@.*'",text];
//        //将data中的汉字数组全部转换成拼音数组 过滤
//        for(NSString *name in classSearchList)
//        {
//            NSString *pyName = [POAPinyin stringConvert:name];
//            NSLog(@"%@",pyName);
//            [pyData addObject:pyName];
//        }
//        for(int i=0;i<pyData.count;i++)
//        {
//            NSLog(@"%i",pyData.count);
//            NSRange range = [pyData[i] rangeOfString:text];
//            if(range.location != NSNotFound)
//            {
//                //找到了
//                [result addObject:classSearchList[i]];
//            }
//        }
//        nameList = result;
//        int i = 0;
//        if(nameList&& nameList.count >0)
//        {
//            [filterData removeAllObjects];
//            for(ClassRoomBean *item in classData)
//            {
//                if([nameList[i] isEqualToString:item.name])
//                {
//                    [filterData addObject:item];
//                }
//            }
//            [self.tableView reloadData];
//        }
//    }
//}

-(void)cencel:(UIBarButtonItem *)sender
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
}
-(void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat startX=10.0f;
    //创建标签view
    markView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth,200)];
    //您感兴趣的标签
    UILabel *label = [self createLabel:CGRectMake(startX, 10, viewWidth, 20) textColor:KWordGrayColor textFont:[UIFont systemFontOfSize:14]];
    label.text = @"类型";
    markView.backgroundColor = [UIColor whiteColor];
    [markView addSubview:label];
    markStartX = 10.0f;
    
    //创建类型view中的标签
    for(CategoryBean *bean in choose)
    {
        ALDButton *btn = [self createMarkBtn:CGRectMake(markStartX, markStartY, 40, 30) bean:bean tag:0x11];
        [markView addSubview:btn];
        btn = [markView.subviews lastObject];
        markStartX = CGRectGetMaxX(btn.frame); 
    }
    CGRect temp = markView.frame;
    UIButton *btn = [markView.subviews lastObject];
    temp.size.height = CGRectGetMaxY(btn.frame) + 10;
    markView.frame = temp;
    //下划线
    UIView *line = [self createLine:CGRectMake(0, temp.size.height, viewWidth, 1)];
    [markView addSubview:line];
    //绘制列表
    _tableView                  = [[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, self.view.frame.size.height) pullingDelegate:self];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource       = self;
    _tableView.delegate         = self;
    _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = KTableViewBackgroundColor;
    [self.view addSubview:_tableView];
    _tableView.tableHeaderView = markView;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
   
}

-(void)loadData
{
//    NSString *str1 = @"计算机网络";
//    NSString *str2 = @"信息安全";
//    NSString *str3 = @"数据结构";
//    NSString *str4 = @"计算机语言";
//    choose = [NSMutableArray arrayWithObjects:str1,str2,str3,str4, nil];
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getClassCategory];
}
#pragma mark - Scroll Action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView tableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.tableView tableViewDidEndDragging:scrollView];
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
    [self loadSubData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MainCell"];
        
        CGFloat cellView = self.view.width;
        
        ALDImageView *imageView = [[ALDImageView alloc] initWithFrame:CGRectMake(10, 15, 145, 80)];
        imageView.defaultImage = [UIImage imageNamed:@"class_default"];
        imageView.imageUrl = @"";
        imageView.tag = 0x0010;
        [cell addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+15, imageView.top,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize30px;
        label.textColor = KWordBlackColor;
        label.tag = 0x0011;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+15, label.bottom+10,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize28px;
        label.textColor = KWordGrayColor;
        label.tag = 0x0012;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.right+15, label.bottom+5,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize28px;
        label.textColor = KWordGrayColor;
        label.tag = 0x0013;
        [cell addSubview:label];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(label.right+15, label.right+15,cellView-145-15 , 15)];
        label.textAlignment = TEXT_ALIGN_LEFT;
        label.font = kFontSize28px;
        label.textColor = [UIColor redColor];
        label.tag = 0x0014;
        [cell addSubview:label];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 109, cell.width-30, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:line];
        
    }
    ClassRoomBean *bean = _tableData[indexPath.row];
    
    ALDImageView *img = (ALDImageView *)[cell viewWithTag:0x0010];
    img.imageUrl =bean.logo;
    
    UILabel *label = (UILabel *)[cell viewWithTag:0x0011];
    label.text = bean.name;
    
    label = (UILabel *)[cell viewWithTag:0x0012];
    label.text = [NSString stringWithFormat:@"分类: %@",bean.categoryName];
    
    label = (UILabel *)[cell viewWithTag:0x0013];
    label.text = [NSString stringWithFormat:@"集数 : %i",bean.chapterCount];
    
    CGSize size = [ALDUtils captureTextSizeWithText:label.text textWidth:200 font:kFontSize28px];
    UILabel *tag = (UILabel *)[cell viewWithTag:0x0014];
    tag.frame = CGRectMake(label.left+size.width+5,label.top, 200, 15);
    tag.text = bean.status ? @"已完结":@"未完结";


    
    //    ClassRoomModel *item = classData[indexPath.row];
    //    cell.classTitle.text = item.className;
    //    cell.leibie.text = item.typeString;
    //    cell.courseCount.text = [NSString stringWithFormat:@"%i",item.courseCount];
    //    cell.lblIfFinished.text = item.ifFinished ? @"已完结":@"未完结";
    //    NSString *str = [NSString stringWithFormat:@"%@/ClassRoom/%@/%@",SourseUrl,item.classImagePath,item.classImageName];
    //    NSURL *url = [NSURL URLWithString:str];
    //    [cell.classIcon setImageWithURL:url placeholderImage:[UIImage imageNamed:@"bg1"]];
    

    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ClassRoomBean *bean = _tableData[indexPath.row];
    
    ClassListViewController *controller = [[ClassListViewController alloc] init];
    controller.title = @"详细";
    controller.courseId = bean.sid;
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = KTableViewBackgroundColor;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(UIView *)createGrayView:(CGRect) frame
{
    UIView *line=[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
    line.backgroundColor=kLineColor;
    
    UIView *grayView=[[UIView alloc] initWithFrame:frame];
    grayView.backgroundColor=RGBCOLOR(240, 240, 240);
    [grayView addSubview:line];
    
    line=[[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-0.5, frame.size.width, 0.5)];
    line.backgroundColor=kLineColor;
    [grayView addSubview:line];
    
    return grayView;
}

-(UIView *)createLine:(CGRect) frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
}
-(void)clickBtn:(UIButton *)sender
{
}
//点击筛选标签
-(void)clickMarkBtn:(ALDButton *)sender
{
    _searchText.text = @"";
    
    CategoryBean *bean = [sender.userInfo objectForKey:@"data"];
    
    _selectedMaskBtn.selected = NO;
    sender.selected = YES;
    _selectedMaskBtn = sender;
    
    
    //过滤 选中的按钮
    if(_tableData)
    {
        _tableData = nil;
    }
    HttpClient *httpClient = [HttpClient httpClientWithDelegate:self];
    [httpClient getrSubjectList:_iPage pageCount:_iPageSize keyword:nil categoryId:bean.sid hot:0 top:0 new:0];
    
}
#pragma mark - 封装
-(UILabel *)createLabel:(CGRect) frame textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.textColor=textColor;
    label.font=textFont;
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor=[UIColor clearColor];
    
    return label;
}
#pragma mark - 创建标签按钮
-(ALDButton *)createMarkBtn:(CGRect )frame bean:(CategoryBean *)bean tag:(NSInteger) tag
{
    CGSize size = [bean.name sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    CGFloat minWidth = CGRectGetWidth(self.view.frame) - 20 - CGRectGetMaxX(frame);
    if(size.width > minWidth)
    {
        markStartY ++;//换行
        markStartX = 10;
    }
    btn.frame = CGRectMake(markStartX + 10, markStartY * 32 + 30, size.width + 20,frame.size.height);
    [btn setTitle:bean.name forState:UIControlStateNormal];
    btn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 10);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateSelected];
    [btn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
    
    UIImage *image = [self resizedImage:@"bg_biaoqian"];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    image = [self resizedImage:@"bg_biaoqian_select"];
    [btn setBackgroundImage:image forState:UIControlStateSelected];

    btn.adjustsImageWhenHighlighted = NO;
    btn.backgroundColor=[UIColor clearColor];
    btn.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    btn.tag=tag;
    btn.userInfo = [NSDictionary dictionaryWithObject:bean forKey:@"data"];
    
    [btn addTarget:self action:@selector(clickMarkBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

#pragma  mark - 图片拉伸
-(UIImage *)resizedImage:(NSString *)imgName
{
    UIImage *image = [UIImage imageNamed:imgName];
    return [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
}
-(void)getTypeStringListCallBack:(NSMutableArray *)list
{
    if(list != nil && list.count > 0)
    {
        choose = list;
    }
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath{
    if(requestPath==HttpRequestPathForCategoryList){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }if(requestPath==HttpRequestPathForSubjectList){
        [ALDUtils addWaitingView:self.view withText:@"数据检索中,请稍候..."];
    }
}
-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result{
    if(requestPath == HttpRequestPathForCategoryList)
    {
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[NSArray class]]){
                
                choose = [NSMutableArray arrayWithArray:obj];
                
                [self initUI];
            }
            [ALDUtils hiddenTips:self.view];
        }
    }else if(requestPath==HttpRequestPathForSubjectList){
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
                    [_tableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                    _tableView.reachedTheEnd = YES;
                }else{
                    [_tableView tableViewDidFinishedLoading];
                    _tableView.reachedTheEnd = NO;
                }
                [_tableView reloadData];
            }
            [ALDUtils hiddenTips:self.view];
        }else if(code==kNO_RESULT){
            _bDataListHasNext = NO;
            if(_iPage==1){
                self.tableData=nil;
                [_tableView reloadData];
            }
            if (!_tableData || _tableData.count < 1){
                [_tableView tableViewDidFinishedLoading];
                _tableView.reachedTheEnd = NO;
                
                [ALDUtils showToast:@"抱歉，无数据"];
                
            }else{
                [ALDUtils hiddenTips:self.view];
                [_tableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                _tableView.reachedTheEnd = YES;
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
                [ALDUtils showToast:@"网络异常，请确认是否已连接!"];
            }
            [_tableView tableViewDidFinishedLoading];
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
            [_tableView tableViewDidFinishedLoading];
            _tableView.reachedTheEnd = YES;
            if (_iPage>1) {
                _iPage--;
            }
        }
    }

    [ALDUtils removeWaitingView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
