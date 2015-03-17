//
//  ALDGridCell.h
//  hyt_ios
//
//  Created by yulong chen on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALDImageView.h"
#import "ALDUtils.h"

@interface ALDGridCell : UIView{
    id _target; //触屏事件响应对象
    SEL _selector; //触屏事件响应方法
    id _param; //触屏事件响应方法传入参数
    UIViewTouchType _touchType; //需要响应的事件
    int _currTouchType; //当前触控类型，1:单击，2：双击，3：移动
    BOOL _hasClickResponded; //是否已响应点击
}

@property (nonatomic,retain) ALDImageView *imageView;
@property (nonatomic,retain) UILabel *textLabel;
@property (nonatomic) BOOL loginTag;

/**
 * 初始化Cell对象
 * @param frame view的frame
 * @param text 显示文本
 * @param imagePath 显示图片路径
 * @return 当前View对象
 */
- (id)initWithFrame:(CGRect)frame text:(NSString *) text imagePath:(NSString *) imagePath;

/**
 * 等比缩放图片
 * @param image 待缩放的图片对象
 * @param scaleSize 缩放比例
 * @return 返回缩放后的图片对象
 */
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/**
 * 设置图标
 * @param image 要显示的图标
 */
-(void) setImage:(UIImage *)image;

/**
 * 设置显示文本
 * @param text 要显示的文本
 */
-(void) setText:(NSString *) text;

-(void) setTextFont:(UIFont*)font;

/**
 * 自定义图片长宽
 * @param image 待重置大小的图片对象
 * @param reSize 待设置的大小
 * @return 返回重置大小的图片对象
 */
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

/**
 * GridCell的点击事件
 * @param target 事件响应对象
 * @param selector 事件响应方法
 * @param object 在调用selector时传入的参数
 * @param controlEvents 响应事件类型
 **/
-(void) addTarget:(id) target action:(SEL) selector withObject:(id)object forControlEvents:(UIViewTouchType) touchType;
@end
