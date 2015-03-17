//
//  CodeVerifyView.m
//  OutdoorClub
//
//  Created by yulong chen on 13-1-8.
//  Copyright (c) 2013年 qw. All rights reserved.
//

#import "CodeVerifyView.h"
//#import "OpenApiLocalizedString.h"
@interface UIAlertView (private)
- (void)layoutAnimated:(BOOL)fp8;
@end

@interface CodeVerifyView ()
@property (nonatomic, assign) UITextField *codeField;
@end

// Enum for alert view button index
typedef enum {
    ShakingAlertViewButtonIndexDismiss = 0,
    ShakingAlertViewButtonIndexSuccess = 1
} ShakingAlertViewButtonIndex;

@implementation CodeVerifyView
@synthesize verifyDelegate=_verifyDelegate;
@synthesize codeField=_codeField;
@synthesize textPlaceholder=_textPlaceholder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.keyboardType=UIKeyboardTypeDefault;
        self.textPlaceholder= @"请输入验证码";
        self.alertViewStyle=UIAlertViewStylePlainTextInput;
    }
    return self;
}

- (id)initWithAlertTitle:(NSString *)title withVerifyDelegate:(id<CodeVerifyViewDelegate>) verifyDelegate{    
    self = [super initWithTitle:title     
                        message:nil //@"---blank---" // password field will go here
                       delegate:self 
              cancelButtonTitle:@"取消" 
              otherButtonTitles:@"确定",nil];
    if (self) {
        self.verifyDelegate  = verifyDelegate;
        self.keyboardType=UIKeyboardTypeDefault;
        self.textPlaceholder = @"请输入验证码";
        self.alertViewStyle=UIAlertViewStylePlainTextInput;
    }
    return self;
}

- (id)initWithAlertTitle:(NSString *)title withOkText:(NSString*)okText withCancelText:(NSString*)cancelText withVerifyDelegate:(id<CodeVerifyViewDelegate>) verifyDelegate{
    self = [super initWithTitle:title
                        message:nil //@"---blank---" // password field will go here
                       delegate:self
              cancelButtonTitle:cancelText
              otherButtonTitles:okText,nil];
    if (self) {
        self.verifyDelegate  = verifyDelegate;
        self.keyboardType=UIKeyboardTypeDefault;
        self.textPlaceholder = @"请输入验证码";
        self.alertViewStyle=UIAlertViewStylePlainTextInput;
    }
    return self;
}

// Override show method to add the password field
- (void)show {
    if (self.alertViewStyle==UIAlertViewStylePlainTextInput) {
        UITextField *textField=[self textFieldAtIndex:0];
        textField.placeholder=self.textPlaceholder;
        textField.keyboardType=self.keyboardType;
        textField.text=self.defaultText;
        self.codeField=textField;
    }
    [super show];
}

- (void)animateIncorrectPassword {
    // Clear the password field
    
    // Animate the alert to show that the entered string was wrong
    // "Shakes" similar to OS X login screen
    CGAffineTransform moveRight = CGAffineTransformTranslate(CGAffineTransformIdentity, 20, 0);
    CGAffineTransform moveLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -20, 0);
    CGAffineTransform resetTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    
    [UIView animateWithDuration:0.1 animations:^{
        // Translate left
        self.transform = moveLeft;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            // Translate right
            self.transform = moveRight;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                // Translate left
                self.transform = moveLeft;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.1 animations:^{
                    
                    // Translate to origin
                    self.transform = resetTransform;
                }];
            }];
            
        }];
    }];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // Hide keyboard
        [self.codeField resignFirstResponder];
        if ([_verifyDelegate respondsToSelector:@selector(verifyViewDidSelectedOnOk:withCode:)]) {
            [_verifyDelegate verifyViewDidSelectedOnOk:self withCode:_codeField.text];
        }
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView{
    if (_codeField) {
        [_codeField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    if (![self enteredTextIsCorrect]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    // Check password
    if ([self enteredTextIsCorrect]) {
        [self.codeField resignFirstResponder];
        if ([_verifyDelegate respondsToSelector:@selector(verifyViewDidSelectedOnOk:withCode:)]) {
            [_verifyDelegate verifyViewDidSelectedOnOk:self withCode:_codeField.text];
        }
        return YES;
    }
    
    // Password is incorrect to so animate
    [self animateIncorrectPassword];
    return NO;
}

- (BOOL)enteredTextIsCorrect {
    NSString *text=_codeField.text;
    if ([_verifyDelegate respondsToSelector:@selector(enteredTextIsCorrect:)]) {
        return [_verifyDelegate enteredTextIsCorrect:text];
    }else{
        return text && ![text isEqualToString:@""];
    }
}

#pragma mark - Memory Managment
- (void)dealloc {
    self.codeField=nil;
    self.textPlaceholder=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
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
