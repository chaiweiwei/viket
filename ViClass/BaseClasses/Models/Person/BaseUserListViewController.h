//
//  UserListViewController.h
//  Zenithzone
//  学员列表
//  Created by alidao on 14-11-12.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDDataChangedDelegate.h"
#import "UserBean.h"
#import "PullingRefreshTableView.h"

@class EmbedButton;

#define cellHeight 64

@interface BaseUserListViewController : BaseViewController
{
    int page;
    int pageCount;
    BOOL hasNext;
    BOOL bRefreshing;
}

@property (retain,nonatomic) PullingRefreshTableView *pullTableView;
@property (retain,nonatomic) NSMutableArray *tableData;
@property (nonatomic,retain) UserBean *selectBean;

/** 1.活动报名学员 2.粉丝 3.我的关注**/
@property (nonatomic) int type;
/** 活动id **/
@property (retain,nonatomic) NSString *sid;
@property (assign,nonatomic) id<ALDDataChangedDelegate> dataChangedDelegate;

-(EmbedButton *)createBtn:(CGRect) frame icon:(UIImage *)icon;

@end
