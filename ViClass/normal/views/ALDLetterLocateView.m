//
//  ALDLetterLocateView.m
//  npf
//  字母定位View
//  Created by yulong chen on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDLetterLocateView.h"

@implementation ALDLetterLocateView
@synthesize delegate=_delegate;
@synthesize selectBgColor=_selectBgColor;
@synthesize letterColor=_letterColor;

- (void)dealloc
{
    ALDRelease(_tableView);
    ALDRelease(_letters);
    self.selectBgColor=nil;
    self.letterColor=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _letters=[[NSArray alloc] initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
        CGSize size=self.bounds.size;
        CGRect frame=CGRectMake(0, 5, size.width,size.height-10);
        _selfWidth=size.width;
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor=[UIColor clearColor];
        
        [self addSubview:_tableView];
        self.backgroundColor=[UIColor clearColor];
        self.selectBgColor=[UIColor blueColor];
    }
    return self;
}

-(void) layoutSubviews{
    CGRect frame=self.bounds;
    _selfWidth=frame.size.width;
    _tableView.frame=CGRectMake(0, 5, frame.size.width,frame.size.height-10);
    [super layoutSubviews];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _letters.count;
}

//static NSString *cellIdentifier = @"LetterLocate";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LetterLocate";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier: cellIdentifier ];
        cell.backgroundColor=[UIColor clearColor];
        UILabel *textLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,_selfWidth,15)];
        textLabel.tag=1;
        textLabel.textAlignment=TEXT_ALIGN_CENTER;
        textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        if (_letterColor) {
            textLabel.textColor=_letterColor;
        }else {
            textLabel.textColor=[UIColor grayColor];
        }
        textLabel.backgroundColor=[UIColor clearColor];
        [cell.contentView addSubview:textLabel];
        ALDRelease(textLabel);
        
        UIView *bgView=[[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor=self.selectBgColor;
        cell.selectedBackgroundView=bgView;
        ALDRelease(bgView);
        ALDAutorelease(cell);
 	}
    NSInteger row=[indexPath row];
    NSString *letter=[_letters objectAtIndex:row];
    UILabel *textLabel=(UILabel *)[cell.contentView viewWithTag:1];
	textLabel.text=letter;
    return cell; 
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row=[indexPath row];
    NSString *letter=[_letters objectAtIndex:row];
    if (_delegate && [_delegate respondsToSelector:@selector(onItemSelected:itemLetter:)]) {
        [_delegate onItemSelected:self itemLetter:letter];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//设置单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 15;
}

@end
