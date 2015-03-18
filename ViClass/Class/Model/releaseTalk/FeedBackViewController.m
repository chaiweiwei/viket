//
//  SendCommentViewController.m
//  Zenithzone
//
//  Created by alidao on 14-11-7.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "FeedBackViewController.h"
#import "ALDButton.h"
#import "NSDictionaryAdditions.h"

#define kPlaceHolder @"写反馈..."

@interface FeedBackViewController ()<DataLoadStateDelegate,UITextViewDelegate,UIWebViewDelegate>
{
    BOOL _isWebViewLoaded;
}
//@property (nonatomic,retain) UITextView *txtViewContent;
//@property (nonatomic,retain) ALDButton *sendBtn;

@end

@implementation FeedBackViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    _isWebViewLoaded=NO;
    
    CGRect frame=self.view.frame;
    CGFloat startY=self.baseStartY;
    UIWebView *webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, startY, CGRectGetWidth(frame), CGRectGetHeight(frame)-startY)];
    webView.delegate=self;
    webView.backgroundColor=[UIColor clearColor];
    webView.dataDetectorTypes=UIDataDetectorTypeLink;
    webView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    
    NSUserDefaults *config = [NSUserDefaults standardUserDefaults];
    NSString *uid = [config objectForKey:kUidKey];
    
    NSString *urlStr;
    if(self.type == 1)
    {
        urlStr = [NSString stringWithFormat:@"%@h5/feedback/send?uid=%@",kServerUrl,uid];
    }
    else if (self.type == 2)
    {
        urlStr = [NSString stringWithFormat:@"%@h5/report/send?sourceId=%@&type=5",kServerUrl,_sourceId];
    }
    NSURL *url=[NSURL URLWithString:urlStr];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    NSDictionary *heads=[BasicsHttpClient getExtraHeads:urlStr];
    NSArray *allKeys=[heads allKeys];
    for (NSString *key in allKeys) {
        NSString *value=[heads objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    [webView loadRequest:request];
    
    // Do any additional setup after loading the view.
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    //NSLog(@"webViewDidStartLoad****");
    [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    //NSLog(@"webViewDidFinishLoad****");
    if (webView.loading)
        return;
    _isWebViewLoaded=YES;
    [ALDUtils removeWaitingView:self.view];
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(error) NSLog(@"didFailLoadWithError****");
    _isWebViewLoaded=YES;
    [ALDUtils removeWaitingView:self.view];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *scheme=request.URL.scheme;
    if([scheme isEqualToString:@"tel"]){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }else if([scheme isEqualToString:@"sms"]){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }else if([scheme isEqualToString:@"mailto"]){
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
        //    }else{
        //        NSString *absoluteString=request.URL.absoluteString;
        //        NSString *soluteString=nil;
        //        if ([absoluteString hasSuffix:@"/"]) {
        //            soluteString=[absoluteString substringToIndex:absoluteString.length-1];
        //        }
        //        if (_isWebViewLoaded && ![absoluteString isEqualToString:self.url]
        //            && (!soluteString || ![soluteString isEqualToString:self.url])) {
        //            CIALBrowserViewController *controller=[[CIALBrowserViewController alloc] init];
        //            controller.url=request.URL;
        //            controller.enabledSafari=YES;
        //            controller.hidesBottomBarWhenPushed=YES;
        //            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:ALDLocalizedString(@"Close", @"关闭") style:UIBarButtonItemStyleBordered target:nil action:nil];
        //            [self.navigationItem setBackBarButtonItem:backItem];
        //            [self.navigationController pushViewController:controller animated:YES];
        //            return NO;
        //        }
    }
    return YES;
}
//    ALDButton *btn=[ALDButton buttonWithType:UIButtonTypeCustom];
//    btn.frame=CGRectMake(0, 0, 60, 44);
//    [btn setTitle:@"提交" forState:UIControlStateNormal];
//    btn.backgroundColor=[UIColor clearColor];
//    btn.selectBgColor=[UIColor clearColor];
//    btn.tag=0x11;
//    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem=rightItem;
//    self.sendBtn=btn;
    
    //[self initUI];

//}

//- (void)initUI
//{
//    float fStartY = 10; //纵坐标
//    CGFloat viewWidth=CGRectGetWidth(self.view.frame);
//    
//    //------------------
//    // 文字输入框
//    //------------------
//    _txtViewContent = [[UITextView alloc] initWithFrame:CGRectMake(10, fStartY, viewWidth-20, 120)];
//    _txtViewContent.layer.borderColor = [UIColor blackColor].CGColor;
//    _txtViewContent.layer.borderWidth = 1;
//    _txtViewContent.text              = kPlaceHolder;
//    _txtViewContent.font              = [UIFont systemFontOfSize:15.0f];
//    _txtViewContent.delegate          = self;
//    [self.view addSubview:_txtViewContent];
//    
//    fStartY = fStartY + _txtViewContent.frame.size.height;
//    UILabel *labRemind = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth-70, fStartY, 60, 20)];
//    labRemind.text = @"最多140字";
//    labRemind.font = [UIFont systemFontOfSize:12.0f];
//    labRemind.textColor       = [UIColor blackColor];
//    labRemind.backgroundColor = [UIColor clearColor];
//    labRemind.textAlignment   = TEXT_ALIGN_Right;
//    [self.view addSubview:labRemind];
//
//}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.view endEditing:YES];
//}
//-(void)clickBtn:(ALDButton *)sender
//{
//    NSString *strText = _txtViewContent.text;
//    if (!strText || [strText isEqualToString:@""] || [strText isEqualToString:kPlaceHolder]) {
//        [_txtViewContent becomeFirstResponder];
//        [ALDUtils showToast:@"请输入文字"];
//        return;
//    } else {
//        int count=[ALDUtils captureTextCount:strText];
//        if (count>140) {
//            [ALDUtils showToast:[NSString stringWithFormat:@"输入内容超过了%d个字，请删减.",(count-140)]];
//            return;
//        }else {
//            sender.enabled = NO;
//        }
//    }
//}
//- (void)textViewDidBeginEditing:(UITextView *)textView
//{
//    if ([textView.text isEqualToString:kPlaceHolder])
//    {
//        textView.text      = @"";
//        textView.textColor = [UIColor blackColor];
//    }
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView
//{
//    NSString *strText = _txtViewContent.text;
//    if (!strText || [strText isEqualToString:@""])
//    {
//        textView.text = kPlaceHolder;
//        textView.textColor = [UIColor lightTextColor];
//    }
//}
//
//-(void)dealloc
//{
//    self.sid=nil;
//    self.txtViewContent=nil;
//    self.sendBtn=nil;
//#if ! __has_feature(objc_arc)
//    [super dealloc];
//#endif
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
