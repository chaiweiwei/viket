//
//  TableUtils.m
//  GWCClub
//
//  Created by yulong chen on 13-1-30.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "TableUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "ALDImageView.h"
#import "ALDButton.h"
#import "ArrowButton.h"
#import "NSDictionaryAdditions.h"
#import "ALDUtils.h"
#import "CommentBean.h"

@interface TableUtils (private)

+(UILabel *) createLabel:(CGRect) frame tag:(int) tag;
+(ArrowButton*) createArrowBtn:(CGRect)frame tag:(int)tag icon:(UIImage*)icon text:(NSString*)text;

@end

@implementation TableUtils
static NSString *moreIdentifier = @"moreCell";
static NSString *normalIdentifier = @"normalCell";
//static NSString *commentCellIdentifier=@"commentCell";

+(NSString*) delCreateData:(NSString*)strDate{
    if (!strDate || [strDate isEqualToString:@""]) {
        return nil;
    }
    //1小时内显示分钟，8小时以上显示具体时间(日期+时间)
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:strDate];
    if (!date) {
        return strDate;
    }
    NSDate *nowDate = [NSDate date];// 获取本地时间
    NSTimeInterval time=[nowDate timeIntervalSince1970]-[date timeIntervalSince1970];
    NSString *result=nil;
    if (time<3600) { //1小时
        if (time<60) {
            result=@"1分钟前";
        }else {
            result=[NSString stringWithFormat:@"%.0f分钟前",(time/60)];
        }
    }else if (time<3600*8) {
        result=[NSString stringWithFormat:@"%.0f小时前",(time/3600)];
    }else {
        [formatter setDateFormat:@"MM-dd HH:mm"];
        result=[formatter stringFromDate:date];
    }
    return result;
}

+(UILabel *) createLabel:(CGRect) frame tag:(int) tag {
    UILabel *label=[[UILabel alloc]initWithFrame:frame];
    label.font=kFontSize28px;
    label.textAlignment=TEXT_ALIGN_LEFT;
    label.textColor=kLittleTitleColor;
    label.numberOfLines=2;
    label.enabled=YES;
    label.tag=tag;
    label.backgroundColor=[UIColor clearColor];
    return label;
}

+(ArrowButton*) createArrowBtn:(CGRect)frame tag:(int)tag icon:(UIImage*)icon text:(NSString*)text{
    ArrowButton *arrowBtn=[[ArrowButton alloc] initWithFrame:frame];
    arrowBtn.iconView.image=icon;
    CGFloat iconY=(frame.size.height-11)/2.f;
    arrowBtn.iconFrame=CGRectMake(0, iconY, 11, 11);
    arrowBtn.textView.text=text;
    arrowBtn.noteAtLeft=YES;
    arrowBtn.arrowView.hidden=YES;
    arrowBtn.selectBgColor=kColorButtonSelected;
    arrowBtn.textView.textColor=[UIColor colorWithRed:166/255.f green:166/255.f blue:166/255.f alpha:1];
    arrowBtn.textView.font=[UIFont systemFontOfSize:13];
    arrowBtn.tag=tag;
    return arrowBtn;
}
/*
+(UITableViewCell *) getNormalNewsCell:(UITableView*) tableView dataBean:(NewsBean*)bean indexPath:(NSIndexPath*)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalIdentifier];
    if (cell==nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalIdentifier] autorelease];
        CGFloat startX=10;
        //标题
        UILabel *label=[TableUtils createLabel:CGRectMake(startX, 15, 300, 20) tag:0x101];
        label.font=kFontSize32px;
        label.numberOfLines=0;
        label.textColor=[UIColor blackColor];
        [cell addSubview:label];
        
        //下面的
        UIView *nextView=[[UIView alloc] initWithFrame:CGRectMake(startX, 35, 300, 65)];
        nextView.tag=0x102;
        [cell addSubview:nextView];
        //logo图片
        startX=0;
        CGFloat startY=0;
        ALDImageView *imageView=[[ALDImageView alloc] initWithFrame:CGRectMake(startX, startY, 80, 60)];
        imageView.tag=0x201;
        imageView.defaultImage=[UIImage imageNamed:@"common_image_default_normal"];
        [nextView addSubview:imageView];
        startX+=imageView.frame.size.width+20;
        [imageView release];
        
        //简介
        label=[TableUtils createLabel:CGRectMake(startX-5, startY, 300-startX, 40) tag:0x202];
        label.font=kFontSize28px;
        label.numberOfLines=2;
        [nextView addSubview:label];
        startY+=label.frame.size.height+5;
        
        //时间
        ArrowButton *button=[TableUtils createArrowBtn:CGRectMake(startX-5, startY, 300-startX, 20) tag:0x203 icon:[UIImage imageNamed:@"conference_icon_time_default"] text:@""];
        button.textView.font=kFontSize20px; 
        button.textView.textColor=kTimesColor;
        button.enabled=NO;
        [nextView addSubview:button];
        
        [nextView release];
    }
    UILabel *label=(UILabel*)[cell viewWithTag:0x101];
    label.text=bean.title;
    CGRect frame=label.frame;
    CGSize size=[ALDUtils captureTextSizeWithText:bean.title textWidth:frame.size.width font:label.font];
    frame.size.height=size.height;
    label.frame=frame;
    
    UIView *nextView=[cell viewWithTag:0x102];
    CGRect nextFrame=nextView.frame;
    nextFrame.origin.y=frame.origin.y + size.height+5;
    nextView.frame=nextFrame;
    
    ALDImageView *imageView=(ALDImageView*)[nextView viewWithTag:0x201];
    [imageView setImageUrl:bean.pic];
    
    label=(UILabel*)[nextView viewWithTag:0x202];
    label.text=bean.content;
    
    ArrowButton *button=(ArrowButton*)[nextView viewWithTag:0x203];
    button.textView.text=[ALDUtils getFormatDateWithString:bean.pubTime withOldFormat:@"yyyy-MM-dd HH:mm:ss" withNewFormat:@"yyyy-MM-dd HH:mm"];
    
    return cell;
}
*/
+(UITableViewCell*) getMoreCell:(UITableView *)tableView{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreIdentifier];
        cell.textLabel.textAlignment = TEXT_ALIGN_CENTER;
        cell.textLabel.text          = ALDLocalizedString(@"More Data", @"更    多");
        cell.textLabel.font          = [UIFont boldSystemFontOfSize:14];
        cell.accessoryType           = UITableViewCellAccessoryNone;
    }
    return cell;
}

@end
