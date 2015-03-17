#import "DetailViewController.h"
#import "ChapterBean.h"

#define MPlayHeight 180
#define TabViewHeight 36
@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    ChapterBean *currCourse;
    UIView *bgView;//底部的图片
}

@property (nonatomic,retain) NSMutableArray *tableData;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    //[self getLocalData];
    ChapterBean *item = self.tableData[0];

   // item.commentList= [self getCommentData:item.courseID];
    if([self.delegate respondsToSelector:@selector(courseChange:)])
    {
        //默认选中第一项
        [self.delegate courseChange:self.tableData[0]];
    }
}
-(void)initUI
{
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    
    CGFloat startY=0.0f;
    UITableView *pullTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, startY, viewWidth,viewHeigh- MPlayHeight - 64 - TabViewHeight) style:UITableViewStylePlain];
    pullTableView.dataSource=self;
    pullTableView.delegate=self;
    pullTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:pullTableView];
    self.myTableView=pullTableView;
    self.myTableView.backgroundColor = [UIColor clearColor];
    
    //在底部增加没有数据的图片
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    [self.view addSubview:bgView];
    
    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noOrder"]];
    bgImg.frame = CGRectMake((CGRectGetWidth(self.view.frame)-107)/2.0f, 20, 107, 90);
    [bgView addSubview:bgImg];
    // 文字
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, CGRectGetMaxY(bgImg.frame)+10, CGRectGetWidth(self.view.frame), 40);
    label.text = @"对不起，没有数据，后台正在努力载入中.";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0f];
    [bgView addSubview:label];
}
#pragma mark - 加载数据
-(void)loadData
{
//    ChapterBean *bean = [[CourseModel alloc] init];
//    bean.courseName = @"概述";
//    
//    ChapterBean *bean2 = [[CourseModel alloc] init];
//    bean2.courseName = @"物理层";
//    
//    CourseModel *bean3 = [[CourseModel alloc] init];
//    bean3.courseName = @"数据链路层";
//    
//    self.tableData = [NSMutableArray arrayWithObjects:bean,bean2,bean3,bean,bean2,bean3,bean,bean2,bean3, nil];
}
//#pragma mark - 本地读取所有的课堂数据
//-(void)getLocalData
//{
//    //本地数据
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *fileName = [NSString stringWithFormat:@"CourseByClassID%i.plist",_classId];
//    NSArray *files =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *file = files[0];
//    NSString *filePath = [file stringByAppendingPathComponent:fileName];
//    BOOL ifFind = [fileManager fileExistsAtPath:filePath];
//    //有问题 要判断文件在不在
//    if(ifFind)
//    {
//        //全部的课程
//        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        CourseModel *bean;
//        for(NSDictionary *item  in dic[@"List"])
//        {
//             bean = [CourseModel itemWithDict:item];
//            if(_tableData == nil)
//            {
//                _tableData = [NSMutableArray array];
//            }
//            [_tableData addObject:bean];
//        }
//    }
//    if(_tableData && _tableData.count>0 )
//    {
//        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        bgView.hidden = YES;
//    }
//    else
//    {
//        self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        bgView.hidden = NO;
//    }
//    
//}
//-(NSMutableArray *)getCommentData:(int)courseID
//{
//    
//    NSMutableArray *arrayM = [NSMutableArray array];
//    
//    
//    //本地数据
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *fileName = [NSString stringWithFormat:@"CommentByClassID%i.plist",courseID];
//    NSArray *files =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *file = files[0];
//    NSString *filePath = [file stringByAppendingPathComponent:fileName];
//    BOOL ifFind = [fileManager fileExistsAtPath:filePath];
//    //有问题 要判断文件在不在
//    if(ifFind)
//    {
//        
//        //全部的课程
//        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        ComentModel *bean;
//        for(NSDictionary *item  in dic[@"List"])
//        {
//            bean = [ComentModel itemWithDict:item];
//            [arrayM addObject:bean];
//        }
//    }
//    return arrayM;
//}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell=@"CouesrCell";
    CGFloat cellWidth;
    UITableViewCell *cell=[tableView dequeueReusableHeaderFooterViewWithIdentifier:strCell];

    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        cellWidth=CGRectGetWidth(cell.frame);
        
        CGFloat startX=10.0f;
        //播放logo
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(startX, 12, 17, 17)];
        imgView.tag=0x11;
        imgView.image=[UIImage imageNamed:@"ico_playing"];
        imgView.layer.masksToBounds=YES;
        imgView.layer.cornerRadius=20.0f;
        imgView.backgroundColor=[UIColor clearColor];
        [cell addSubview:imgView];
        
        startX+=27.0f;
        //课程名称  要改长度
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 12, cellWidth-startX, 20.0f)];
        label.tag=0x12;
        label.textColor=KWordBlackColor;
        label.font=[UIFont systemFontOfSize:12.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
    }
    
    ChapterBean *course=[self.tableData objectAtIndex:indexPath.row];
    //标记
    UILabel *label=(UILabel *)[cell viewWithTag:0x12];
    NSString *text=[NSString stringWithFormat:@"[第%li集] %@",indexPath.row + 1,course.name];
    label.text=text;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor= RGBCOLOR(255,193,46);
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    ClassNewsTabViewController *controller =(ClassNewsTabViewController *)self.parentController;
//    
//    currCourse = self.tableData[indexPath.row];
//    //这个是视频播放的控制
//    [controller selecedCell:SelecedCourseType ID:currCourse];
//    //评论控制
//    [currCourse.commentList removeAllObjects];
//    //currCourse.commentList =[self getCommentData:currCourse.courseID];
//    if([self.delegate respondsToSelector:@selector(courseChange:)])
//    {
//        //默认选中第一项
//        [self.delegate courseChange:currCourse];
//    }
    
    
}
-(UIView *)createLine:(CGRect)frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    return line;
}

-(UIButton *) createBtn:(CGRect )frame title:(NSString *)title
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=frame;
    btn.backgroundColor=[UIColor clearColor];
    
    return btn;
}
-(CGRect)getStringRect:(NSString *)text
{
    //-------------得到字符串的长度-----------//
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: [UIFont systemFontOfSize:12.0f], NSParagraphStyleAttributeName:paragraphStyle.copy
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width - 80, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    ////--------------------------//
    return rect;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
