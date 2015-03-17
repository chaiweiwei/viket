//
//  HttpClient.h
//  npf
//
//  Created by yulong chen on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicsHttpClient.h"
#import "StringUtil.h"

typedef NS_ENUM(NSInteger, MyHttpRequestPath){
    /** 积分排名 **/
    HttpRequestPathForRecordsRanking = 200,
    /** 类型 **/
    HttpRequestPathForCategoryList = 201,
    /** 课程列表 **/
    HttpRequestPathForSubjectList = 202,
    /** 课程详情 **/
    HttpRequestPathForClassDetail = 203,
    /** 课程章节列表 **/
    HttpRequestPathForChapterList = 204,
    /** 课程章节详情 **/
    HttpRequestPathForChapterDetail = 205,
    /** 课程章节练习 **/
    HttpRequestPathForQuestionList = 206,
    /** 练习答案提交 **/
    HttpRequestPathForSubmitAsk = 207,
    /** 提交评分 **/
    HttpRequestPathForSendScore = 208,
    /** 获取用户消息列表 **/
    HttpRequestPathForUserNews = 209,
    /** 获取用户消息列表当前未读 **/
    HttpRequestPathForUserNewsUnread = 210,
    /** 删除用户消息 */
    HttpRequestPathForDeleteNews= 211,
    /** 最后的登陆时间 */
    HttpRequestPathForLastTime= 212,
    /** 课程报名接口 */
    HttpRequestPathForCourseApply= 213,
    /** 课程取消报名接口 */
    HttpRequestPathForCourseCancel= 214,
    /** 用户消息列表已读 **/
    HttpRequestPathForUserNewsRead = 215,
    /** 获取报名课程列表 **/
    HttpRequestPathForMyCourse = 216,
    
};

//本类中实现了app所有数据请求协议，全为异步请求，采用接口回调方式通知请求发起对象，需要实现DataLoadStateDelegate协议
@interface HttpClient : BasicsHttpClient{
    
}
/**
 *  积分排行榜列表
 *
 *  @param page      分页页码，从1开始
 *  @param pageCount 每页最大返回数，默认20
 */
-(void)getRecordsRankingList:(int)page pageCount:(int)pageCount;
/**
 *  课程类型列表
 */
-(void)getClassCategory;
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
-(void)getrSubjectList:(int)page pageCount:(int)pageCount keyword:(NSString *)keyword categoryId:(NSString *)categoryId hot:(int)hot top:(int)top new:(int)newid;
/**
 *  课程详情
 *
 *  @param sid 课程ID
 */
-(void)getClassDetail:(NSString *)sid;
/**
 *  课程章节列表
 *
 *  @param page      分页页码，从1开始
 *  @param pageCount 每页最大返回数，默认20
 *  @param subjectId 课程ID
 */
-(void)getChapterList:(int)page pageCount:(int)pageCount subjectId:(NSString *)subjectId;
/**
 *  课程章节详情
 *
 *  @param sid 课程ID
 */
-(void)getChapterDetail:(NSString *)sid;
/**
 *  课程章节练习
 *
 *  @param sid 课程ID
 */
-(void)getQuestionList:(NSString *)chapterId;
/**
 *  练习答案提交
 *
 *  @param chapterId 课程章节ID
 *  @param answers   答案列表
 */
-(void)sendAnswer:(NSString *)chapterId answers:(NSArray *)answers;
/**
 *  提交评分信息
 *
 *  @param sourceId 课程章节ID
 *  @param type     5：课程
 *  @param score    评分数
 */
-(void)sendScore:(NSString *)sourceId type:(int)type score:(int)score;
/**
 *  获取用户当前系统放送的消息
 *
 *  @param page      分页页码，从1开始
 *  @param pageCount 每页最大返回数，默认20
 */
-(void)getUserNews:(int)page pageCount:(int)pageCount;
/**
 *  用户未读消息数据
 */
-(void)getUnReadUserNewsCount;
/**
 * 标记已经读
 * ids消息数据id数组
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result=nil
 **/
-(void) setUserNewsRead:(NSArray *)ids;

/**
 * 删除用户消息数据
 * ids消息数据id数组
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态,result=nil
 **/
-(void) deleteNews:(NSArray *)ids;
/**
 * 修改用户信息 如果只修改头像，则只传头像到后台
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void) modifyUserInfo:(UserInfoBean*) userInfo username:(NSString*) username mobile:(NSString*) mobile extra:(NSDictionary*) extra;
/**
 *  根据最新的上线时间
 */
-(void)updateLastTime;
/**
 * 课程报名
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void)courseApply:(NSString *)courseId;
/**
 * 课程取消报名
 * @param user 用户数据对象
 * @return 结果以接口回调dataLoadDone:code withObj:obj通知请求发起者，code为状态
 **/
-(void)courseCancel:(NSString *)courseId;
/**
 *  获取收藏的课表
 *
 *  @param page
 *  @param pageCount
 */
-(void)getMyCourse:(int)page pageCount:(int)pageCount;
@end