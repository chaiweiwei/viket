//
//  DetailViewController.h
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/9.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "BaseViewController.h"
#import "ALDDataChangedDelegate.h"

@interface ShowViewController : BaseViewController<UITextViewDelegate>

@property (nonatomic, retain) NSMutableArray *commentData;//评论列表数据
@property (nonatomic, retain) UITextView     *commentTextView;

@property (nonatomic, retain) UIView *HeadView;
@property (nonatomic,strong) UITextView *currField;
// 1:课表 2 列表 3:缓存
@property (nonatomic,assign)int toController;
@property (nonatomic,copy) NSString *chapterId;
@property (nonatomic,copy) NSString *url;

@property (weak,nonatomic) id<ALDDataChangedDelegate> dataChangedDelegate;

@end
