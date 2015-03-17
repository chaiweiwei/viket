//
//  BookListCell.m
//  ZhiDuoPing
//
//  Created by alidao on 14-4-10.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "ShowListCell.h"
#import "ALDImageView.h"
#import "UIViewExt.h"

@interface ShowListCell ()

@property (weak, nonatomic) ALDImageView *bookPic;
@property (weak, nonatomic) UILabel *bookNameLab;
//@property (retain, nonatomic) BookInfoBean *bean;
@property (weak, nonatomic) UILabel *ratingLabel;
@property (retain, nonatomic) NSString *string;

@end

@implementation ShowListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height ;
        
        CGFloat startY=0;
        ALDImageView *bookPic = [[ALDImageView alloc] initWithFrame:CGRectMake(0.0f, startY, width, height)];
       // bookPic.backgroundColor = [UIColor yellowColor];
        bookPic.defaultImage=[UIImage imageNamed:@"pic_book_duefult"];
        [self addSubview:bookPic];
        self.bookPic = bookPic;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    [self setBackgroundImage:[UIImage imageNamed:_imageName] forState:UIControlStateNormal];
}
-(void)setTitle:(NSString *)title
{
    _title = title;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, self.height-10-15, self.width, 15)];
    label.textColor = KWordWhiteColor;
    label.font = kFontSize30px;
    label.layer.shadowColor = KWordBlackColor.CGColor;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    label.layer.shadowRadius = 1.0;
    label.layer.shadowOpacity = 0.8;

    label.text = self.title;
    [self addSubview:label];
}
//-(void)setData:(BookInfoBean *) bean
//{
//    self.bean=bean;
//    self.cellSelected=bean.selected;
//    NSString *text = bean.booktitle;
//    text=text==nil?@"":text;
//    CGSize titleSize = [text sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(self.bookNameLab.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    if(titleSize.height<=20)
//    {
//        CGRect frame = self.bookNameLab.frame;
//        frame.size.height=20.0f;
//        self.bookNameLab.frame=frame;
//    }
//    self.bookNameLab.text = text;
//    /**服务端错误的url处理**/
//    text=bean.picurl;
////    text=[text stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
//    [self.bookPic setImageUrl:text];
//    
//    NSNumber *rate=bean.rate;
//    if (rate && [rate doubleValue]>0 && self.ratingLabel) {
//        text=[NSString stringWithFormat:@"已读 %.02f",[rate doubleValue]];
//        text=[text stringByAppendingString:@"%"];
//        self.ratingLabel.text=text;
//    }else{
//        self.ratingLabel.text=@"未读";
//    }
//}
//
//-(BookInfoBean*) getBookInfo{
//    return self.bean;
//}

-(void) setCellSelected:(BOOL)selected{
    _cellSelected=selected;
    if (self.cellSelected) {
        self.layer.masksToBounds=YES;
        self.layer.borderWidth=2.f;
        self.layer.borderColor=KWordGrayColor.CGColor;
    }else{
        self.layer.masksToBounds=NO;
        self.layer.borderWidth=0;
        self.layer.borderColor=[UIColor clearColor].CGColor;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
