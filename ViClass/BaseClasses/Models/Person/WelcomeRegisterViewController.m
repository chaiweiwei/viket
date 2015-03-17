//
//  WelcomeRegisterViewController.m
//  Basics
//  第三方登录成功欢迎界面
//  Created by alidao on 14/12/4.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "WelcomeRegisterViewController.h"
#import "OHAttributedLabel.h"
#import "ALDButton.h"

#import "BindLoginViewController.h"

@interface WelcomeRegisterViewController ()

@end

@implementation WelcomeRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    // Do any additional setup after loading the view.
}

-(void)initUI
{
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat startX=10.0f;
    CGFloat startY=5.0f;
    
    NSString *text=[NSString stringWithFormat:@"亲爱的微信(QQ/新浪微博)用户:%@若您是%@新用户",self.nickName,kSoftwareName];
    
    CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:viewWidth-2*startX font:kFontSize28px];
    OHAttributedLabel *attributedlabel=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth-2*startX, size.height)];
    attributedlabel.font=kFontSize28px;
    attributedlabel.backgroundColor=[UIColor clearColor];
    [attributedlabel setUnderlineLinks:NO];
    [attributedlabel setLinkColor:KWordBlueColor];
    attributedlabel.userInteractionEnabled=YES;
    
    NSMutableAttributedString *attrStr=[NSMutableAttributedString attributedStringWithString:text];
    [attrStr setFont:kFontSize28px];
    [attrStr setTextColor:KWordBlackColor];
    
    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle.textAlignment = kCTLeftTextAlignment;
    paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 3.f; // increase space between lines by 3 points
    [attrStr setParagraphStyle:paragraphStyle];
    NSInteger nameLength=self.nickName.length;
    NSRange range=NSMakeRange(17,nameLength);
    [attrStr setTextColor:KWordRedColor range:range];
    nameLength=kSoftwareName.length;
    range=NSMakeRange(17+nameLength+3, nameLength);
    [attrStr setTextColor:KWordRedColor range:range];
    attributedlabel.attributedText=attrStr;
    startY+=(size.height+10);
    
    //直接进入
    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(startX, startY, viewWidth-2*startX, 44.0f);
    [btn setTitle:@"直接进入" forState:UIControlStateNormal];
    [btn setTitleColor:KWordWhiteColor forState:UIControlStateNormal];
    btn.titleLabel.font=kFontSize30px;
    btn.backgroundColor=KWordRedColor;
    btn.tag=0x11;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    startY+=44;
    
    startY+=10;
    UIView *line=[self createLine:CGRectMake(0, startY, viewWidth, 0.5)];
    [self.view addSubview:line];
    startY+=1;
    
    //已有账号
    text=[NSString stringWithFormat:@"已有%@账号",kSoftwareName];
    attributedlabel=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth-2*startX, size.height)];
    attributedlabel.font=kFontSize28px;
    attributedlabel.backgroundColor=[UIColor clearColor];
    [attributedlabel setUnderlineLinks:NO];
    [attributedlabel setLinkColor:KWordBlueColor];
    attributedlabel.userInteractionEnabled=YES;
    
    NSMutableAttributedString *attrStr1=[NSMutableAttributedString attributedStringWithString:text];
    [attrStr1 setFont:kFontSize28px];
    [attrStr1 setTextColor:KWordBlackColor];
    OHParagraphStyle* paragraphStyle1 = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle1.textAlignment = kCTLeftTextAlignment;
    paragraphStyle1.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle1.lineSpacing = 3.f; // increase space between lines by 3 points
    [attrStr1 setParagraphStyle:paragraphStyle1];
    nameLength=kSoftwareName.length;
    range=NSMakeRange(2, nameLength);
    [attrStr1 setTextColor:KWordRedColor range:range];
    attributedlabel.attributedText=attrStr1;
    startY+=20;
    
    line=[self createLine:CGRectMake(0, startY, viewWidth, 0.5)];
    [self.view addSubview:line];
    startY+=1;

    //绑定账号
    text=[NSString stringWithFormat:@"已有%@账号",kSoftwareName];
    attributedlabel=[[OHAttributedLabel alloc] initWithFrame:CGRectMake(startX, startY, viewWidth-2*startX, 44)];
    attributedlabel.font=kFontSize30px;
    attributedlabel.backgroundColor=[UIColor clearColor];
    [attributedlabel setUnderlineLinks:NO];
    [attributedlabel setLinkColor:KWordBlueColor];
    attributedlabel.userInteractionEnabled=YES;
    
    NSMutableAttributedString *attrStr2=[NSMutableAttributedString attributedStringWithString:text];
    [attrStr2 setFont:kFontSize30px];
    [attrStr2 setTextColor:KWordBlackColor];
    OHParagraphStyle* paragraphStyle2 = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle2.textAlignment = kCTLeftTextAlignment;
    paragraphStyle2.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle2.lineSpacing = 3.f; // increase space between lines by 3 points
    [attrStr2 setParagraphStyle:paragraphStyle2];
    nameLength=kSoftwareName.length;
    range=NSMakeRange(2, nameLength);
    [attrStr2 setTextColor:KWordRedColor range:range];
    attributedlabel.attributedText=attrStr2;
    
    btn=[ALDButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, startY, viewWidth, 44);
    btn.tag=0x12;
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

}

-(void)clickBtn:(ALDButton *)sender
{
    switch (sender.tag) {
        case 0x11:{ //直接进入
            
        }
            break;
            
        case 0x12:{ //绑定app账号
            BindLoginViewController *controller=[[BindLoginViewController alloc] init];
            controller.title=@"绑定已有账号";
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Back", @"返回") style:UIBarButtonItemStyleBordered target:nil action:nil];
            self.navigationItem.backBarButtonItem=backItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(UIView *)createLine:(CGRect )frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    
    return line;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
