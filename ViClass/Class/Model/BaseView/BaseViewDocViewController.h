//
//  ViewDocViewController.h
//  hyt_pro
//  资料浏览
//  Created by yulong chen on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpClient.h"
#import "BaseViewController.h"
typedef enum: NSInteger{
    FinishStyleWithPlay = 1, //下载完播放
    FinishStyleWithSave = 2, //下载完保存

}FinishStyle;

@interface BaseViewDocViewController : BaseViewController<UIWebViewDelegate,UIAlertViewDelegate,DataLoadStateDelegate>{
    UIInterfaceOrientation previousOrientation;
    BOOL backClicked;
}

@property (retain,nonatomic) UILabel *textLabel;
@property (retain,nonatomic) UIWebView *webView;
@property (retain, nonatomic)  UIProgressView *progressView;
@property (retain, nonatomic)  UILabel *progressText;

@property (retain,nonatomic) NSString *docUrl; //文档url
@property (nonatomic) long docSize; //文档大小，单位b
@property (retain,nonatomic) NSString *docName; //文档名称
@property (retain,nonatomic) NSString *fileType; //文档类型
//--------
@property (assign,nonatomic) FinishStyle type; //下载完后的操作

- (void)setProgress:(float)progress;
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
