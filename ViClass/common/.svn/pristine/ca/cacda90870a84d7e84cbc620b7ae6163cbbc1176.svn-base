//
//  ALDSmsPicker.m
//  hyt_ios
//
//  Created by yulong chen on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ALDSmsPicker.h"
#import "ALDUtils.h"
#import "ViewsLocalizedString.h"

@interface ALDSmsPicker (private)
- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg;
- (void)displaySMS:(NSString *)message;
@end

@implementation ALDSmsPicker
@synthesize rootViewController=_rootViewController;


- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertView*alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:ViewsLocalizedString(@"确定",@"OK",@"") otherButtonTitles:nil];
    [alert show];
    ALDRelease(alert);
}
                         
#pragma mark -
#pragma mark SMS
- (void)displaySMS:(NSString *)message  {
    
    MFMessageComposeViewController*picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate= self;
    picker.navigationBar.tintColor= [UIColor blackColor];
    picker.body = message; // 默认信息内容
    // 默认收件人(可多个)
    //picker.recipients = [NSArray arrayWithObject:@"12345678901", nil];
    [_rootViewController presentViewController:picker animated:YES completion:^{
        
    }];
    ALDRelease(picker);
}

- (void)sendsms:(NSString *)message {
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            [self displaySMS:message];
        } else {
            [self alertWithTitle:nil msg:ViewsLocalizedString(@"设备没有短信功能",@"device no msg",@"")];
        }
    } else { 
        [self alertWithTitle:nil msg:ViewsLocalizedString(@"iOS版本过低，iOS4.0以上才支持程序内发送短信",@"not support msg",@"")];
    }
    
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
                 didFinishWithResult:(MessageComposeResult)result {
    NSString*msg;
    switch (result) {
        case MessageComposeResultCancelled:
            msg = ViewsLocalizedString(@"你已取消短信分享",@"cancel msg",@"");
            break;
        case MessageComposeResultSent:
            msg = ViewsLocalizedString(@"短信分享成功",@"msg ok",@"");
            //[self alertWithTitle:nil msg:msg];
            break;
        case MessageComposeResultFailed:
            msg = ViewsLocalizedString(@"短信分享失败",@"msg failed",@"");
            //[self alertWithTitle:nil msg:msg];
            break;
        default:
            break;
    }
    
    NSLog(@"发送结果：%@", msg);
    
    [_rootViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (msg) {
        [ALDUtils showToast:_rootViewController.view withText:msg];
    }
}

- (void)dealloc
{
    self.rootViewController=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}
@end
