//
//  ALDChoiseAlertView.m
//  BFEC
//
//  Created by chen yulong on 14-1-3.
//  Copyright (c) 2014年 alidao. All rights reserved.
//

#import "ALDChoiseAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "ALDButton.h"

@interface ALDChoiseAlertView (){
    BOOL _isShowing;
    BOOL _isInited;
}
@property (retain,nonatomic) UILabel *titleView;
@property (retain,nonatomic) UIView *bottomView;
@property (retain,nonatomic) UITableView *choiseTable;
@property (retain,nonatomic) UIImage *selectImage;
@property (retain,nonatomic) UIImage *unSelectImage;

@end

@implementation ALDChoiseAlertView
@synthesize bottomView=_bottomView;
@synthesize contentView=_contentView,choiseTable=_choiseTable;
@synthesize selectImage=_selectImage,unSelectImage=_unSelectImage;

@synthesize data=_data;
@synthesize selectedData=_selectedData;
@synthesize choiseType=_choiseType;
@synthesize selectedIdx=_selectedIdx;

#define kRowHeight 45
#define kTablePadding 10.0f
#define kViewPadding 20

#define kMaxViewWidth 400
#define kMaxViewHeight ((isIPAD) ? 610 : 310)

#define kAnimationDuration      0.5f

- (id)initWithFrame:(CGRect)frame
{
    CGRect screenBounds=[UIScreen mainScreen].bounds;
    self = [super initWithFrame:CGRectMake(0, 0,screenBounds.size.width , screenBounds.size.height)];
    if (self) {
        CGFloat width=screenBounds.size.width-2*kViewPadding;
        if (width>kMaxViewWidth) {
            width=kMaxViewWidth;
        }
        
        self.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.4];
        
        CGFloat startX=(screenBounds.size.width-width)/2.f;
        _contentView=[[UIView alloc] initWithFrame:CGRectMake(startX, 0, width, 90)];
        _contentView.layer.masksToBounds=YES;
        _contentView.layer.cornerRadius=10;
        _contentView.backgroundColor=[UIColor whiteColor];
        
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, width, 30)];
        _titleView.backgroundColor=[UIColor clearColor];
//        _titleView.textColor=kBackBtnColor;
        _titleView.font=[UIFont boldSystemFontOfSize:18];
        _titleView.textAlignment=NSTextAlignmentCenter;
        [_contentView addSubview:_titleView];
        
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 40, width, 1)];
        lineView.backgroundColor=[UIColor lightGrayColor];
        [_contentView addSubview:lineView];
        ALDRelease(lineView);
        
        _choiseTable=[[UITableView alloc] initWithFrame:CGRectMake(20, 41, width-40, 0) style:UITableViewStylePlain];
        _choiseTable.delegate=self;
        _choiseTable.dataSource=self;
        _choiseTable.backgroundColor=[UIColor clearColor];
        [_contentView addSubview:_choiseTable];
        
        _bottomView=[[UIView alloc] initWithFrame:CGRectMake(0, 45, width, 40)];
        _bottomView.backgroundColor=[UIColor clearColor];
        [_contentView addSubview:_bottomView];
        
        [self addSubview:_contentView];
    }
    return self;
}

-(id) initWithTitle:(NSString *)title delegate:(id<ALDChoiseAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle{
    self=[self initWithFrame:CGRectZero];
    if (self) {
        self.delegate=delegate;
        _titleView.text=title;
        if (!cancelButtonTitle || [cancelButtonTitle isEqualToString:@""]) {
            cancelButtonTitle=ViewsLocalizedString(@"关闭",@"Close", @"");
        }
        if (okButtonTitle && ![okButtonTitle isEqualToString:@""]) {
            CGFloat buttonWidth=(_bottomView.frame.size.width-70)/2.f;
            UIButton *button=[self createButton:CGRectMake(30, 0, buttonWidth, 30) title:cancelButtonTitle tag:0];
            [_bottomView addSubview:button];
            
            button=[self createButton:CGRectMake(buttonWidth+40, 0, buttonWidth, 30) title:okButtonTitle tag:1];
            [_bottomView addSubview:button];
        }else{
            CGFloat buttonWidth=_bottomView.frame.size.width-60;
            UIButton *button=[self createButton:CGRectMake(30, 0, buttonWidth, 30) title:cancelButtonTitle tag:0];
            [_bottomView addSubview:button];
        }
    }
    return self;
}

-(UIButton*) createButton:(CGRect) frame title:(NSString*)title tag:(int) tag{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=frame;
    button.tag=tag;
    UIColor *textColor=[UIColor blackColor];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    [button setTitleColor:[textColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)dealloc
{
    self.titleView=nil;
    self.bottomView=nil;
    self.contentView=nil;
    self.choiseTable=nil;
    self.data=nil;
    self.selectedData=nil;
    self.selectImage=nil;
    self.unSelectImage=nil;
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void) layoutSubviews{
    CGRect choiseFrame=_choiseTable.frame;
    CGFloat tableHeight=kRowHeight*_data.count;
    if (tableHeight>kMaxViewHeight) {
        tableHeight=kMaxViewHeight;
    }
    choiseFrame.size.height=tableHeight;
    _choiseTable.frame=choiseFrame;
    
    CGRect bottomFrame=_bottomView.frame;
    bottomFrame.origin.y=choiseFrame.origin.y+tableHeight+10;
    _bottomView.frame=bottomFrame;
    CGRect contentFrame=_contentView.frame;
    contentFrame.size.height=bottomFrame.origin.y+bottomFrame.size.height;
    _contentView.frame=contentFrame;
    _contentView.center=self.center;
    [super layoutSubviews];
}

//overwrite the show method of UIAlertView
-(void) showToView:(UIView*) rootView{
    if (!_isInited) {
        _isInited=YES;
        [self prepare:rootView];
    }
    if (!_isShowing) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kAnimationDuration];
    }
     _isShowing=YES;
}

-(void) dismiss{
    _isShowing=NO;
    _isInited=NO;
    [self hiddenShareView];
}

- (void)prepare:(UIView*) rootView{
    if (_choiseType==ALDChoiseTypeRadio) {
        self.selectImage=[UIImage imageNamed:@"views.bundle/images/btn_radio_selected.png"];
        self.unSelectImage=[UIImage imageNamed:@"views.bundle/images/btn_radio_unselected.png"];
    }else {
        self.selectImage=[UIImage imageNamed:@"views.bundle/images/btn_checkbox_sel.png"];
        self.unSelectImage=[UIImage imageNamed:@"views.bundle/images/btn_checkbox_unsel.png"];
    }
    
    [[rootView window] addSubview:self];
}

-(void) hiddenView{
    [self removeFromSuperview];
}

-(void) hiddenShareView{
    NSString *animationsID=@"animation";
    //modify
    [UIView commitAnimations];
    [UIView beginAnimations:animationsID context:nil];
    [UIView setAnimationDuration:kAnimationDuration]; //动画时长
    CGRect frame=_contentView.frame;
    frame.origin.y=self.frame.size.height*2/3.f;
    _contentView.alpha = 0.6;
    _contentView.frame = frame;
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
    
    [self performSelector:@selector(hiddenView) withObject:nil afterDelay:kAnimationDuration];
}

#pragma marks UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_data) {
        return _data.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentfy=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndentfy];
    if (cell ==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentfy];
        UIImageView *checkImage=[[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(tableView.frame)-35, 10, 25, 25)];
		checkImage.tag = 0x101;
        [cell addSubview:checkImage];
        ALDRelease(checkImage);
        ALDAutorelease(cell);
    }
    NSInteger row=[indexPath row];
    cell.textLabel.text=[[_data objectAtIndex:row] description];
    UIImageView *checkImage=(UIImageView*)[cell viewWithTag:0x101];
    if ([self check:row]) {
        checkImage.image=_selectImage;
    }else {
        checkImage.image=_unSelectImage;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma marks UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row=[indexPath row];
    //获取单元格对象
    UITableViewCell *tablecell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView *img1=(UIImageView *)[tablecell viewWithTag:0x101];
    if (_choiseType==ALDChoiseTypeRadio) {
        if (![self check:row]) {
            NSIndexPath *selectPath = [_choiseTable indexPathForRowAtPoint: CGPointMake(0, _selectedIdx*kRowHeight)];
            //NSLog(@"selectPath row:%d",selectPath.row);
            UITableViewCell *tempCell = [tableView cellForRowAtIndexPath:selectPath];
            UIImageView *imgView=(UIImageView *)[tempCell viewWithTag:0x101];
            imgView.image=_unSelectImage;
            img1.image=_selectImage;
            self.selectedIdx=row;
        }
    }else {
        if ([self check:row]) {
            img1.image=_unSelectImage;
            [_selectedData removeObjectForKey:[NSNumber numberWithInteger:row]];
        }else {
            img1.image=_selectImage;
            [_selectedData setObject:[_data objectAtIndex:row] forKey:[NSNumber numberWithInteger:row]];
        }
    }
}

- (BOOL)check:(NSInteger)row{
    if (_choiseType==ALDChoiseTypeRadio) {
        if (_selectedIdx==row) {
            return YES;
        }
    }else {
        if (!_selectedData) {
            _selectedData=[[NSMutableDictionary alloc] init];
        }
        
        if ([_selectedData objectForKey:[NSNumber numberWithInteger:row]]) {
            return YES;
        }
    }
	
	return NO;
}

-(void) onButtonClicked:(UIButton*) button{
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [_delegate alertView:self clickedButtonAtIndex:button.tag];
    }
    [self dismiss];
}


@end
