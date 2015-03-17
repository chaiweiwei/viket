//
//  BookListCell.h
//  ZhiDuoPing
//
//  Created by alidao on 14-4-10.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "ALDButton.h"
//#import "BookInfoBean.h"

@interface ShowListCell :ALDButton

@property (nonatomic) BOOL cellSelected;
@property (nonatomic,copy) NSString *imageName;
@property (nonatomic,copy) NSString *title;
-(void)setData:(id) book;

//-(BookInfoBean*) getBookInfo;

@end
