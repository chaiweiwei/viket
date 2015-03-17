//
//  TestViewController.m
//  Vike_1018
//
//  Created by chaiweiwei on 14/11/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "TestViewController.h"
#import "QuestionBean.h"
#import "WorkViewController.h"

#define MPlayHeight 200
#define TabViewHeight 50
@interface TestViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    WorkViewController *workViewController;
    UIView *bgView;
    
    BOOL _isShow;
}
@property (nonatomic,retain) UITableView *myTableView; //表格
@property (nonatomic,retain) NSMutableArray *tableExamData;
@property (nonatomic,retain) NSMutableArray *tableExerciseData;

@end

@implementation TestViewController
-(void) setViewShowing:(BOOL) isShow{
    if (!_isShow) {
        [self performSelectorInBackground:@selector(initData) withObject:nil];
    }
    _isShow=isShow;
}
-(void)initData
{
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
    //[self getLocalData];
}
-(void)setClassId:(int)classId
{
    _classId = classId;
    //[self getLocalData];
}
-(void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    
    CGFloat startY=0.0f;
    UITableView *pullTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, startY, viewWidth,viewHeigh- MPlayHeight - 36- TabViewHeight) style:UITableViewStylePlain];
    pullTableView.dataSource=self;
    pullTableView.delegate=self;
    pullTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:pullTableView];
    self.myTableView=pullTableView;
    
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
//    CourseModel *bean = [[CourseModel alloc] init];
//    bean.courseName = @"概述";
//    
//    CourseModel *bean2 = [[CourseModel alloc] init];
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
//    NSString *fileName = [NSString stringWithFormat:@"ExamByClassID%i.plist",_classId];
//    NSArray *files =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *file = files[0];
//    NSString *filePath = [file stringByAppendingPathComponent:fileName];
//    BOOL ifFind = [fileManager fileExistsAtPath:filePath];
//    if(ifFind)
//    {
//        //全部的课程
//        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        ExamModel *bean;
//        QuestionModel *quest;
//        NSMutableArray *arrayM = [NSMutableArray array];
//        for(NSDictionary *item  in dic[@"List"])
//        {
//            if(bean == nil || bean.examID != [item[@"ExamID"] intValue])
//            {
//                //拿到其中的exercise的字段
//                //先赋值前一个数组  更新后赋值新的数组 进行下一轮
//                bean.questArray = arrayM;
//                
//                bean = [ExamModel itemWithDict:item];
//                if(_tableExamData == nil)
//                {
//                    _tableExamData = [NSMutableArray array];
//                }
//                [_tableExamData addObject:bean];
//                
//                arrayM = [NSMutableArray array];
//            }
//            //完整的问题模型
//            quest = [QuestionModel itemWithDict:item];
//            [arrayM addObject:quest];
//        }
//        bean.questArray = arrayM;
//
//    }
//    
//    //本地数据
//    fileName = [NSString stringWithFormat:@"ExerciseQuestByClassID%i.plist",_classId];
//    files =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    file = files[0];
//    filePath = [file stringByAppendingPathComponent:fileName];
//    
//    if(filePath)
//    {
//        //全部的课程
//        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        ExerciseModel *bean;//将相同
//        QuestionModel *quest;
//        NSMutableArray *arrayM = [NSMutableArray array];
//        for(NSDictionary *item  in dic[@"List"])
//        {
//            if(bean == nil || bean.exerciseID != [item[@"ExerciseID"] intValue])
//            {
//                //拿到其中的exercise的字段
//                //先赋值前一个数组  更新后赋值新的数组 进行下一轮
//                bean.questArray = arrayM;
//                
//                bean = [ExerciseModel itemWithDict:item];
//                if(_tableExerciseData == nil)
//                {
//                    _tableExerciseData = [NSMutableArray array];
//                }
//                [_tableExerciseData addObject:bean];
//                
//                arrayM = [NSMutableArray array];
//            }
//            //完整的问题模型
//            quest = [QuestionModel itemWithDict:item];
//            [arrayM addObject:quest];
//        }
//        bean.questArray = arrayM;
//    }
//}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(!_tableExamData&&!_tableExerciseData&&_tableExamData.count<=0&&_tableExerciseData.count<=0)
    {
        bgView.hidden = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    bgView.hidden = YES;
    return 2;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%@",self.tableExamData);
    NSLog(@"%@",self.tableExerciseData);
    if(section == 1)
        return self.tableExamData.count;
    return self.tableExerciseData.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"课后练习";
    return @"测试";
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
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
       
        // 作业名称
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 12, cellWidth-startX, 20.0f)];
        label.tag=0x12;
        label.textColor=KWordBlackColor;
        label.font=[UIFont systemFontOfSize:12.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
    }
//    if(indexPath.section == 0)
//    {
//        ExerciseModel *exercise=[self.tableExerciseData objectAtIndex:indexPath.row];
//        //标记
//        UILabel *label=(UILabel *)[cell viewWithTag:0x12];
//        NSString *text=[NSString stringWithFormat:@"%@",exercise.exerciseName];
//        label.text=text;
//    }
//    else if(indexPath.section == 1)
//    {
//        ExamModel *exam=[self.tableExamData objectAtIndex:indexPath.row];
//        //标记
//        UILabel *label=(UILabel *)[cell viewWithTag:0x12];
//        NSString *text=[NSString stringWithFormat:@"%@",exam.examName];
//        label.text=text;
//    }
    return cell;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell.backgroundColor= RGBCOLOR(41,206,66);
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    ClassNewsTabViewController *controller =(ClassNewsTabViewController *)self.parentController;
//    if(indexPath.section == 0)
//    {
//        currExercise = self.tableExerciseData[indexPath.row];
//        [controller selecedCell:SelecedWorkType ID:currExercise];
//    }
//    if(indexPath.section == 1)
//    {
//        currExam = self.tableExamData[indexPath.row];
//        [controller selecedCell:SelecedWorkType ID:currExam];
//    }
    //[self.parentController performSegueWithIdentifier:@"toWork" sender:self];
    
}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    id vc = segue.destinationViewController;
//    if([vc isKindOfClass:[WorkViewController class]])
//    {
//        workViewController = vc;
//        //得到选中模型
//        if(currExam != nil)
//            workViewController.lblTestName.text = currExam.examName;
//        else
//            workViewController.lblTestName.text = currExercise.exerciseName;
//    }
//}
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
