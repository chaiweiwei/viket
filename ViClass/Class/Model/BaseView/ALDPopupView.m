//
//  ALDPopupView.m
//  hzapp
//
//  Created by yulong chen on 12-12-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDPopupView.h"
#import <QuartzCore/QuartzCore.h>

#define kMaxTableHeight 350

@implementation ALDPopupView
@synthesize isOpen=_isOpen;
@synthesize listData=_listData;
@synthesize delegate=_delegate;
@synthesize tableView=_tableView;

-(void)dealloc{
    ALDRelease(tableView);
    ALDRelease(toView);
    
    self.tableView = nil;
    self.listData = nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isOpen = NO;
        
		//设置边界是否能修剪
		[self setClipsToBounds:YES];
		self.backgroundColor = [UIColor clearColor];
        
        UIImage *bgImage=[UIImage imageNamed:@"icon_arraw"];
        UIImageView *imgViewRect=[[UIImageView alloc]initWithImage:bgImage];
        imgViewRect.frame = CGRectMake(15,0,15,8);
        _topView=imgViewRect;
        [self addSubview:imgViewRect];

        
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 7, frame.size.width, frame.size.height-8) style:UITableViewStylePlain];
        tableView.scrollEnabled = YES;
        tableView.delegate      = self;
        tableView.dataSource    = self;
        tableView.backgroundView  = nil;
        tableView.tableHeaderView = nil;
        tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.scrollEnabled   = NO;
        tableView.layer.cornerRadius = 7;
        tableView.layer.masksToBounds = YES;
        self.tableView=tableView;
        [self addSubview:tableView];
    }
    return self;
}

-(void)viewOpenWithView:(UIView *)tview :(BOOL) animation{
	_isOpen = YES;
    UIView *targetSuperview=[tview superview];
    
    CGRect supperFrame = [targetSuperview convertRect:tview.frame toView:[self superview]];
    CGRect viewFrame=tview.frame;
	if (animation)
    {
        [UIImageView beginAnimations:nil context:nil];
        [UIImageView setAnimationDuration:0.4];
        [UIImageView setAnimationCurve:UIViewAnimationCurveLinear];
        CGRect selfFrame=self.frame;
        CGFloat selfX=supperFrame.origin.x;
        if (selfX+selfFrame.size.width>320)
        {
            selfX=320-selfFrame.size.width;
        }
        selfFrame.origin.x=selfX;
        self.frame=selfFrame;
        
        CGRect arrowFrame=_topView.frame;
        CGFloat x=supperFrame.origin.x+(viewFrame.size.width-arrowFrame.size.width)/2.f-selfX;
        arrowFrame.origin.x=x;
        _topView.frame=arrowFrame;
        [self setHidden:NO];
        [UIImageView commitAnimations];
    }
    else
    {
//        CGRect selfFrame = self.frame;
//        CGFloat selfX = supperFrame.origin.x;
//        if (selfX + selfFrame.size.width > 320)
//        {
//            selfX = 320-selfFrame.size.width;
//        }
//        selfFrame.origin.x=selfX;
//        self.frame=selfFrame;
        [self setHidden:NO];
    }
}

-(void)viewClose:(BOOL) animation{
	_isOpen = NO;
    if (animation) {
        [UIImageView beginAnimations:nil context:nil];
        [UIImageView setAnimationDuration:0.4];
        [UIImageView setAnimationCurve:UIViewAnimationCurveLinear];
        [self setHidden:YES];
        [UIImageView commitAnimations];
    }else {
        [self setHidden:YES];
    }
}

-(void) setListData:(NSArray *)listData{
    _listData=listData;
    [_tableView reloadData];
}

-(void) layoutSubviews{
    CGFloat height=_listData.count*45;
    if (height<140) {
        height=140;
    }
    if (height>kMaxTableHeight) {
        height=kMaxTableHeight;
        _tableView.scrollEnabled=YES;
    }else{
        _tableView.scrollEnabled=NO;
    }
    CGRect tFrame=_tableView.frame;
    CGFloat startY=tFrame.origin.y;
    tFrame.size.height=height;
    _tableView.frame=tFrame;
    tFrame=self.frame;
    tFrame.size.height=height+startY;
    self.frame=tFrame;
    
    [super layoutSubviews];
}

//返回分组的行数
-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
    if (_listData) {
        return _listData.count;
    }
    return 0;
}

//设置行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 45;
}

//设置每一单元格的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CGFloat cellWidth = CGRectGetWidth(tableView.frame);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *textLabel= [[UILabel alloc] initWithFrame:CGRectMake(15, 0, cellWidth-15, 45)];
        textLabel.tag=1;
        textLabel.textAlignment = TEXT_ALIGN_LEFT;
        textLabel.font = kFontSize36px;
        textLabel.textColor=[UIColor whiteColor];
        textLabel.backgroundColor=[UIColor clearColor];
        [cell addSubview:textLabel];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth-24, 18, 9, 9)];
        icon.image = [UIImage imageNamed:@"icon_kind"];
        icon.tag = 2;
        icon.hidden = YES;
        [cell addSubview:icon];
        
        UIImageView *lineView=[[UIImageView alloc] initWithFrame:CGRectMake(15, 44, tableView.frame.size.width-30, 0.5)];
        lineView.backgroundColor = RGBACOLOR(204, 204, 204, 1);
        lineView.hidden = NO;
        lineView.tag = 3;
        [cell addSubview:lineView];
 	}
    int row = indexPath.row;
    BoothBean *bean = _listData[row];
    
    UILabel *textLabel=(UILabel *)[cell viewWithTag:1];

    textLabel.text = bean.title;
    textLabel.textColor = bean.color;
    
    UIImageView *icon = (UIImageView *)[cell viewWithTag:2];
    icon.hidden = YES;
    //分割线
    UIImageView *line = (UIImageView *)[cell viewWithTag:3];
    if(indexPath.row == self.listData.count-1)
    {
        icon.hidden = NO;
        line.hidden = YES;
    }
    else
        line.hidden = NO;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = self.selectedCell;;
    if(cell== nil)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:5 inSection:0];
        cell = [tableView cellForRowAtIndexPath:index];
    }
    UIImageView *icon = (UIImageView *)[cell viewWithTag:2];
    icon.hidden = YES;
    
    //显示选中icon
    cell = [tableView cellForRowAtIndexPath:indexPath];
    icon = (UIImageView *)[cell viewWithTag:2];
    icon.hidden = NO;
    
    self.selectedCell = cell;
    
    if (_delegate && [_delegate respondsToSelector:@selector(itemDidSelected:selecedAt:)]) {
        [_delegate itemDidSelected:self selecedAt:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row % 2 == 1){//奇数行
//        UIColor *color=[[UIColor alloc] initWithRed:250/255.f green:249/255.f blue:249/255.f alpha:1];
//        [cell setBackgroundColor:color];
//        [color release];
//    }else{//indexPath.row % 2 == 0（偶数行）
//        UIColor *color=[[UIColor alloc] initWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1];
//        [cell setBackgroundColor:color];
//        [color release];
//    }
//
//}

@end
