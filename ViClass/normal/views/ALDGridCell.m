//
//  ALDGridCell.m
//  hyt_ios
//
//  Created by yulong chen on 12-4-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDGridCell.h"
#import <QuartzCore/QuartzCore.h>

#define kMargin 5
#define kImageMarginText 3
#define kLabelHight 20

@interface ALDGridCell(private){
    
}

-(CGRect) captureImageSize;

//点击效果
-(void) clickEffect;
//清楚效果
-(void) clearEffect;
@end

@implementation ALDGridCell
@synthesize textLabel=_textLabel,imageView=_imageView;
@synthesize loginTag=_loginTag;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.layer.cornerRadius = 8; 
        //self.layer.masksToBounds = YES;
        self.loginTag=NO;
        CGRect bounds=self.bounds;
        CGRect rct=[self captureImageSize];
        _imageView=[[ALDImageView alloc] initWithFrame:rct];
        _imageView.fitImageToSize=NO;
        _imageView.autoResize=NO;
        //_imageView.backgroundColor=[UIColor lightGrayColor];
        //_imageView.layer.cornerRadius = 8;
        //_imageView.layer.masksToBounds=YES;
        [self addSubview:_imageView];
        
        CGRect lFrame=CGRectMake(0,kImageMarginText+rct.size.height+3, bounds.size.width, kLabelHight);
        _textLabel=[[UILabel alloc] initWithFrame:lFrame];
        _textLabel.highlighted = YES;//设置高亮      
        _textLabel.textColor=RGBCOLOR(158, 0, 0);
        _textLabel.font=[UIFont boldSystemFontOfSize:15.0];
        //  [_textLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];
        _textLabel.textAlignment  = TEXT_ALIGN_CENTER;
        //_textLabel.adjustsFontSizeToFitWidth =  YES ; //设置字体大小适应label宽度
        [_textLabel setLineBreakMode:LineBreakModeMiddleTruncation];
        _textLabel.numberOfLines = 1; //设置label的行数     
        _textLabel.backgroundColor=[UIColor clearColor];
        
        [self addSubview:_textLabel];
        
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

/**
 * 初始化Cell对象
 * @param frame view的frame
 * @param text 显示文本
 * @param imagePath 显示图片路径
 * @return 当前View对象
 */
- (id)initWithFrame:(CGRect)frame text:(NSString *) text imagePath:(NSString *) imagePath{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setImage:[UIImage imageNamed:imagePath]];
        //NSLog(@"imagePath:%@",imagePath);
        [_imageView setImageUrl:imagePath];
        [self setText:text];
    }
    return self;
}

-(void) setImage:(UIImage *)image{
    UIImage *tmp=[self reSizeImage:image toSize:_imageView.frame.size];
    _imageView.image=tmp;
}


-(void) setText:(NSString *) text{
    _textLabel.text=text;
}

-(void) setTextFont:(UIFont*)font{
    _textLabel.font=font;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _hasClickResponded=NO;
    [self clickEffect];
    UITouch *touch = [[event allTouches] anyObject];
    if(touch.tapCount>1){
        _currTouchType=UIDoubleClick;
    }else {
        _currTouchType=UISingleClick;
    }
    if(_touchType==UITouchInside){
        _hasClickResponded=YES;
        if ([_target respondsToSelector:_selector])
        {
            [_target performSelector:_selector withObject:_param];
        }
    }
    //NSLog(@"*****touchesBegan");
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clearEffect];
    if(!_hasClickResponded && _touchType==UISingleClick && _currTouchType==UISingleClick){
        _hasClickResponded=YES;
        if ([_target respondsToSelector:_selector])
        {
            [_target performSelector:_selector withObject:_param];
        }
    }else if(!_hasClickResponded &&_touchType==UISingleClick && _currTouchType==UIDoubleClick){
        _hasClickResponded=YES;
        if ([_target respondsToSelector:_selector])
        {
            [_target performSelector:_selector withObject:_param];
        }
    }
    //NSLog(@"*****touchesCancelled");
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clearEffect];
    if(!_hasClickResponded && _touchType==UISingleClick && _currTouchType==UISingleClick){
        _hasClickResponded=YES;
        if ([_target respondsToSelector:_selector])
        {
            [_target performSelector:_selector withObject:_param];
        }
    }else if(!_hasClickResponded && _touchType==UISingleClick && _currTouchType==UIDoubleClick){
        _hasClickResponded=YES;
        if ([_target respondsToSelector:_selector])
        {
            [_target performSelector:_selector withObject:_param];
        }
    }
    //NSLog(@"*****touchesEnded");
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clearEffect];
    _currTouchType=UITouchMove;
    if(_touchType==UITouchMove){
        if ([_target respondsToSelector:_selector])
        {
            [_target performSelector:_selector withObject:_param];
        }
    }
    //NSLog(@"*****touchesMoved");
}

-(BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return [super pointInside:point withEvent:event];
}

-(UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return [super hitTest:point withEvent:event];
}

/**
 * 等比缩放图片
 * @param image 待缩放的图片对象
 * @param scaleSize 缩放比例
 * @return 返回缩放后的图片对象
 */
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(CGRect) captureImageSize{
    CGSize viewSize=self.bounds.size;
    CGFloat x=kMargin;
    CGFloat y=kMargin;
    CGFloat height=viewSize.height-kLabelHight-kImageMarginText-2*kMargin;
    CGFloat width=viewSize.width-2*kMargin;
    if (width>height) {
        width=height;
        x=(viewSize.width-width)/2.0;
    }
    CGRect rect=CGRectMake(x, y,width, height);
    return rect;
}

/**
 * 自定义图片长宽
 * @param image 待重置大小的图片对象
 * @param reSize 待设置的大小
 * @return 返回重置大小的图片对象
 */
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void) clearEffect{
    self.backgroundColor=[UIColor clearColor];
    self.alpha=1.0;
    self.layer.cornerRadius = 0; 
    self.layer.masksToBounds = NO;
    _textLabel.textColor=RGBCOLOR(158, 0, 0);
}

-(void) clickEffect{
    self.layer.cornerRadius = 5; 
    self.layer.masksToBounds = YES;
    self.backgroundColor=[UIColor blackColor];
    self.alpha=0.3;
    _textLabel.textColor=[UIColor whiteColor];
}

-(void) layoutSubviews{
    CGSize size=[ALDUtils captureTextSizeWithText:_textLabel.text textWidth:320 font:_textLabel.font];
    CGRect bounds=self.frame;
    if (size.width>bounds.size.width) {
        CGFloat x=(bounds.size.width-size.width)/2.f;
        _textLabel.frame=CGRectMake(x, _textLabel.frame.origin.y, size.width, kLabelHight);
    }
    [super layoutSubviews];
}

/**
 * GridCell的点击事件
 * @param target 事件响应对象
 * @param selector 事件响应方法
 * @param object 在调用selector时传入的参数
 * @param controlEvents 响应事件类型
 **/
-(void) addTarget:(id) target action:(SEL) selector withObject:(id)object forControlEvents:(UIViewTouchType) touchType{
    _target=target;
    _selector=selector;
    _touchType=touchType;
    _param=object;
}

- (void)dealloc
{
    self.imageView=nil;
    self.textLabel=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
