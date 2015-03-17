//
//  ButtonView.m
//  ViKeTang
//
//  Created by chaiweiwei on 14/12/16.
//  Copyright (c) 2014年 chaiweiwei. All rights reserved.
//

#import "ButtonView.h"
#import "ChapterBean.h"

@interface ButtonView()

@property (nonatomic,retain) NSArray *color;
@property (nonatomic,retain) NSMutableArray *str;
@end
@implementation ButtonView
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)setDelegate:(id<ButtonDelegate>)delegate
{
    _delegate = delegate;
}
-(void)setArray:(NSArray *)array
{
    _array = array;
    _str = [NSMutableArray array];
    if([_array[0] isKindOfClass:[ChapterBean class]])
    {
        for( ChapterBean *bean in _array)
        {
            [_str addObject:bean.name];
        }
    }
}
-(NSArray *)color
{
//    _color = [NSArray arrayWithObjects:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_list01"]],
//                                         [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_list02"]],
//                                          [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_list03"]],
//                                           [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_list04"]],
//                                            [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_my"]],nil];
    _color = [NSArray arrayWithObjects:RGBACOLOR(190, 147, 105, 1),RGBACOLOR(252,184, 107, 1),RGBACOLOR(136, 23, 36, 1),
              RGBACOLOR(95, 55, 23, 1),RGBACOLOR(177, 223, 231, 1),RGBACOLOR(194, 180, 154, 1),nil];
    return _color;
}
-(void)layoutSubviews
{
    CGFloat startY = 5;
    CGFloat startX = 10;
    CGFloat btnMagin = (CGRectGetWidth(self.frame)-290)/2.0f;
    for(int i= 0;i<_array.count;i++)
    {
        if(i%3==0&&i!=0)
        {
            startX = 10;
            startY += 35+10;
        }
        UIButton *btn = [self createThree:CGRectMake(startX, startY, 90, 35) title1:_str[i] title2:@"" icon:@"img_right" tag:(0x200+i)];
        [self addSubview:btn];
        startX+=90+btnMagin;

   }
    
}
-(void)btnSelected:(UIButton *)sender
{
    UIImageView *icon =(UIImageView *)[sender viewWithTag:0x3001];
    icon.image = [UIImage imageNamed:@"img_right"];
    
    
    if([self.delegate respondsToSelector:@selector(btnCickedDelegate:)])
    {
        [self.delegate btnCickedDelegate:sender];
    }
}
-(UIButton *)createThree:(CGRect)rect title1:(NSString *)title1 title2:(NSString *)title2 icon:(NSString *)icon tag:(int)tag
{
    UIButton *btn = [[UIButton alloc] initWithFrame:rect];
    btn.backgroundColor = [UIColor whiteColor];
    [btn addTarget:self action:@selector(btnSelected:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = tag;
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 30, 25)];
    img.tag = 0x3001;
    img.image = [UIImage imageNamed:icon];
    [btn addSubview:img];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40,0, 50, 15)];
    label.font = kFontSize24px;
    label.textAlignment = TEXT_ALIGN_LEFT;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = KWordBlackColor;
    label.text = title1;
    [btn addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(40,15, 50, 20)];
    label.font = kFontSize24px;
    label.textAlignment = TEXT_ALIGN_LEFT;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBACOLOR(150, 150, 150, 1);
    label.text = title2;
    [btn addSubview:label];
    
    return btn;
}
@end
