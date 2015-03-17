//
//  ALDUtils.m
//  hyt
//
//  Created by yulong chen on 12-4-12.
//  Copyright (c) 2012年 qw. All rights reserved.
//

#import "ALDUtils.h"
#import "SBJson.h"
#import "WaitingView.h"
#import "ALDToastView.h"
#import "ALDHttpClient.h"

@implementation UIWebView (JavaScriptAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    NSString *btnText=ViewsLocalizedString(@"确定",@"OK",@"");
    [ALDUtils showAlert:ViewsLocalizedString(@"温馨提示",@"MsgTips",@"") strForMsg:message withTag:10001 withDelegate:nil cancelButtonTitle:btnText otherButtonTitles:nil];
    
}
@end

@implementation ALDUtils

/** 将字符串时间转换成NSDate **/
+(NSDate *) getDateWithString:(NSString *)strDate format:(NSString *)format{
    if (!strDate|| [strDate isEqualToString:@""] || !format) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:strDate];
    ALDRelease(formatter);
    return date;
}

/** 获取指定格式的当前系统时间字符串 **/
+(NSString *) getFormatDate:(NSString *) format{
    NSDate *nowDate = [NSDate date];// 获取本地时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];  // 格式化时间NSDate
    NSString *stringFromDate = [formatter stringFromDate:nowDate];//转换成字符串并格式化时间格式。
    ALDRelease(formatter);
    return  stringFromDate;
}

/** 获取给定日期的指定格式字符串 **/
+(NSString *) getFormatDate:(NSString *) format withDate:(NSDate *) date{
    if(!date) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];  // 格式化时间NSDate
    NSString *stringFromDate = [formatter stringFromDate:date];//转换成字符串并格式化时间格式。
    ALDRelease(formatter);
    return  stringFromDate;
}

/** 获取给定日期的指定格式字符串 **/
+(NSString *) getFormatDateWithString:(NSString *) strDate withOldFormat:(NSString *)oldFormat withNewFormat:(NSString *) newFormat{
    if(!strDate || [strDate isEqualToString:@""]) return nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:oldFormat];
    NSDate *date = [formatter dateFromString:strDate];
    if (!date) {
        ALDRelease(formatter);
        return nil;
    }
    [formatter setDateFormat:newFormat];  // 格式化时间NSDate
    NSString *stringFromDate = [formatter stringFromDate:date];//转换成字符串并格式化时间格式。
    ALDRelease(formatter);
    return  stringFromDate;
}

//将字符串转换成json对象的NSDictionary
+(id) getJSONObjectFromString:(NSString *) str{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id repr = [parser objectWithString:str];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", parser.error);
    ALDRelease(parser);
    return repr;
}

/**
 * 将字典和数组混合的多层多层次数据转化为JSON数据
 * obj为字典或数组
 */
+(NSString *)getJSONStringFromObj:(id)obj {
    if (obj==nil) {
        return @"";
    }
    
    SBJsonWriter *json = [[SBJsonWriter alloc] init];
    NSString *result=[json stringWithObject:obj];
    ALDRelease(json);
    return result;
}

/**
 * 将字典和数组混合的多层多层次数据转化为JSON数据
 * @param obj为字典或数组
 * @param error 返回的错误
 * @return 返回json格式字符串
 */
+(NSString *) getJSONStringFromObj:(id)obj withError:(NSError **)error{
    SBJsonWriter *json = [[SBJsonWriter alloc] init];
    NSString *result=[json stringWithObject:obj];
    ALDRelease(json);
    return result;
}

/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 */
+(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value{
    [ALDUtils dictionarySetValue:dic key:key value:value withDefault:@""];
}

/**
 * 将键值放入目标字典里，对NSMutableDictionary进行了封装，nil值进行了过滤，防止crash
 * key 键名
 * value 值
 * defaultValue 默认值，当value为nil时使用该值代替
 */
+(void) dictionarySetValue:(NSMutableDictionary *) dic key:(id)key value:(id)value withDefault:(id) defaultVaule{
    if(!key){
        return ;
    }
    if(!value){
        if(!defaultVaule){
            defaultVaule=@"";
        }
        value=defaultVaule;
    }
    [dic setObject:value forKey:key];
}


/**
 * 保存数据到tmp文件夹
 * @param filename 文件名
 * @param data 要保存的数据
 * 成功返回YES,失败返回NO
 **/
+(BOOL) saveDataToTmpFile:(NSString *) filename withData:(NSString *) data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"temp"];
    // [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory=NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory] || !isDirectory) {
        NSError *error=nil;
        BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!res) {
            if (error) {
                NSLog(@"create temp path:%@ failed! Error:%@",path,error);
            }else {
                NSLog(@"create temp path:%@ failed!",path);
            }
        }
    }
    path=[path stringByAppendingPathComponent:filename];
    NSError *error=nil;
    if([fileManager fileExistsAtPath:path]){
        [fileManager removeItemAtPath:path error:&error];
        if(error){
            NSLog(@"delete file %@ Error:%@",path,error);
        }else{
            //NSLog(@"delete tmp file %@ ",path);
        }
    }
    BOOL success=[fileManager createFileAtPath:path contents:[data dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    ALDRelease(fileManager);
    return success;
    
}

/**
 * 读取tmp文件数据
 * @param filename 文件名
 * 成功返回字符串数据，失败返回nil
 **/
+(NSString *) readDataFromTmpFile:(NSString *) filename{
    //NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"temp"];
    // [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    path=[path stringByAppendingPathComponent:filename];
    if([fileManager fileExistsAtPath:path]){
        NSData *data = [NSData dataWithContentsOfFile:path];
        ALDRelease(fileManager);
        NSString *result=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return ALDReturnAutoreleased(result);
    }
    ALDRelease(fileManager);
    return nil;
}

/**
 * 删除tmp文件数据
 * @param filename 文件名
 **/
+(void) deleteTmpFile:(NSString *) filename{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if([fileManager fileExistsAtPath:path]){
        NSError *error=nil;
        [fileManager removeItemAtPath:path error:&error];
        if(error){
            NSLog(@"delete file %@ Error:%@",path,error);
        }
    }
    ALDRelease(fileManager);
}

#pragma mark - custom method
/**
 * 添加提示信息，如果有等待状态则更改
 * @param rootView 等待视图添加到的根视图
 * @param text 提示文字
 */
+ (void)changeWaitingViewStatus:(UIView *)rootView withText:(NSString *) text{
    //NSLog(@"加载页面失败哦");
    WaitingView *waitingView = (WaitingView *)[rootView viewWithTag:kWaitingViewTag];
    if (!waitingView) {
        CGRect rc = CGRectMake((CGRectGetWidth(rootView.frame)-200)/2.f, (CGRectGetHeight(rootView.frame)-120)/3.f,200, 120);
        waitingView = [[WaitingView alloc] initWithFrame:rc];
        waitingView.activityPosition=WaitingActivityInTop;
        waitingView.tag = kWaitingViewTag;
        waitingView.showMessage = text;
        [rootView addSubview:waitingView];
        waitingView.warningView.hidden = NO;
        waitingView.activityIndicatorView.hidden = YES;
        ALDRelease(waitingView);
    }else {
        waitingView.warningView.hidden = NO;
        waitingView.activityIndicatorView.hidden = YES;
        waitingView.showMessage = text;
        [waitingView setNeedsDisplay];
    }
}

/**
 * 添加等待状态信息，如果有提示状态则更改
 * @param rootView 等待视图添加到的根视图
 * @param text 提示文字
 */
+ (void) addWaitingView:(UIView *) rootView withText:(NSString *) text{
    WaitingView *waitingView = (WaitingView *)[rootView viewWithTag:kWaitingViewTag];
    if (!waitingView) {
        CGRect rc = CGRectMake((CGRectGetWidth(rootView.frame)-200)/2.f, (CGRectGetHeight(rootView.frame)-120)/3.f,200, 120);
        waitingView = [[WaitingView alloc] initWithFrame:rc];
        waitingView.activityPosition=WaitingActivityInTop;
        waitingView.tag = kWaitingViewTag;
        waitingView.showMessage = text;
        [rootView addSubview:waitingView];
        ALDRelease(waitingView);
    }else {
        waitingView.warningView.hidden=YES;
        waitingView.showMessage = text;
        [waitingView setNeedsDisplay];
        [rootView bringSubviewToFront:waitingView];
    } 
}

/**
 * 添加等待状态信息，如果有提示状态则更改
 * @param rootView 等待视图添加到的根视图
 * @param frame 
 * @param text 提示文字
 */
+ (void) addWaitingView:(UIView *) rootView frame:(CGRect)frame withText:(NSString *) text{
    WaitingView *waitingView = (WaitingView *)[rootView viewWithTag:kWaitingViewTag];
    if (!waitingView) {
        waitingView = [[WaitingView alloc] initWithFrame:frame];
        waitingView.activityPosition=WaitingActivityInTop;
        waitingView.tag = kWaitingViewTag;
        waitingView.showMessage = text;
        [rootView addSubview:waitingView];
        waitingView.center=rootView.center;
        ALDRelease(waitingView);
    }else {
        waitingView.warningView.hidden=YES;
        waitingView.showMessage = text;
        [waitingView setNeedsDisplay];
    }
}

/**
 * 将之前添加的等待或提示信息移除
 * @param rootView 之前添加到的根视图
 **/
+ (void)removeWaitingView:(UIView *) rootView{
    //NSLog(@"页面加载完成哦");
    UIView *waitingView = [rootView viewWithTag:kWaitingViewTag];
    if (waitingView) {
        [waitingView removeFromSuperview];
    }
    
}

/**
 * 显示Toast提示信息，提示信息2秒后消失
 * @param text 提示文字
 */
+(void) showToast:(NSString *) text{
    [ALDUtils showToast:text withInterval:2.0f];
}

/**
 * 显示Toast提示信息，提示信息2秒后消失
 * @param text 提示文字
 * @param interval 提示信息显示时长，单位秒
 */
+(void) showToast:(NSString *) text withInterval:(float) interval{
    CGRect rc = CGRectMake(10, 150, 300, 40);
    ALDToastView *toastView = [[ALDToastView alloc] initWithFrame:rc];
    toastView.showTimes=interval;
    [toastView setTipsMessage:text];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:toastView];
    toastView.center=CGPointMake(window.center.x, rc.origin.y);
    ALDRelease(toastView);
}

/**
 * 显示Toast提示信息，提示信息2秒后消失
 * @param rootView 等待视图添加到的根视图
 * @param text 提示文字
 */
+(void) showToast:(UIView *) rootView withText:(NSString *)text{
    [ALDUtils showToast:rootView withText:text withInterval:2.0];
}

/**
 * 显示Toast提示信息，提示信息interval秒后消失
 * @param rootView 等待视图添加到的根视图
 * @param text 提示文字
 * @param interval 提示信息显示时长，单位秒
 */
+(void) showToast:(UIView *)rootView withText:(NSString *) text withInterval:(float) interval{
    CGRect rc = CGRectMake(10, 150, 300, 40);
    ALDToastView *toastView = [[ALDToastView alloc] initWithFrame:rc];
    toastView.showTimes=interval;
    [toastView setTipsMessage:text];
    [rootView addSubview:toastView];
    toastView.center=CGPointMake(rootView.center.x, rc.origin.y);
    ALDRelease(toastView);
}

/**
 * 显示提示信息
 * @param parentView 父级视图
 * @param text 提示文字
 **/
+(UILabel*) showTips:(UIView *)parentView text:(NSString *)text{
    return [ALDUtils showTips:parentView frame:CGRectMake(10, 30, CGRectGetWidth(parentView.frame)-20, 160) text:text];
}

/**
 * 显示提示信息
 * @param parentView 父级视图
 * @param frame 提示信息的frame
 * @param text 提示文字
 **/
+(UILabel*) showTips:(UIView *) parentView frame:(CGRect)frame text:(NSString*) text{
    UILabel *textView=(UILabel*)[parentView viewWithTag:kTipsTextTag];
    if (textView==nil) {
        CGFloat tempH=frame.size.height;
        CGFloat height=tempH>160?tempH-100:tempH;
        CGRect newFrame=CGRectMake(frame.origin.x+10, frame.origin.y, frame.size.width-20, height);
        textView=[[UILabel alloc] initWithFrame:newFrame];
        textView.textColor=[UIColor blackColor];
        textView.tag=kTipsTextTag;
        textView.backgroundColor=[UIColor clearColor];
        textView.textAlignment=TEXT_ALIGN_CENTER;
        textView.font = [UIFont boldSystemFontOfSize:16];
        textView.highlighted = YES;//设置高亮      
        textView.numberOfLines=0;
        textView.adjustsFontSizeToFitWidth =  YES ; //设置字体大小适应label宽度
        textView.text=text;
        [parentView addSubview:textView];
        ALDRelease(textView);
    }else {
        textView.frame=frame;
        textView.text=text;
    }
    return textView;
}

/**
 * 显示提示信息
 * @param parentView 父级视图
 * @param frame 提示信息的frame
 * @param text 提示文字
 * @param color 文字颜色
 **/
+(UILabel*) showTips:(UIView *) parentView frame:(CGRect)frame text:(NSString*) text textColor:(UIColor*)color{
    UILabel *textView=(UILabel*)[parentView viewWithTag:kTipsTextTag];
    if (textView==nil) {
        CGFloat tempH=frame.size.height;
        CGFloat height=tempH>160?tempH-100:tempH;
        CGRect newFrame=CGRectMake(frame.origin.x+10, frame.origin.y, frame.size.width-20, height);
        textView=[[UILabel alloc] initWithFrame:newFrame];
        textView.textColor=color;
        textView.tag=kTipsTextTag;
        textView.backgroundColor=[UIColor clearColor];
        textView.textAlignment=TEXT_ALIGN_CENTER;
        textView.font = [UIFont boldSystemFontOfSize:16];
        textView.highlighted = YES;//设置高亮      
        textView.numberOfLines=0;
        textView.adjustsFontSizeToFitWidth =  YES ; //设置字体大小适应label宽度
        textView.text=text;
        [parentView addSubview:textView];
        ALDRelease(textView);
    }else {
        textView.frame=frame;
        textView.text=text;
    }
    return textView;
}

/**
 * 隐藏提示信息
 * @param parentView 父级视图
 **/
+(void) hiddenTips:(UIView*) parentView{
    UILabel *textView=(UILabel*)[parentView viewWithTag:kTipsTextTag];
    [textView removeFromSuperview];
}

+(void) showAlert:(NSString*) title strForMsg:(NSString*) msg withTag:(NSInteger) tag otherButtonTitles:(NSString*) btnTitle{
    UIAlertView* alert;
    if(btnTitle){
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:ViewsLocalizedString(@"关闭",@"Close",@"") otherButtonTitles:btnTitle,nil];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:ViewsLocalizedString(@"关闭",@"Close",@"") otherButtonTitles:btnTitle,nil];
    }
    alert.tag = tag;
    [alert show];
    ALDRelease(alert);
}

+(void) showAlert:(NSString*) title strForMsg:(NSString*) msg withTag:(NSInteger) tag withDelegate:(id<UIAlertViewDelegate>)delegate otherButtonTitles:(NSString*) btnTitle{
    UIAlertView* alert;
    if(btnTitle){
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:ViewsLocalizedString(@"关闭",@"Close",@"") otherButtonTitles:btnTitle,nil];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:ViewsLocalizedString(@"关闭",@"Close",@"") otherButtonTitles:btnTitle,nil];
    }
    alert.tag = tag;
    [alert show];
    ALDRelease(alert);
}

+(void) showAlert:(NSString*) title strForMsg:(NSString*) msg withTag:(NSInteger) tag withDelegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*) btnTitle{
    UIAlertView* alert;
    if(btnTitle){
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:btnTitle,nil];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:btnTitle,nil];
    }
    alert.tag = tag;
    [alert show];
    ALDRelease(alert);
}

//计算单行文本占用高度
+(CGFloat) captureTextHeightWithText:(NSString *) text font:(UIFont *)font{
    if (!text || ![text isKindOfClass:[NSString class]]) {
        return 0.f;
    }
    CGSize size = [text sizeWithFont:font];
    return size.height;
}

//计算文本占用高度和宽度
+(CGSize) captureTextSizeWithText:(NSString *) text textWidth:(float)width font:(UIFont *)font{
    if (!text || ![text isKindOfClass:[NSString class]]) {
        return CGSizeZero;
    }
    //self.frame.size.width-kAcWidth-kDistance - (kLeft * 2)
    CGSize constraint = CGSizeMake(width, 20000.0f);
    CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:LineBreakModeWordWrap];
    return size;
}

/**
 * 格式化展览时间
 * @param beginTime 活动开始时间
 * @param endTime 活动结束时间
 * @return 格式化后的时间
 **/
+(NSString *) delExhibDate:(NSString *)beginTime endTime:(NSString *)endTime{
    if (!beginTime || ![beginTime isKindOfClass:[NSString class]]) {
        beginTime=[beginTime description];
    }
    if (!endTime || ![endTime isKindOfClass:[NSString class]]) {
        endTime=[endTime description];
    }
    NSString *defaultFormat=nil;
    if(beginTime.length==@"yyyy-MM-dd HH:mm:ss".length ||endTime.length==@"yyyy-MM-dd HH:mm:ss".length ){
        defaultFormat=@"yyyy-MM-dd HH:mm:ss";
    }else if(beginTime.length==@"yyyy-MM-dd".length ||endTime.length==@"yyyy-MM-dd".length ){
        defaultFormat=@"yyyy-MM-dd";
    }else{
        defaultFormat=@"yyyy-MM-dd HH:mm";
    }
    NSRange range=[beginTime rangeOfString:@"."];
    if (range.location!=NSNotFound) {
        beginTime=[beginTime substringToIndex:range.location];
    }
    range=[endTime rangeOfString:@"."];
    if (range.location!=NSNotFound) {
        endTime=[endTime substringToIndex:range.location];
    }
    NSString *format=nil;//ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
    if (!beginTime && !endTime) {
        return @"";
    }else if(!endTime || [endTime isEqualToString:@""]) {
        NSDate *bDate=[ALDUtils getDateWithString:beginTime format:defaultFormat];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *bcomps = [calendar components:unitFlags fromDate:bDate];
        NSDateComponents *nowcomps=[calendar components:unitFlags fromDate:[NSDate date]];
        ALDRelease(calendar);
        if (bcomps.year!=nowcomps.year) {
            format=ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"");
        }else {
            format=ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
        }
        return [ALDUtils getFormatDateWithString:beginTime withOldFormat:defaultFormat withNewFormat:format];
    }
    
    
    NSDate *bDate=[ALDUtils getDateWithString:beginTime format:defaultFormat];
    NSDate *eDate=[ALDUtils getDateWithString:endTime format:defaultFormat];
    if (!bDate && !eDate) {
        return beginTime;
    }else if(!bDate) {
        return [NSString stringWithFormat:@"%@-%@",beginTime,endTime];
    }else if (!eDate) {
        return [NSString stringWithFormat:@"%@-%@",beginTime,endTime];
    }else{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *bcomps = [calendar components:unitFlags fromDate:bDate];
        NSDateComponents *ecomps = [calendar components:unitFlags fromDate:eDate];
        NSDateComponents *nowcomps=[calendar components:unitFlags fromDate:[NSDate date]];
        ALDRelease(calendar);
        NSString *endFormat=nil;
        //NSLog(@"sum:hour=%d,minute=%d,second=%d",bcomps.hour,bcomps.minute,bcomps.second);
        if (bcomps.year!=nowcomps.year || ecomps.year!=nowcomps.year) {
            format=ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"");
        }else {
            format=ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
        }
        
        if (bcomps.year!=ecomps.year) {
            format=ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"");
            return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:format withDate:eDate]];
        }else if (bcomps.month!=ecomps.month) {
            endFormat=ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
            return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:endFormat withDate:eDate]];
        }else if(bcomps.day!=ecomps.day){
            endFormat=ViewsLocalizedString(@"MM月dd日",@"mouth day", @"");
            return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:endFormat withDate:eDate]];
        }else {
            return [NSString stringWithFormat:@"%@",[ALDUtils getFormatDate:format withDate:bDate]];
        }
    }
}

/**
 * 格式化活动时间
 * @param beginTime 活动开始时间
 * @param endTime 活动结束时间
 * @return 格式化后的时间
 **/
+(NSString *) delEventDate:(NSString *)beginTime endTime:(NSString *)endTime{
    if (!beginTime || ![beginTime isKindOfClass:[NSString class]]) {
        beginTime=[beginTime description];
    }
    if (!endTime || ![endTime isKindOfClass:[NSString class]]) {
        endTime=[endTime description];
    }
    NSString *defaultFormat=nil;
    if(beginTime.length==@"yyyy-MM-dd HH:mm:ss".length ||endTime.length==@"yyyy-MM-dd HH:mm:ss".length ){
        defaultFormat=@"yyyy-MM-dd HH:mm:ss";
    }else if(beginTime.length==@"yyyy-MM-dd".length ||endTime.length==@"yyyy-MM-dd".length ){
        defaultFormat=@"yyyy-MM-dd";
}else{
        defaultFormat=@"yyyy-MM-dd HH:mm";
    }
    NSRange range=[beginTime rangeOfString:@"."];
    if (range.location!=NSNotFound) {
        beginTime=[beginTime substringToIndex:range.location];
    }
    range=[endTime rangeOfString:@"."];
    if (range.location!=NSNotFound) {
        endTime=[endTime substringToIndex:range.location];
    }
    NSString *format=nil;//[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"MM月dd日",@"mouth day",@"")];
    if (!beginTime && !endTime) {
        return @"";
    }else if(!endTime || [endTime isEqualToString:@""]) {
        NSDate *bDate=[ALDUtils getDateWithString:beginTime format:defaultFormat];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *bcomps = [calendar components:unitFlags fromDate:bDate];
        NSDateComponents *nowcomps=[calendar components:unitFlags fromDate:[NSDate date]];
        ALDRelease(calendar);
        if (bcomps.year!=nowcomps.year) {
            if ((bcomps.hour+bcomps.minute+bcomps.second)==0) {
                format=ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"");
            }else {
                format=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"")];
            }
        }else {
            if ((bcomps.hour+bcomps.minute+bcomps.second)==0) {
                format=ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
            }else {
                format=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"MM月dd日",@"mouth day",@"")];
            }
        }
        return [ALDUtils getFormatDateWithString:beginTime withOldFormat:defaultFormat withNewFormat:format];
    }
    
    
    NSDate *bDate=[ALDUtils getDateWithString:beginTime format:defaultFormat];
    NSDate *eDate=[ALDUtils getDateWithString:endTime format:defaultFormat];
    if (!bDate && !eDate) {
        return beginTime;
    }else if(!bDate) {
        return [NSString stringWithFormat:@"%@-%@",beginTime,endTime];
    }else if (!eDate) {
        return [NSString stringWithFormat:@"%@-%@",beginTime,endTime];
    }else{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSDateComponents *bcomps = [calendar components:unitFlags fromDate:bDate];
        NSDateComponents *ecomps = [calendar components:unitFlags fromDate:eDate];
        NSDateComponents *nowcomps=[calendar components:unitFlags fromDate:[NSDate date]];
        ALDRelease(calendar);
        NSString *endFormat=nil;
        //NSLog(@"sum:hour=%d,minute=%d,second=%d",bcomps.hour,bcomps.minute,bcomps.second);
        if (bcomps.year!=nowcomps.year || ecomps.year!=nowcomps.year) {
            if ((bcomps.hour+bcomps.minute+bcomps.second)==0) {
                format=ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"");
            }else {
                format=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"")];
            }
        }else {
            if ((bcomps.hour+bcomps.minute+bcomps.second)==0) {
                format=ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
            }else {
                format=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"MM月dd日",@"mouth day",@"")];
            }
        }
        
        if (bcomps.year!=ecomps.year) {
            if ((bcomps.hour+bcomps.minute+bcomps.second)==0) {
                format=ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"");
            }else {
                format=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"yyyy年MM月dd日",@"year mouth day",@"")];
            }
            return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:format withDate:eDate]];
        }else if (bcomps.month!=ecomps.month) {
            if ((ecomps.hour+ecomps.minute+ecomps.second)==0) {
                endFormat=ViewsLocalizedString(@"MM月dd日",@"mouth day",@"");
            }else {
                endFormat=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"MM月dd日",@"mouth day", @"")];
            }
            return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:endFormat withDate:eDate]];
        }else if(bcomps.day!=ecomps.day){
            if ((ecomps.hour+ecomps.minute+ecomps.second)==0) {
                endFormat=ViewsLocalizedString(@"MM月dd日",@"mouth day", @"");
            }else {
                endFormat=[NSString stringWithFormat:@"%@ HH:mm",ViewsLocalizedString(@"MM月dd日",@"mouth day",@"")];
            }
            return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:endFormat withDate:eDate]];
        }else {
            if ((ecomps.hour+ecomps.minute+ecomps.second)==0) {
                return [NSString stringWithFormat:@"%@",[ALDUtils getFormatDate:format withDate:bDate]];
            }else {
                return [NSString stringWithFormat:@"%@-%@",[ALDUtils getFormatDate:format withDate:bDate],[ALDUtils getFormatDate:@"HH:mm" withDate:eDate]];
            }
            
        }
    }
}

/**
 * 处理实时互动数据时间
 * @param strDate 要处理的时间
 * @return 返回处理后的时间
 **/
+(NSString*) delRealTimeData:(NSString*)strDate{
    if (!strDate || [strDate isEqualToString:@""]) {
        return nil;
    }
    //1小时内显示分钟，8小时以上显示具体时间(日期+时间)
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:strDate];
    if (!date) {
        ALDRelease(formatter);
        return strDate;
    }
    NSDate *nowDate = [NSDate date];// 获取本地时间
    NSTimeInterval time=[nowDate timeIntervalSince1970]-[date timeIntervalSince1970];
    NSString *result=nil;
    if (time<3600) { //1小时
        if (time<60) {
            result=@"1分钟前";
        }else {
            result=[NSString stringWithFormat:@"%.0f分钟前",(time/60)];
        }
    }else if (time<3600*8) {
        result=[NSString stringWithFormat:@"%.0f小时前",(time/3600)];
    }else if(time<3600*48) {
        [formatter setDateFormat:@" HH:mm"];
        result=[NSString stringWithFormat:@"昨天%@",[formatter stringFromDate:date]];
    }else if(time<3600*72) {
        [formatter setDateFormat:@" HH:mm"];
        result=[NSString stringWithFormat:@"前天%@",[formatter stringFromDate:date]];
    }else if(time<3600*168) {
        [formatter setDateFormat:@" HH:mm"];
        result=[NSString stringWithFormat:@"%0.f天前%@",(time/3600/24),[formatter stringFromDate:date]];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        result=[formatter stringFromDate:date];
    }

    ALDRelease(formatter);
    return result;
}

/**
 *  判断当前时间是否在给定时间范围内
 *  @param startTime 开始时间
 *  @param endTime 结束时间
 **/
+(BOOL) isOngoing:(NSString*)startTime endTime:(NSString*)endTime{
    if (!startTime || ![startTime isKindOfClass:[NSString class]]) {
        return NO;
    }
    if (!endTime || ![endTime isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSString *defaultFormat=nil;
    if(startTime.length==@"yyyy-MM-dd HH:mm:ss".length ||endTime.length==@"yyyy-MM-dd HH:mm:ss".length ){
        defaultFormat=@"yyyy-MM-dd HH:mm:ss";
    }else{
        defaultFormat=@"yyyy-MM-dd HH:mm";
    }
    NSRange range=[startTime rangeOfString:@"."];
    if (range.location!=NSNotFound) {
        startTime=[startTime substringToIndex:range.location];
    }
    range=[endTime rangeOfString:@"."];
    if (range.location!=NSNotFound) {
        endTime=[endTime substringToIndex:range.location];
    }
    if (!startTime && !endTime) {
        return NO;
    }
    
    NSDate *bDate=[ALDUtils getDateWithString:startTime format:defaultFormat];
    NSDate *eDate=[ALDUtils getDateWithString:endTime format:defaultFormat];
    NSDate *nowDate=[NSDate date];
    if (!bDate || !eDate) {
        return NO;
    }else{
        NSTimeInterval time= [nowDate timeIntervalSince1970];
        if (time>=[bDate timeIntervalSince1970] && time<=[eDate timeIntervalSince1970]) {
            return YES;
        }
    }
    return NO;
}

/**
 * 统计文本字数
 * @param text 要统计的文本
 **/
+(int) captureTextCount:(NSString *)text{
    NSInteger len=text.length;
    int count=0;
    for (int i=0; i<len; i++) {
        int c=[text characterAtIndex:i];
        if (c>255) {
            count+=2;
        }else {
            count+=1;
        }
    }
    if ((count%2)==0) {
        count=count/2;
    }else {
        count=count/2+1;
    }
    return count;
}

/**
 *  将Url参数转换成字典
 *  @param query url参数
 *  @result 返回处理后的结果
 **/
+(NSMutableDictionary *) getUrlParams:(NSString *)query{
    if(!query || [query isEqualToString:@""]){
        return nil;
    }
    //query=[query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *result=[[NSMutableDictionary alloc] init];
    NSArray *params=[query componentsSeparatedByString:@"&"];
    for(NSString *str in params){
        NSArray *tmp=[str componentsSeparatedByString:@"="];
        if (tmp.count<2) {
            continue;
        }
        NSString *key=[[tmp objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        key=[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *value=[[tmp objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        value=[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [result setValue:value forKey:key];
    }
    return ALDReturnAutoreleased(result);
}

/**
 * 根据类型和源id查询本地通知是否已存在
 * @param type 消息类型，1：议程 3：活动
 * @param sid 源id
 * @return 如果存在则返回该UILocalNotification对象
 **/
+(UILocalNotification *) findLocalNotify:(int) type withSid:(NSString*)sid{
    if (type<1 || !sid) {
        return nil;
    }
    if (![sid isKindOfClass:[NSString class]]) {
        sid=[NSString stringWithFormat:@"%@",sid];
    }
    NSArray *array=[[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in array) {
        NSDictionary *userInfo=notification.userInfo;
        if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
            id temp=[userInfo objectForKey:@"type"];
            int ntype=-1;
            if (temp) {
                ntype=[temp intValue];
            }
            NSString *nid=nil;
            temp=[userInfo objectForKey:@"sid"];
            if (temp) {
                nid=[NSString stringWithFormat:@"%@",temp];
            }
            if (type==ntype && nid && [sid isEqualToString:nid]) {
                return notification;
            }
            
        }
    }
    return nil;
}

/**
 * 添加到本地通知，本地通知数量上有限制，最大支持64个，超过将忽略
 * @param title 消息标题
 * @param body 提示消息体
 * @param userInfo 消息体携带的userInfo字典信息，字典信息需包含type(消息类型,1：议程 3：活动)和sid(源id)字段
 * @param fireDate 消息提醒时间
 **/
+(void) addLocalNotify:(NSString *)title body:(NSString *)body userInfo:(NSDictionary*)userInfo fireDate:(NSDate*)fireDate{
    if (!fireDate) {
        return;
    }
    if (userInfo && [userInfo isKindOfClass:[NSDictionary class]]) {
        id temp=[userInfo objectForKey:@"type"];
        int ntype=-1;
        if (temp) {
            ntype=[temp intValue];
        }
        NSString *sid=[userInfo objectForKey:@"sid"];
        [ALDUtils cancelLocalNotify:ntype withSid:sid];
    }
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    notification.timeZone=[NSTimeZone defaultTimeZone];
//    notification.repeatInterval=NSDayCalendarUnit; //循环时间单元
//    notification.repeatInterval=0;//循环次数，kCFCalendarUnitWeekday一周一次
    notification.applicationIconBadgeNumber += 1;
    notification.alertAction =title;
    notification.fireDate=fireDate;
    notification.alertBody=body;
    BOOL isSoundOn=YES;
    id temp=[[NSUserDefaults standardUserDefaults] objectForKey:kNeedRingKey];
    if (temp) {
        isSoundOn=[temp intValue];
    }
    if (isSoundOn) {
        [notification setSoundName:UILocalNotificationDefaultSoundName];
    }
    
    [notification setUserInfo:userInfo];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    ALDRelease(notification);
}

/**
 * 根据类型和源id查询本地通知是否已存在
 * @param type 消息类型，1：议程 3：活动
 * @param sid 源id
 **/
+(void) cancelLocalNotify:(int)type withSid:(NSString*)sid{
    UILocalNotification *nofication=[ALDUtils findLocalNotify:type withSid:sid];
    if (nofication!=nil) {
        [[UIApplication sharedApplication] cancelLocalNotification:nofication];
    }
}

/**
 * 验证邮箱合法性
 * @param email 待验证的邮箱
 * @return 返回验证后的结果
 **/
+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:email];
}

+(BOOL) isValidatePhoneNumber:(NSString*) phoneNumer{
//    NSString *phoneRegex=@"^(13[0-9]|15[0-9]|18[0-9])\\d{8}$";
//    NSString *phoneRegex=@"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
    NSString *phoneRegex=@"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumer];
}

/**
 * 验证手机号合法性
 * @param phoneNumer 待验证的手机号
 * @return 返回验证后的结果
 **/
+(BOOL) isValidateMobile:(NSString*) phoneNumer{
    NSString *phoneRegex=@"^(1[3-9][0-9])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumer];
}

+(BOOL) isImage:(NSString *) url{
    NSString *imageRegex=@"([^\\s]+(\\.(?i)(jpg|jpeg|png|gif|bmp|tiff|svg|psd))$)";
    NSPredicate *imageTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", imageRegex];
    return [imageTest evaluateWithObject:url];
}

/**
 * 创建压缩图片
 * @param image 源图片
 * @param thumbSize 要压缩的理想尺寸，该函数会根据图片大小和设定尺寸智能调整压缩尺寸
 * @param fileSize 文件压缩后的大小，若图片压缩后大于该值，则使用percent进行再次压缩，单位kb
 * @param percent 图片压缩质量比例
 **/
+ (UIImage*)createScaleImage:(UIImage *)image size:(CGSize )thumbSize maxFileSize:(CGFloat)fileSize percent:(float)percent{
    if (!image) {
        return nil;
    }
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width<thumbSize.width && height<thumbSize.height) {
        return image;
    }
    CGFloat scaleFactor = 0.0;
    
    CGFloat widthFactor = thumbSize.width / width;
    CGFloat heightFactor = thumbSize.height / height;
    
    if (widthFactor < heightFactor)  {
        scaleFactor = widthFactor;
    }else {
        scaleFactor = heightFactor;
    }
    CGFloat scaledWidth  = width * scaleFactor;
    CGFloat scaledHeight = height * scaleFactor;
    
    CGRect thumbRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
    CGSize newSize=CGSizeMake(scaledWidth, scaledHeight);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:thumbRect];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!thumbImage) {
        thumbImage=image;
    }
    thumbImage.imageType=image.imageType;
    
    NSData *data= nil;
    if (thumbImage.imageType && [thumbImage.imageType isEqualToString:@"png"]) {
        data=UIImagePNGRepresentation(thumbImage);
    }else{
        thumbImage.imageType=@"jpg";
        data=UIImageJPEGRepresentation(thumbImage, 1);
    }
    if (data.length>fileSize*1024) { //大于fileSizekb
        percent=fileSize*1024/data.length;
        NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, percent);
        UIImage *newImage=[UIImage imageWithData:thumbImageData];
        if (!newImage) {
            return thumbImage;
        }
        newImage.imageType=@"jpg";
        return newImage;
    }else{
        return thumbImage;
    }
}

/**
 * 图片压缩并保存到本地
 **/
+(NSString *)saveImage:(UIImage *)image quality:(CGFloat) quality
{
    NSData *data = UIImageJPEGRepresentation(image, quality);
    
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Documents/image"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:DocumentsPath]){
        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    NSString *uuid=[[NSUUID UUID] UUIDString];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingFormat:@"/%@.jpg",uuid] contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg",DocumentsPath, uuid];
    return filePath;
}

/**
 * 获取国际化的字符串，并格式化
 * @param defValue 默认值
 * @param key...参数
 * @return 返回格式化后的字符串
 **/
+(NSString*) formatLocalizedString:(NSString *)defValue key:(NSString *)key, ...
{
	// Localize the format
	NSString *localizedStringFormat = ALDLocalizedString(key,defValue);
	
	va_list args;
    va_start(args, key);
    NSString *string = [[NSString alloc] initWithFormat:localizedStringFormat arguments:args];
    va_end(args);
	return ALDReturnAutoreleased(string);
}

//地球半径
#define EARTH_RADIUS 6378137 
#define PI 3.141592653589793
#define rad(d) d * PI / 180.0

/**
 * 根据两点间经纬度坐标（double值），计算两点间距离，单位为米
 * @param lng1 经度1
 * @param lat1 纬度1
 * @param lng2 经度2
 * @param lat2 纬度2
 * @return 返回计算后的距离
 */
+(double) getDistanceWithLng1:(double) lng1 lat1:(double) lat1 lng2:(double) lng2 lat2:(double) lat2{
    double radLat1 = rad(lat1);
    double radLat2 = rad(lat2);
    double a = radLat1 - radLat2;
    double b = rad(lng1) - rad(lng2);
    double s = 2 * asin(sqrt(pow(sin(a/2),2)+cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    s = round(s * 1000000) / 1000000;
    return s;
}

/**
 * 截取字符串
 * @param text 待截取的字符串
 * @param encoding 字符串编码
 * @param length 需截取的长度，此为字节长度
 * @return 返回截取后的字符串
 **/
+(NSString*) cutStringWithText:(NSString*)text textEncoding:(NSStringEncoding) encoding length:(int) length{
    if (!text || ![text isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSData *textData=[text dataUsingEncoding:encoding allowLossyConversion:NO];
    if (length>textData.length) {
        return text;
    }
    NSRange range;
    range.location=0;
    range.length=length;
    NSData *temp=[textData subdataWithRange:range];
    NSString *tempString=ALDReturnAutoreleased([[NSString alloc] initWithData:temp encoding:encoding]);
    while(tempString==nil) {
        range.length-=1;
        if (range.length<1) {
            break;
        }
        temp=[textData subdataWithRange:range];
        tempString=ALDReturnAutoreleased([[NSString alloc] initWithData:temp encoding:encoding]);
//        if (tempString) {
//            int textLength=tempString.length;
//            if ([tempString characterAtIndex:(textLength-1)]!=[text characterAtIndex:(textLength-1)]) {
//                range.length-=1;
//                temp=[textData subdataWithRange:range];
//                tempString=[[[NSString alloc] initWithData:temp encoding:encoding] autorelease];
//            }
//        }
    }
    return tempString;
}

/**
 * 创建并显示UIActionSheet
 * @param title 标题
 * @param delegate UIActionSheet的委托实例
 * @param controller UIActionSheet要显示到的视图控制器上
 * @param buttons  UIActionSheet上的按钮，取[Object description]为显示标题
 * @param tag tag属性值
 **/
+(void) showActionSheetWithTitle:(NSString*) title
                        delegate:(id<UIActionSheetDelegate>)delegate
                      controller:(UIViewController*) controller
                         buttons:(NSArray*) buttons
                             tag:(int) tag{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:delegate
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = tag;
    for (id temp in buttons) {
        [actionSheet addButtonWithTitle:[temp description]];
    }
    
    // 同时添加一个取消按钮
    [actionSheet addButtonWithTitle:ALDLocalizedString(@"Cancel",  @"取消")];
    // 将取消按钮的index设置成我们刚添加的那个按钮，这样在delegate中就可以知道是那个按钮
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    
    if (controller.tabBarController) {
        [actionSheet showInView:controller.tabBarController.view]; //必须如此，否则取消按钮不能按
    }else{
        [actionSheet showInView:controller.view];
    }
    ALDRelease(actionSheet);
}

@end