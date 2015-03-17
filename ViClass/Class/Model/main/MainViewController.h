//
//  MianViewController.h
//  WeTalk
//
//  主页
//
//  Created by x-Alidao on 14/11/29.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "PullingRefreshTableView.h"
#import "ALDUtils.h"

@interface MainViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, PullingRefreshTableViewDelegate, UIGestureRecognizerDelegate> {
    int  _iPage;             //列表页码
    int  _iPageSize;         //列表行数
    BOOL _bDataListHasNext;  //是否还有下拉数据
}

@property (nonatomic, retain) PullingRefreshTableView *pullTableView;//列表
@property (nonatomic, retain) NSMutableArray          *tableData;//列表数据
@property (nonatomic        ) BOOL                    bRefreshing;
@property (nonatomic        ) int                     type;

@property (assign,nonatomic ) UIViewController        *parentController;
/** 1.热门 2.最新 3.推荐 **/
@property (nonatomic,retain ) NSNumber                *typeId;

-(void) launchRefreshing;
-(void) setViewShowing:(BOOL) isShow;

@end
