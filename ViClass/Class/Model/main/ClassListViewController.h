//
//  TalkListViewController.h
//  WeTalk
//
//  1.达人显示页 2.导师显示页 3.我的微说 4.我的收藏
//
//  Created by x-Alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseViewController.h"
#import "PullingRefreshTableView.h"
#import "ALDDataChangedDelegate.h"

@interface ClassListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate,ALDDataChangedDelegate> {
    int  _iPage;             //列表页码
    int  _iPageSize;         //列表行数
    BOOL _bDataListHasNext;  //是否还有下拉数据
}

@property (nonatomic, retain) PullingRefreshTableView *pullTableView;//列表
@property (nonatomic, retain) NSMutableArray          *tableData;//列表数据
@property (nonatomic        ) BOOL                    bRefreshing;
@property (nonatomic,copy) NSString *courseId;
/** 1.达人显示页 2.导师显示页 3.我的微说 4.我的收藏 **/
@property (nonatomic) NSInteger toController;

@end
