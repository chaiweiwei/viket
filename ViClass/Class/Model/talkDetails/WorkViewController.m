#import "WorkViewController.h"
#import "QuestionBean.h"
#import "MainViewController.h"

@interface WorkViewController ()<UITextViewDelegate>
{
    int type; //题目类型
    int currIndex;//当前的第几题
    UIButton *selectedBtn; //选中的答案选项
    UIView *view;
    int scores; //分数
    QuestionBean *quest;
    BOOL _isShow;
}

@property (nonatomic,retain) NSMutableArray *tableData;

@end
#define MPlayHeight 180
#define TabViewHeight 36
@implementation WorkViewController
-(void) setViewShowing:(BOOL) isShow{
    if (!_isShow) {
        [self performSelectorInBackground:@selector(initData) withObject:nil];
    }
    _isShow=isShow;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
-(void)initData
{
//    if([_currModel isKindOfClass:[ExamModel class]])
//    {
//       ExamModel *exam = (ExamModel *)_currModel;
//        for(QuestionModel *temp in exam.questArray)
//        {
//            if(_tableData == nil)
//            {
//                _tableData = [NSMutableArray array];
//            }
//            [_tableData addObject:temp];
//        }
//    }
//    else if([_currModel isKindOfClass:[ExerciseModel class]])
//    {
//        ExerciseModel *exam = (ExerciseModel *)_currModel;
//        for(QuestionModel *temp in exam.questArray)
//        {
//            if(_tableData == nil)
//            {
//                _tableData = [NSMutableArray array];
//            }
//            [_tableData addObject:temp];
//        }
//    }
}
-(void)initUI
{
    self.view.backgroundColor = RGBCOLOR(78,172,160);
    
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeight=CGRectGetHeight(frame);
    
    CGFloat startY=74.0f;
    CGFloat startX=0.0f;
    quest = _tableData[currIndex];
    //动画
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [view  removeFromSuperview];
    view = [[UIView alloc] initWithFrame:CGRectMake(startX, 0, viewWidth, viewHeight)];
    [self.view addSubview:view];
    [UIView commitAnimations];
    
    //标题
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, startY, viewWidth, 20)];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    
//        label.text = [NSString stringWithFormat:@"%@:%@",quest.xTitle,quest.xContent];
//        CGRect rect = [self getStringRect:label.text font:16];
//        label.frame = CGRectMake(10, startY, rect.size.width, rect.size.height);
//        [view addSubview:label];
//        startY += rect.size.height;
//        //选择题1
//        UIButton *btn=[self createBtn:CGRectMake(startX, startY, viewWidth - 20, 20.0f) tag:0x11];
//        [btn setTitle:[NSString stringWithFormat:@"A. %@",quest.xChoiceA] forState:UIControlStateNormal];
//
//        rect = [self getStringRect:btn.titleLabel.text font:16];
//        btn.frame = CGRectMake(startX , startY, viewWidth, rect.size.height*2);
//        btn.titleLabel.frame = CGRectMake(startX, startY, rect.size.width, rect.size.height);
//        [view addSubview:btn];
//        startY += rect.size.height * 2;
//        
//        btn=[self createBtn:CGRectMake(startX, startY, viewWidth, 20.0f) tag:0x11];
//        [btn setTitle:[NSString stringWithFormat:@"B. %@",quest.xChoiceB] forState:UIControlStateNormal];
//        rect = [self getStringRect:btn.titleLabel.text font:16];
//        btn.frame = CGRectMake(startX , startY, viewWidth, rect.size.height*2);
//        btn.titleLabel.frame = CGRectMake(startX, startY, rect.size.width, rect.size.height);
//        [view addSubview:btn];
//        startY += rect.size.height * 2;
//        
//        btn=[self createBtn:CGRectMake(startX, startY, viewWidth, 20.0f) tag:0x11];
//        [btn setTitle:[NSString stringWithFormat:@"C. %@",quest.xChoiceC] forState:UIControlStateNormal];
//        rect = [self getStringRect:btn.titleLabel.text font:16];
//        btn.frame = CGRectMake(startX , startY, viewWidth, rect.size.height*2);
//        btn.titleLabel.frame = CGRectMake(startX, startY, rect.size.width, rect.size.height);
//        [view addSubview:btn];
//        startY += rect.size.height * 2;
//        btn=[self createBtn:CGRectMake(startX, startY, viewWidth, 20.0f) tag:0x11];
//        [btn setTitle:[NSString stringWithFormat:@"D. %@",quest.xChoiceD] forState:UIControlStateNormal];
//        rect = [self getStringRect:btn.titleLabel.text font:16];
//        btn.frame = CGRectMake(startX , startY, viewWidth, rect.size.height*2);
//        btn.titleLabel.frame = CGRectMake(startX, startY, rect.size.width, rect.size.height);
//        [view addSubview:btn];
//        startY += rect.size.height * 2;
 
    
//    else //简答题
//    {
//        label.text = [NSString stringWithFormat:@"%@:%@",quest.jTitle,quest.jContent];
//        CGRect rect = [self getStringRect:label.text font:16];
//        label.frame = CGRectMake(10, startY, rect.size.width, rect.size.height);
//        [view addSubview:label];
//        startY += rect.size.height;
//        
//        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, startY, viewWidth - 20, 100)];
//        textView.delegate = self;
//        [view addSubview:textView];
//        startY += 100;
//    }
    UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
    btn.tag = 0x12;
    btn.center = CGPointMake(viewWidth/2, 400);
    int nextIndex = currIndex;
    [btn setTitle:[NSString stringWithFormat:@"下一题"] forState:UIControlStateNormal];
    if(++ nextIndex == _tableData.count)
        [btn setTitle:[NSString stringWithFormat:@"没有更多了"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(UIView *)createLine:(CGRect)frame
{
    UIView *line=[[UIView alloc] initWithFrame:frame];
    line.backgroundColor=kLineColor;
    return line;
}
-(UIButton *) createBtn:(CGRect )frame tag:(NSInteger) tag
{
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=frame;
    btn.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
    btn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    btn.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    [btn setTitleColor:KWordBlackColor forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:16.0f];
    btn.backgroundColor=[UIColor clearColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.numberOfLines = 0;
    btn.tag=tag;
    
    return btn;
}
//选项选中
-(void)clickBtn:(UIButton *)sender
{
    switch (sender.tag) {
        case 0x11:{
            //三部曲
            selectedBtn.selected = NO;
            selectedBtn = sender;
            selectedBtn.selected = YES;
        }
            break;
        case 0x12:{//下一题 按钮
            
            //计算分数
            NSString *rigth = @"5";
            if([rigth characterAtIndex:0] == [selectedBtn.titleLabel.text characterAtIndex:0])
            {
                scores += quest.score;
            }

            //进入下一题
            currIndex ++;
            if(currIndex < _tableData.count)
                [self initUI];
            else
            {
                //最后一题 完成结算分数
                [UIView beginAnimations:@"View Flip" context:nil];
                [UIView setAnimationDuration:1.0];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
                //从右往左翻，启用缓存
                [view  removeFromSuperview];
                view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
                [self.view insertSubview:view atIndex:0];
                 [UIView commitAnimations];

                //标题
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:16];
                label.numberOfLines = 0;
                label.text = [NSString stringWithFormat:@"成绩:%i",scores];
                label.textColor = [UIColor whiteColor];
                [self.view addSubview:label];
                
                UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
                btn.tag = 0x13;
                btn.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 400);
                [btn setTitle:[NSString stringWithFormat:@"完成"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
                
                //显示错误的题目和正确的答案
            }
        }
            break;
        case 0x13:{
            //完成 提交成绩  //成绩显示在作业的右侧
            NSLog(@"完成 提交成绩");
            
            //回到详情页
            [self.navigationController popViewControllerAnimated:YES];
           
        }
            break;
        default:
            break;
    }
}
-(CGRect)getStringRect:(NSString *)text font:(int)size
{
    //-------------得到字符串的长度-----------//
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: [UIFont systemFontOfSize:size], NSParagraphStyleAttributeName:paragraphStyle.copy
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){self.view.frame.size.width - 20, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    ////--------------------------//
    return rect;
}


@end
