//
//  CodeVerifyView.h
//  OutdoorClub
//
//  Created by yulong chen on 13-1-8.
//  Copyright (c) 2013年 qw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CodeVerifyView;

@protocol CodeVerifyViewDelegate <NSObject>

@optional
-(void) verifyViewDidSelectedOnCancel:(CodeVerifyView*)view;

-(void) verifyViewDidSelectedOnOk:(CodeVerifyView*)view withCode:(NSString*)code;

- (BOOL) enteredTextIsCorrect:(NSString*) text;
@end

@interface CodeVerifyView : UIAlertView<UITextFieldDelegate>
@property (assign,nonatomic) UIKeyboardType keyboardType;

@property (retain,nonatomic) NSString *textPlaceholder;
@property (retain,nonatomic) NSString *defaultText;

@property (assign,nonatomic) id<CodeVerifyViewDelegate> verifyDelegate;
- (id)initWithAlertTitle:(NSString *)title withVerifyDelegate:(id<CodeVerifyViewDelegate>) verifyDelegate;

- (id)initWithAlertTitle:(NSString *)title withOkText:(NSString*)okText withCancelText:(NSString*)cancelText withVerifyDelegate:(id<CodeVerifyViewDelegate>) verifyDelegate;

@end
