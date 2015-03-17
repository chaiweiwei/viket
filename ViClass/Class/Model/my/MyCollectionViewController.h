//
//  MyCollectionViewController.h
//  ViClass
//
//  Created by chaiweiwei on 15/2/12.
//  Copyright (c) 2015年 chaiweiwei. All rights reserved.
//

#import "BaseViewController.h"

@interface MyCollectionViewController : BaseViewController<UIAlertViewDelegate>
{
    int  _iPage;             //列表页码
    int  _iPageSize;         //列表行数
    BOOL _bDataListHasNext;  //是否还有下拉数据
}
@end
