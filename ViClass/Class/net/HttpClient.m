//
//  HttpClient.m
//  npf
//
//  Created by yulong chen on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HttpClient.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSDictionaryAdditions.h"
#import "StringUtil.h"
#import "SBJson.h"
#import "NetworkTest.h"
#import "GTMBase64.h"
#import "JSONUtils.h"
#import "AppDelegate.h"

@interface HttpClient (private)<UIAlertViewDelegate>

@end

@implementation HttpClient
@synthesize delegate=_delegate;
@synthesize needTipsNetError=_needTipsNetError;


-(void) setObject:(id)anObject forKey:(id <NSCopying>)aKey forDic:(NSMutableDictionary*) dic withDefault:(id) defValue{
    if (!defValue) {
        defValue=@"";
    }
    if (anObject==nil) {
        anObject=defValue;
    }

    [dic setObject:anObject forKey:aKey];
}
/**
 *  积分排行榜列表
 *
 *  @param page      分页页码，从1开始
 *  @param pageCount 每页最大返回数，默认20
 */
-(void)getRecordsRankingList:(int)page pageCount:(int)pageCount
{

    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    [self requestWithParams:params actionName:@"app/user/tops" requestPath:HttpRequestPathForRecordsRanking needCache:YES];
}
/**
 *  课程类型列表
 */
-(void)getClassCategory
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [self requestWithParams:params actionName:@"app/category/list" requestPath:HttpRequestPathForCategoryList needCache:YES];
}
/**
 *  课程列表
 *
 *  @param page       分页页码，从1开始
 *  @param pageCount  每页最大返回数，默认20
 *  @param keyword    搜索关键字(支持拼音查询)
 *  @param categoryId 课程类型
 *  @param hot        hot为1时表示热门
 *  @param top        top为1时表示推荐
 *  @param newid      new为1时表示最新
 三者只能同时有一个为1，都不为1时默认以添加时间倒序排序
 */
-(void)getrSubjectList:(int)page pageCount:(int)pageCount keyword:(NSString *)keyword categoryId:(NSString *)categoryId hot:(int)hot top:(int)top new:(int)newid
{
    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    if(keyword == nil)
        keyword = @"";
    [params setObject:keyword forKey:@"keyword"];
    if(categoryId == nil)
        categoryId = @"";
    [params setObject:categoryId forKey:@"categoryId"];
    [params setObject:[NSNumber numberWithInt:hot] forKey:@"hot"];
    [params setObject:[NSNumber numberWithInt:top] forKey:@"top"];
    [params setObject:[NSNumber numberWithInt:newid] forKey:@"new"];
    
    [self requestWithParams:params actionName:@"app/course/list" requestPath:HttpRequestPathForSubjectList needCache:YES];
}
/**
 *  课程详情
 *
 *  @param sid 课程ID
 */
-(void)getClassDetail:(NSString *)sid
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"id"];
    
    [self requestWithParams:params actionName:@"app/course/detail" requestPath:HttpRequestPathForClassDetail needCache:YES];
    
}
/**
 *  课程章节列表
 *
 *  @param page      分页页码，从1开始
 *  @param pageCount 每页最大返回数，默认20
 *  @param subjectId 课程ID
 */
-(void)getChapterList:(int)page pageCount:(int)pageCount subjectId:(NSString *)subjectId
{
    if(page<1) page=1;
    if(pageCount<1) pageCount=20;
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    [params setObject:subjectId forKey:@"courseId"];
    
    [self requestWithParams:params actionName:@"app/chapter/list" requestPath:HttpRequestPathForChapterList needCache:YES];
}
/**
 *  课程章节详情
 *
 *  @param sid 课程ID
 */
-(void)getChapterDetail:(NSString *)sid
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sid forKey:@"id"];
    
    [self requestWithParams:params actionName:@"app/chapter/detail" requestPath:HttpRequestPathForChapterDetail needCache:YES];
}
/**
 *  课程章节练习
 *
 *  @param sid 课程ID
 */
-(void)getQuestionList:(NSString *)chapterId
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:chapterId forKey:@"chapterId"];
    
    [self requestWithParams:params actionName:@"app/question/list" requestPath:HttpRequestPathForQuestionList needCache:YES];

}
/**
 *  练习答案提交
 *
 *  @param chapterId 课程章节ID
 *  @param answers   答案列表
 */
-(void)sendAnswer:(NSString *)chapterId answers:(NSArray *)answers
{
    HttpRequestPath requestPath=HttpRequestPathForSubmitAsk;
    if (answers==nil || answers.count<1 ) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:chapterId forKey:@"chapterId"];
    [params setObject:answers forKey:@"answers"];
    [self requestWithParams:params actionName:@"app/answer/send" requestPath:requestPath needCache:false];
    
//    NSMutableDictionary *params=[NSMutableDictionary dictionary];
//    [params setObject:chapterId forKey:@"chapterId"];
//    [params setObject:answers forKey:@"answers"];
//
//    [self requestWithParams:params actionName:@"app/answer/send" requestPath:HttpRequestPathForSubmitAsk needCache:YES];
}
/**
 *  提交评分信息
 *
 *  @param sourceId 课程章节ID
 *  @param type     5：课程
 *  @param score    评分数
 */
-(void)sendScore:(NSString *)sourceId type:(int)type score:(int)score
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:sourceId forKey:@"sourceId"];
    [params setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [params setObject:[NSNumber numberWithInt:score] forKey:@"score"];
    
    [self requestWithParams:params actionName:@"app/data/score" requestPath:HttpRequestPathForSendScore needCache:YES];
}
/**
 *  获取用户当前系统放送的消息
 *
 *  @param page      分页页码，从1开始
 *  @param pageCount 每页最大返回数，默认20
 */
-(void)getUserNews:(int)page pageCount:(int)pageCount
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    [self requestWithParams:params actionName:@"app/userNews/mine" requestPath:HttpRequestPathForUserNews needCache:YES];

}
/**
 *  用户未读消息数据
 */
-(void)getUnReadUserNewsCount
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [self requestWithParams:params actionName:@"app/userNews/unreadCount" requestPath:HttpRequestPathForUserNewsUnread needCache:NO];
}
/**
 * 删除用户消息数据
 * ids消息数据id数组
 *
 **/
-(void) deleteNews:(NSArray *)ids
{
    if(!ids || ids.count<1){
        if([_delegate respondsToSelector:@selector(dataLoadDone:requestPath:withCode:withObj:)]){
            [_delegate dataLoadDone:self requestPath:HttpRequestPathForDeleteNews withCode:kPARAM_ERROR withObj:nil];
            return;
        }
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:ids forKey:@"ids"];
    [self requestWithParams:params actionName:@"app/userNews/delete" requestPath:HttpRequestPathForDeleteNews needCache:NO];
}
/**
 * 标记已经读
 * ids消息数据id数组
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result=nil
 **/
-(void) setUserNewsRead:(NSArray *)ids
{
    if(!ids || ids.count<1){
        if([_delegate respondsToSelector:@selector(dataLoadDone:requestPath:withCode:withObj:)]){
            [_delegate dataLoadDone:self requestPath:HttpRequestPathForUserNewsRead withCode:kPARAM_ERROR withObj:nil];
            return;
        }
    }
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:ids forKey:@"ids"];
    [self requestWithParams:params actionName:@"app/userNews/read" requestPath:HttpRequestPathForUserNewsRead needCache:NO];
}
/**
 *
 *  课程类型列表
 */
-(void)updateLastTime
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [self requestWithParams:params actionName:@"app/user/access" requestPath:HttpRequestPathForLastTime needCache:YES];
}

//只返回code和errMsg
-(void)decodeJSONCode:(NSDictionary *)resultData returnResult:(ALDResult*) result
{
    if([resultData isKindOfClass:[NSDictionary class]]){
        int code=[[resultData objectForKey_NONULL:@"resultCode"] intValue];
        if(code!=KOK){
            result.errorMsg=[resultData objectForKey_NONULL:@"msg"];
        }
        result.code=code;
    }else{
        result.code=kPARAM_ERROR;
    }
}
/**
 * 修改用户信息 如果只修改头像，则只传头像到后台
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyUserInfo:(UserInfoBean*) userInfo username:(NSString*) username mobile:(NSString*) mobile extra:(NSDictionary*) extra {
    HttpRequestPath requestPath=HttpRequestPathForModifyUserInfo;
    if (userInfo==nil && [NSString isEmpty:username] && [NSString isEmpty:mobile] && extra==nil) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    if (![NSString isEmpty:username]) {
        [params setObject:username forKey:@"username"];
    }
    if (![NSString isEmpty:mobile]) {
        [params setObject:mobile forKey:@"mobile"];
    }
    if (userInfo!=nil) {
        NSDictionary *dicUserInfo=[userInfo toDictionary];
        [params setObject:dicUserInfo forKey:@"userInfo"];
    }
    if (extra!=nil) {
        [params setObject:extra forKey:@"extra"];
    }
    
    [self requestWithParams:params actionName:@"app/user/modifyUserInfo" requestPath:requestPath needCache:NO];
}
-(void) queryMyFavorites:(int) type page:(int) page paeCount:(int) pageCount
{
    [super queryMyFavorites:type page:page paeCount:pageCount];
}
/**
 * 课程 报名
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void)courseApply:(NSString *)courseId
{
    HttpRequestPath requestPath=HttpRequestPathForCourseApply;
    if (courseId==nil) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:courseId forKey:@"courseId"];
    [self requestWithParams:params actionName:@"app/course/apply" requestPath:requestPath needCache:false];
    
}
/**
 * 取消报名
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void)courseCancel:(NSString *)courseId
{
    HttpRequestPath requestPath=HttpRequestPathForCourseCancel;
    if (courseId==nil) {
        [self returnParamsError:requestPath];
        return;
    }
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:courseId forKey:@"courseId"];
    [self requestWithParams:params actionName:@"app/course/cancel" requestPath:requestPath needCache:false];
    
}
/**
 *  获取收藏的课表
 *
 *  @param page
 *  @param pageCount
 */
-(void)getMyCourse:(int)page pageCount:(int)pageCount
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:pageCount] forKey:@"pageCount"];
    
    [self requestWithParams:params actionName:@"app/course/mine" requestPath:HttpRequestPathForMyCourse needCache:YES];
    
}
-(void) onRequestStart:(ASIHTTPRequest *)request{
    [super onRequestStart:request];
}

-(ALDResult*) onRequestDone:(ASIHTTPRequest *)request isSuccessed:(BOOL)isSuccess{
    if (isSuccess) {
        NSDictionary *userInfo=request.userInfo;
        int requestPath=[[userInfo objectForKey_NONULL:kRequestPathKey] intValue];
        if (requestPath==HttpRequestPathForDownload || requestPath==HttpRequestPathForHtmlInfo) {
            return [super onRequestDone:request isSuccessed:isSuccess];
        }
        
        NSString *responseString = [request responseString];
        NSLog(@"response:%@",responseString);
        
        id jobj=[responseString strToJSON];
        ALDResult *result=[[ALDResult alloc] init];
        if (!jobj || ![jobj isKindOfClass:[NSDictionary class]]) {
            result.code=kDATA_ERROR;
            result.errorMsg=@"请求失败，返回数据有误！";
            return result;
        }
        int resultCode=[[jobj objectForKey_NONULL:@"resultCode"] intValue];
        result.code=resultCode;
        result.errorMsg=[jobj objectForKey_NONULL:@"message"];
        
        /* 401：用户未登录，需登录 508：登录已过期 509：已在别的地方登录*/
        if (resultCode==401) {
            result.isNeedLogin=YES;
            result.errorMsg=@"请求需要登录权限，请先登录!";
        }else if (resultCode==508) {
            result.isNeedLogin=YES;
            result.errorMsg=@"登录已过期，请重新登录!";
        }else if (resultCode==509) {
            result.isNeedLogin=YES;
            result.errorMsg=@"账户已在别的地方登录，请重新登录!";
        }else if (resultCode != KOK && requestPath!=HttpRequestPathForUploadFile) {
            return result;
        }
        id resultData=[jobj objectForKey_NONULL:@"result"];
        BOOL hasSwitched=NO;
        switch (requestPath)
        {
            case HttpRequestPathForRecordsRanking: {
                [self decodeJSONArray:jobj itemClass:@"CustomBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
                
            case HttpRequestPathForCategoryList:
            {
                [self decodeJSONArray:jobj itemClass:@"CategoryBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForSubjectList:
            {
                [self decodeJSONArray:jobj itemClass:@"ClassRoomBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForClassDetail:
            {
                [self decodeJSONObject:resultData toClass:@"ClassRoomBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForChapterList:
            {
                [self decodeJSONArray:jobj itemClass:@"ChapterBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForChapterDetail:
            {
                [self decodeJSONObject:resultData toClass:@"ChapterBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForQuestionList: {
                [self decodeJSONArray:jobj itemClass:@"QuestionBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForSubmitAsk: {
                [self decodeJSONObject:resultData toClass:@"ScoreBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForSendScore: {
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForUserNews:
            {
                [self decodeJSONArray:jobj itemClass:@"NewBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForMyFavorites:
            {
                [self decodeJSONArray:jobj itemClass:@"ChapterBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForUserNewsUnread:{
                if ([resultData isKindOfClass:[NSDictionary class]]) {
                    result.obj=(NSNumber *)[resultData objectForKey_NONULL:@"count"];
                }else {
                    result.code=kDATA_ERROR;
                }
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForMyCourse:
            {
                [self decodeJSONArray:jobj itemClass:@"ClassRoomBean" returnResult:result];
                hasSwitched=YES;
            }
                break;
            case HttpRequestPathForUserNewsRead:
            case HttpRequestPathForCourseCancel:
            case HttpRequestPathForCourseApply:
            case HttpRequestPathForLastTime:
            case HttpRequestPathForModifyUserInfo:
            case HttpRequestPathForDeleteNews:
                break;
                
            default:
                break;
        }
        if (hasSwitched) {
            return result;
        }
    }
    return [super onRequestDone:request isSuccessed:isSuccess];
}





@end