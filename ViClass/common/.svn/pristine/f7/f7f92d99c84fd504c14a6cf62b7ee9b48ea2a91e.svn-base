//
//  SheetActionView.h
//  NewAppText
//  弹出层View
//  Created by yulong chen on 12-9-10.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SheetActionView;

@protocol SheetActionViewDelegate

@optional
/**
 * SheetAction项点击事件响应委托方法
 * index 顶级点击索引
 * subIndex 子级索引，如果非子级点击事件，该索引为-1
 **/
- (void)sheetActionView:(SheetActionView*)view didSelectItemAtPIndex:(NSInteger)index subIndex:(NSInteger)subIndex;

@end

@interface SheetActionView : UIView<UITableViewDelegate,UITableViewDataSource>{
    UIView *_mRootContentView; //顶弹出层
    UIView *_mSubContentView; //子弹出层
    NSInteger _currRootIndex; //当前root选中项
    
    CGRect screenRect;
}

@property (nonatomic) int cornerRadius;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (retain,nonatomic) NSArray *data; //弹出层数据,每一条数据都是NSDictionary对象或NSArray对象
@property (retain,nonatomic) NSArray *currentSubData; //当前子弹出层数据，每一条数据都是NSDictionary
@property (assign,nonatomic) UIView *rootView; //将当前view添加到的根view

//@property (nonatomic,assign) id<SheetActionViewDelegate> delegate; //事件委托
@property (assign,nonatomic) id delegate; //事件委托

- (id)initWithRootView:(UIView*)rootView;

/**
 * 显示弹出层
 **/
-(void) showSheetAction:(CGRect)senderFrame;

-(void) showSheetActionWithEvent:(UIEvent *)senderEvent;

/**
 * 显示弹出层
 * @param data 弹出层数据
 **/
-(void) showSheetAction:(CGRect)senderFrame data:(NSArray*)data;

/**
 * 显示子弹出层
 * subData 子弹出层数据
 **/
-(void) showSubSheetAction:(NSArray *)subData;

- (void) dismissSheetActionAnimatd:(BOOL)animated;

- (void) dismissSubSheetActionAnimatd:(BOOL)animated;
@end
