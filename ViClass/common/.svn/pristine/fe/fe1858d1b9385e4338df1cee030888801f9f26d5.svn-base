//
//  ALDLetterLocateView.h
//  npf
//
//  Created by yulong chen on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALDLetterLocateView;

@protocol LetterLocateViewDelegate <NSObject>
@required
/**
 * ALDLetterLocateView项点击事件响应
 * @param locateView 响应事件的view
 * @param position 点击项的索引
 **/
-(void) onItemSelected:(ALDLetterLocateView *) locateView itemLetter:(NSString*)letter;
@end

@interface ALDLetterLocateView : UIView<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    NSArray *_letters;
    CGFloat _selfWidth;
}

@property (nonatomic,assign) id<LetterLocateViewDelegate> delegate;
@property (retain,nonatomic) UIColor *selectBgColor;
@property (retain,nonatomic) UIColor *letterColor;
@end
