//
//  AllCourseViewController.h
//  Vike_1018
//  搜索
//  Created by chaiweiwei on 14/11/17.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllCourseViewController : UIViewController
{
    int  _iPage;             //列表页码
    int  _iPageSize;         //列表行数
    BOOL _bDataListHasNext;  //是否还有下拉数据
}
@property (nonatomic        ) BOOL                    bRefreshing;
@end
