//
//  ALDPopupView.h
//  hzapp
//
//  Created by yulong chen on 12-12-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoothBean.h"
@class ALDPopupView;

@protocol PopupViewDelegate <NSObject>

@optional
-(NSString*) itemTextForRow:(ALDPopupView*) popupView atRow:(NSInteger)row;  

-(void) itemDidSelected:(ALDPopupView*) popupView selecedAt:(NSInteger)selectedIndex;

@end

@interface ALDPopupView : UIView<UITableViewDelegate,UITableViewDataSource> {
	UITableView *_tableView;
    UIImageView *_topView; //No Retain
}
@property (nonatomic,retain) UITableView *tableView;
@property BOOL isOpen;
@property (nonatomic,retain) NSArray *listData;
@property (nonatomic,retain) UITableViewCell *selectedCell;
@property (nonatomic,assign) id<PopupViewDelegate> delegate;

-(void)viewOpenWithView:(UIView *)tview :(BOOL) animation;
-(void)viewClose:(BOOL) animation;

@end
