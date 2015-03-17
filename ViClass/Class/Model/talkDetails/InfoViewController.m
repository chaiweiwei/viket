//
//  InfoViewController.m
//  Vike_1018
//
//  Created by chaiweiwei on 14/11/14.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "InfoViewController.h"
#import "ClassRoomBean.h"

@interface InfoViewController ()
{
    //ClassRoomModel *bean;
    BOOL _isShow;
}

@end

@implementation InfoViewController

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
    //[self getLocalData];
    [self initUI];
    
}

-(void)initUI
{
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    CGFloat startX = 10.0f;
    CGFloat startY = 12.0f;
    //单位 课堂名称
    NSString *name = [NSString stringWithFormat:@"%@:%@",_currClass.name,_currClass.name];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth, 20.0f)];
    label.textColor = [UIColor blackColor];
    [label setFont:[UIFont systemFontOfSize:16.0f]];
    label.text = name;
    [self.view addSubview:label];
    startY += 22.0f;

    //类型
    label = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth, 20.0f)];
    label.text = [NSString stringWithFormat:@"类型: %@",_currClass.name];
    label.textColor = [UIColor blackColor];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [self.view addSubview:label];
    startY += 20.0f;
    
    //主讲人
    label = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth, 20.0f)];
    label.text = [NSString stringWithFormat:@"教师: %@",_currClass.teacherName];
    label.textColor = [UIColor blackColor];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    [self.view addSubview:label];
    startY += 20.0f;
    
    //简介
    label = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth, 20.0f)];
    label.text = [NSString stringWithFormat:@"简介: %@",_currClass.note];
    label.textColor = [UIColor blackColor];
    [label setFont:[UIFont systemFontOfSize:12.0f]];
    //改变宽高
    CGRect rect = [self getStringRect:label.text];
    label.numberOfLines = 0;
    label.frame = CGRectMake(startX, startY, rect.size.width, rect.size.height);
    
    [self.view addSubview:label];
}
#pragma mark - 加载数据
-(void)loadData
{
//    _currClass = [[ClassRoomModel alloc] init];
//    _currClass.company = @"浙江传媒学院";
//    _currClass.className = @"计算机网络";
//    _currClass.teacherName = @"赵老师";
//    _currClass.typeString = @"计算机网络";
//    _currClass.info = @"dedede计算机网络计算机网计算机网dede计算机网络计算机网dede计算机网络计算机网dede计算机网络计算机网dede计算机网络计算机网络络计算机网络赵老师赵老师赵老师赵老师计算机网络计算机网络计算机网络de frvtvy";
}
#pragma mark - 本地读取所有的课堂数据
//-(void)getLocalData
//{
//    //本地数据
//    NSString *fileName = [NSString stringWithFormat:@"ClassRoomData.plist"];
//    NSArray *files =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *file = files[0];
//    NSString *filePath = [file stringByAppendingPathComponent:fileName];
//    
//    if(filePath)
//    {
//        //全部的课程
//        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        for(NSDictionary *item  in dic[@"List"])
//        {
//            if([item[@"DjLsh"] intValue] == _classId)
//            {
//                bean = [ClassRoomModel itemWithDict:item];
//                return;
//            }
//        }
//    }
//}

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
     NSFontAttributeName: [UIFont systemFontOfSize:16.0f], NSParagraphStyleAttributeName:paragraphStyle.copy
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width - 10, CGFLOAT_MAX}
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
