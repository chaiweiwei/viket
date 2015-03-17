//
//  CommentViewController.m
//  Vike_1018
//
//  Created by chaiweiwei on 14/11/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "CommentViewController.h"
#import "CustomBean.h"
#import "CommentBean.h"
#import "DetailViewController.h"

#define MPlayHeight 180
#define TabViewHeight 36
@interface CommentViewController ()<UITableViewDataSource,UITableViewDelegate,DetailViewDelegate>
{
    UIView *bgView;
}

@property (nonatomic,retain) UITableView *myTableView; //表格
@property (nonatomic,retain) NSMutableArray *tableData;

@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];
   // [self loadData];
}
-(void)initUI
{
    
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    
    CGFloat startY=0.0f;
    UITableView *pullTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, startY, viewWidth,viewHeigh- MPlayHeight - 110 - TabViewHeight) style:UITableViewStylePlain];
    pullTableView.dataSource=self;
    pullTableView.delegate=self;
    pullTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    pullTableView.backgroundColor=[UIColor clearColor];
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
    label.text = @"快抢沙发吧";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16.0f];
    [bgView addSubview:label];
}
-(void)courseChange:(ChapterBean *)selectedCourse
{
    self.tableData = selectedCourse.name;
    //[self getLocalData:selectedCourse.courseID];
    
    [self.myTableView reloadData];
}
//#pragma mark - 加载数据
//-(void)loadData
//{
//    ComentModel *bean = [[ComentModel alloc] init];
//    bean.customName = @"张三";
//    bean.createTime = @"2014-11-02";
//    bean.info = @"单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed单位的味道dedededed";
//    
//    ComentModel *bean2 = [[ComentModel alloc] init];
//    bean2.customName = @"张三";
//    bean2.createTime = @"2014-11-02";
//    bean2.info = @"单位的味道dedededed单位的";
//    
//    self.tableData = [NSMutableArray arrayWithObjects:bean,bean2,bean,bean,bean2, nil];
//}
-(void)getLocalData:(int)courseID
{
//    if(_tableData == nil)
//    {
//        _tableData = [NSMutableArray array];
//    }
//    //清除之前的数据
//    [_tableData removeAllObjects];
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
//        CommentBean *bean;
//        for(NSDictionary *item  in dic[@"List"])
//        {
//            bean = [CommentBean itemWithDict:item];
//            [_tableData addObject:bean];
//        }
//    }
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.tableData||self.tableData.count<=0)
    {
        bgView.hidden = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    bgView.hidden = YES;
    return self.tableData.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentBean *comment=[self.tableData objectAtIndex:indexPath.row];
    NSString *text = comment.content;
    
    CGRect rect = [self getStringRect:text];

    CGSize textSize = rect.size;
    if(textSize.height < 64)
        return 64.0f;
    else
        return 42 + textSize.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell=@"CommentCell";
    CGFloat cellWidth;
    UITableViewCell *cell=[tableView dequeueReusableHeaderFooterViewWithIdentifier:strCell];
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        
        cellWidth=CGRectGetWidth(cell.frame);
        
        CGFloat startX=10.0f;
        //头像
        UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(startX, 12, 40, 40)];
        imgView.tag=0x11;
        imgView.image=[UIImage imageNamed:@"user_default"];
        imgView.layer.masksToBounds=YES;
        imgView.layer.cornerRadius=20.0f;
        imgView.backgroundColor=[UIColor clearColor];
        [cell addSubview:imgView];
        
        startX+=50.0f;
        //姓名
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 12, cellWidth-startX-10, 20.0f)];
        label.tag=0x12;
        label.textColor=KWordBlackColor;
        label.font=[UIFont systemFontOfSize:16.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
        
        //内容
        label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 42, cellWidth-startX-10, 20.0f)];
        label.tag=0x13;
        label.textColor=KWordGrayColor;
        label.font=[UIFont systemFontOfSize:12.0f];
        label.backgroundColor=[UIColor clearColor];
        label.lineBreakMode =NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [cell addSubview:label];
        
        //时间
        label=[[UILabel alloc] initWithFrame:CGRectMake(cellWidth-100, 22, 90, 20.0f)];
        label.tag=0x14;
        label.textColor=KWordGrayColor;
        label.textAlignment=NSTextAlignmentLeft;
        label.font=[UIFont systemFontOfSize:12.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
    }
    
    CommentBean *comment=[self.tableData objectAtIndex:indexPath.row];
    //姓名
    UILabel *label=(UILabel *)[cell viewWithTag:0x12];
    NSString *text=comment.name;
    label.text=text;
    
    //评价
    label=(UILabel *)[cell viewWithTag:0x13];
    text=comment.content;
    label.text=text;

    CGRect rect = [self getStringRect:text];
    
    label.frame = CGRectMake(CGRectGetMinX(label.frame), CGRectGetMinY(label.frame), rect.size.width, rect.size.height);
    //改变cell的高
    
    // 时间
    label=(UILabel *)[cell viewWithTag:0x14];
    text=comment.createTime;
    label.text=text;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor=[UIColor whiteColor];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

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
