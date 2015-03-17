//
//  SheetActionView.m
//  NewAppText
//
//  Created by yulong chen on 12-9-10.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import "SheetActionView.h"
#import "ALDUtils.h"
#import <QuartzCore/QuartzCore.h>

#define kRootTableView 10001
#define kSubTableView 10002
#define CORNER_RADIUS 5
#define MARGIN 2
#define kTableRowHeight 40.f
#define kRootWidth 95
#define kRootMinHeight 100
#define kRootMaxHeight 300
#define kSubWidth 180
#define kSubMinHeight 80
#define kSubMaxHeight 340

@implementation SheetActionView
@synthesize data=_data;
@synthesize currentSubData=_currentSubData;
@synthesize delegate=_delegate;
@synthesize rootView=_rootView;

@synthesize cornerRadius=_cornerRadius;
@synthesize interfaceOrientation=_interfaceOrientation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cornerRadius = CORNER_RADIUS;
        self.backgroundColor = [UIColor clearColor];
        screenRect = [[UIScreen mainScreen] bounds];
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
            screenRect.size.width = [[UIScreen mainScreen] bounds].size.height;
            screenRect.size.height = [[UIScreen mainScreen] bounds].size.width;
        }
        
        screenRect.origin.y = 20;
        screenRect.size.height = screenRect.size.height-20;   
        self.frame = screenRect;
    }
    return self;
}

- (id)initWithRootView:(UIView*)rootView
{
    self = [super initWithFrame:rootView.frame];
    if (self) {
        self.rootView=rootView;
        // Initialization code
        self.cornerRadius = CORNER_RADIUS;
        self.backgroundColor = [UIColor clearColor];
        screenRect = rootView.frame;
        self.frame = screenRect;
    }
    return self;
}

- (void)dealloc
{
    self.data=nil;
    self.currentSubData=nil;
    ALDRelease(_mSubContentView);
    ALDRelease(_mRootContentView);
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/**
 * 显示弹出层
 **/
-(void) showSheetActionWithEvent:(UIEvent *)senderEvent{
    //UIView *senderView = [[senderEvent.allTouches anyObject] view];
    CGRect frame=[[[senderEvent.allTouches anyObject] view] frame];
    [self showSheetAction:frame];
}

-(CGRect) captureFrame:(CGFloat)startX startY:(CGFloat)startY width:(CGFloat)width height:(CGFloat)height{
    CGFloat maxX;
    CGFloat maxY;
    if (_rootView) {
        CGRect frame=_rootView.frame;
        maxX=frame.origin.x+frame.size.width;
        maxY=frame.origin.y+frame.size.height;
    }else {
        maxX=320.f;
        maxY=480.f;
    }
    CGFloat x=startX;
    CGFloat y=startY;
    CGFloat w=width;
    CGFloat h=height;
    CGFloat temp=startX+width;
    if (temp>maxX) {
        temp=startX-width;
        if (temp<0) {
            w=maxX-startX;
        }else {
            x=temp;
        }
    }
    temp=startY+height;
    if (temp>maxY) {
        temp=startY-height;
        if (temp<0) {
            h=maxY-startY;
        }else {
            y=temp;
        }
    }
    return CGRectMake(x, y, w, h);
}

/**
 * 显示弹出层
 **/
-(void) showSheetAction:(CGRect)senderFrame{
    CGFloat sx=senderFrame.origin.x;
    CGFloat sy=senderFrame.origin.y+senderFrame.size.height+3;
    CGFloat height=_data.count*kTableRowHeight;
    if (height<kRootMinHeight) {
        height=kRootMinHeight;
    }else if (height>kRootMaxHeight) {
        height=kRootMaxHeight;
    }
//    CGFloat sheight=screenRect.size.height-10;
//    if (height+sy>sheight) {
//        height=sheight-sy;
//    }
//    CGRect frame=CGRectMake(sx, sy, kRootWidth, height);
    CGRect frame=[self captureFrame:sx startY:sy width:kRootWidth height:height];
    if (!_mRootContentView) {
        _mRootContentView=[[UIView alloc] initWithFrame:frame];
        _mRootContentView.layer.cornerRadius = _cornerRadius; 
        _mRootContentView.layer.masksToBounds = YES;
        _mRootContentView.backgroundColor=[UIColor lightGrayColor];
        UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kRootWidth, height)];
        tableView.layer.cornerRadius = _cornerRadius; 
        tableView.layer.masksToBounds = YES;
        tableView.backgroundColor=[UIColor lightGrayColor];
        [_mRootContentView addSubview:tableView];
        tableView.tag=kRootTableView;
        tableView.delegate=self;
        tableView.dataSource=self;
        ALDRelease(tableView);
    }
    _mRootContentView.frame=frame;
    UITableView *tableView=(UITableView*)[_mRootContentView viewWithTag:kRootTableView];
    tableView.frame=CGRectMake(0, 0, kRootWidth, height);
    [tableView reloadData];
    [self addSubview:_mRootContentView];
    if (_rootView) {
        [_rootView addSubview:self];
    }else {
        UIWindow *appWindow = [[UIApplication sharedApplication] keyWindow];
        [appWindow.rootViewController.view addSubview:self];
    }
}

/**
 * 显示弹出层
 * @param data 弹出层数据
 **/
-(void) showSheetAction:(CGRect)senderFrame data:(NSArray*)data{
    self.data=data;
    [self showSheetAction:senderFrame];
}

/**
 * 显示子弹出层
 * subData 子弹出层数据
 **/
-(void) showSubSheetAction:(NSArray *)subData{
    self.currentSubData=subData;
    if (!_mRootContentView) {
        return;
    }
    CGRect frame=_mRootContentView.frame;
    CGFloat sx=MARGIN+frame.origin.x+frame.size.width;
    CGFloat sy=10+frame.origin.y;
    CGFloat height=_currentSubData.count*kTableRowHeight;
    if (height<kSubMinHeight) {
        height=kSubMinHeight;
    }else if (height>kSubMaxHeight) {
        height=kSubMaxHeight;
    }
//    CGFloat sheight=screenRect.size.height-20;
//    if (height+sy>sheight) {
//        height=sheight-sy;
//    }
//    CGRect vFrame=CGRectMake(sx, sy, kSubWidth, height);
    CGRect vFrame=[self captureFrame:sx startY:sy width:kSubWidth height:height];
    if (!_mSubContentView) {
        _mSubContentView=[[UIView alloc] initWithFrame:vFrame];
        _mSubContentView.layer.cornerRadius = _cornerRadius; 
        _mSubContentView.layer.masksToBounds = YES;
        _mSubContentView.backgroundColor=[UIColor lightGrayColor];
        UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSubWidth, height)];
        tableView.layer.cornerRadius = _cornerRadius; 
        tableView.layer.masksToBounds = YES;
        tableView.backgroundColor=[UIColor lightGrayColor];
        [_mSubContentView addSubview:tableView];
        tableView.tag=kSubTableView;
        tableView.delegate=self;
        tableView.dataSource=self;
        ALDRelease(tableView);
        [self addSubview:_mSubContentView];
    }
    _mSubContentView.frame=vFrame;
    UITableView *tableView=(UITableView*)[_mSubContentView viewWithTag:kSubTableView];
    tableView.frame=CGRectMake(0, 0, kSubWidth, height);
    [tableView reloadData];
    _mSubContentView.hidden=NO;
}

- (void) dismissSheetActionAnimatd:(BOOL)animated
{
    [self removeFromSuperview];
}

- (void) dismissSubSheetActionAnimatd:(BOOL)animated{
    _mSubContentView.hidden=YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger tag=tableView.tag;
    if (tag==kRootTableView) {
        if (_data) {
            return _data.count;
        }
    }else if(tag==kSubTableView) {
        if (_currentSubData) {
            return _currentSubData.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger tag=tableView.tag;
    if (cell == nil) {
        cell = ALDReturnAutoreleased([[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]);
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,0,80,40)];
        textLabel.tag=101;
        textLabel.textAlignment=TEXT_ALIGN_LEFT;
        textLabel.textColor=[UIColor whiteColor];
        textLabel.backgroundColor=[UIColor clearColor];
        [cell addSubview:textLabel];
        ALDRelease(textLabel);
 	}
    NSInteger row=indexPath.row;
    UILabel *textLabel=(UILabel*)[cell viewWithTag:101];
    if (tag==kRootTableView) {
        textLabel.frame=CGRectMake(10,0,70,40);
        textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        NSDictionary *dic=[_data objectAtIndex:row];
        NSString *name=[dic objectForKey:@"name"];
        textLabel.text=name;
        BOOL hasSub=NO;
        id temp=[dic objectForKey:@"hasSub"];
        if (temp) {
            hasSub=[temp boolValue];
        }
        if (hasSub) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//加箭头
        }else {
            cell.accessoryType = UITableViewCellAccessoryNone;//去掉箭头
        }
    }else {
        textLabel.frame=CGRectMake(10,0,160,40);
        textLabel.font=[UIFont boldSystemFontOfSize:13.0];
        NSDictionary *dic=[_currentSubData objectAtIndex:row];
        NSString *name=[dic objectForKey:@"name"];
        textLabel.text=name;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(sheetActionView:didSelectItemAtPIndex:subIndex:)]) {
        NSInteger tag=tableView.tag;
        NSInteger row=indexPath.row;
        if (tag==kRootTableView) {
            _currRootIndex=row;
            [_delegate sheetActionView:self didSelectItemAtPIndex:row subIndex:-1];
        }else if(tag==kSubTableView) {
            [_delegate sheetActionView:self didSelectItemAtPIndex:_currRootIndex subIndex:row];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
                                                                 
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableRowHeight;
}

#pragma mark -touch events
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismissSubSheetActionAnimatd:YES];
    [self dismissSheetActionAnimatd:YES];
}
@end
