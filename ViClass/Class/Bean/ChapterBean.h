#import <Foundation/Foundation.h>
#import "AttachmentBean.h"
#import "JSONUtils.h"

//课程模型
@interface ChapterBean : NSObject

@property (nonatomic,copy) NSString *sid; //课程编号
@property (nonatomic,copy) NSString *courseId; //所属课程ID
@property (nonatomic,copy) NSString *name; //章节名称
@property (nonatomic,copy) NSString *logo; //章节图标
@property (nonatomic,copy) NSString *tags;//章节关键词，多个以逗号分隔
@property (nonatomic,assign) int questionCount; //练习题数
@property (nonatomic,copy) NSString *note;//章节介绍
@property (nonatomic,assign) int commentCount; //评论数
@property (nonatomic,assign) int praiseCount; //点赞数
@property (nonatomic,assign) int forwardCount; //分享数
@property (nonatomic,assign) int favoriteCount; //收藏数
@property (nonatomic,assign) int reportCount; //反馈数
@property (nonatomic,assign) BOOL praiseFlag; //是否已点赞
@property (nonatomic,assign) BOOL favoriteFlag; //是否已收藏
@property (nonatomic,assign) int myScore; //我的评分 为空时表示还未评分
@property (nonatomic,copy) NSString *shareUrl;//分享的URL
@property (nonatomic,copy) NSString *createTime;
/** 附件列表，(AttachmentsBean) **/
@property (retain,nonatomic) NSArray *attachments;

@property (nonatomic,assign) int count;
@end
