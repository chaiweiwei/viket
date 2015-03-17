//
//  TimeViewController.m
//  ViClass
//
//  Created by chaiweiwei on 15/2/11.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "TimeViewController.h"
#import "TimeDao.h"
#import "TimeBean.h"

@interface TimeViewController()<UITableViewDataSource,UITableViewDelegate>
{
    
}
@property (nonatomic,retain) NSArray *tableData;
@property (nonatomic,retain) NSMutableArray *monthData;
@property (nonatomic,retain) NSMutableDictionary *monthDayDic;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSArray *colors;

@end
@implementation TimeViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height-64-70) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //RGBACOLOR(54, 63, 68, 1)
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    view.backgroundColor = RGBACOLOR(76, 85, 87, 1);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 70)];
    label.text = @"月份";
    label.textAlignment = TEXT_ALIGN_LEFT;
    label.font = KFontSizeBold40px;
    label.textColor = RGBACOLOR(114, 124, 126, 1);
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(78, 15, 40, 40)];
    icon.image = [UIImage imageNamed:@"icon_clock"];
    [view addSubview:icon];
    
    [self.view addSubview:view];
    
    _colors = [NSArray arrayWithObjects:[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor], nil];
}
-(void)loadData
{
    TimeDao *timeDao = [[TimeDao alloc] init];
    _tableData = [NSArray arrayWithArray:[timeDao queryTimeData]];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableData.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat cellwidth = CGRectGetWidth(self.view.frame);
        
        UILabel *month = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 60)];
        month.tag = 0x1001;
        month.backgroundColor = [UIColor clearColor];
        month.textAlignment = TEXT_ALIGN_LEFT;
        month.textColor = KWordGrayColor;
        month.font = kFontSize30px;
        [cell addSubview:month];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 2, 60)];
        line.backgroundColor = RGBACOLOR(172, 178, 183, 1);
        [cell addSubview:line];
        
        UIView *cir = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        cir.center = CGPointMake(51, 30);
        cir.layer.borderWidth = 1;
        cir.layer.borderColor = [UIColor greenColor].CGColor;
        cir.layer.masksToBounds = YES;
        cir.layer.cornerRadius = 7.5;
        cir.backgroundColor = KWordWhiteColor;
        cir.tag = 0x1003;
        [cell addSubview:cir];
        
        UIImageView *arraw = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
        arraw.center = CGPointMake(cir.right+10+4, 30);
        arraw.image = [UIImage imageNamed:@"icon_arraw"];
        [cell addSubview:arraw];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(arraw.right, 10, cellwidth-10-arraw.right, 40)];
        content.backgroundColor = RGBACOLOR(237, 241, 242, 1);
        content.textColor = KWordGrayColor;
        content.layer.masksToBounds = YES;
        content.layer.cornerRadius = 3;
        content.font = kFontSize30px;
        content.textAlignment = TEXT_ALIGN_CENTER;
        content.tag = 0x1002;
        
        [cell addSubview:content];
    }
    TimeBean *bean = _tableData[indexPath.row];
    UILabel *month = (UILabel *)[cell viewWithTag:0x1001];
    month.text =[NSString stringWithFormat:@"%li 月",bean.month];
    if(indexPath.row == 0)
        month.hidden = NO;
    else
    {
        TimeBean *lastBean = _tableData[indexPath.row-1];
        if(bean.month == lastBean.month)
        {
            month.hidden = YES;
        }
        else
            month.hidden = NO;
    }
    
    UILabel *content = (UILabel *)[cell viewWithTag:0x1002];
    content.text = bean.time;
    
    UIView *cir = (UIView *)[cell viewWithTag:0x1003];
    UIColor *color =_colors[indexPath.row%4];
    cir.layer.borderColor = color.CGColor;
    
    return cell;
}
@end
