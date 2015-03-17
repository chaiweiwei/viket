#import <Foundation/Foundation.h>

//课堂模型
@interface ClassRoomBean : NSObject

@property (nonatomic,copy) NSString *sid; //课堂编号
@property (nonatomic,copy) NSString *name;//课堂名称
@property (nonatomic,copy) NSString *logo;//课程图片
@property (nonatomic,copy) NSString *note;//课程介绍
@property (nonatomic,copy) NSString *categoryName;//课程类型
@property (nonatomic,assign) int chapterCount;//章节(集)数
@property (nonatomic,assign) int status;//0.未完结，1.已完结
@property (nonatomic,assign) CGFloat completeness;
@property (nonatomic,copy) NSString *teacherName;//导师名称
@property (nonatomic,copy) NSString *teacherNote;//导师介绍
@property (nonatomic,copy) NSString *createTime;
@property (nonatomic,assign) BOOL applyFlag;//是否已报名

@property (nonatomic, assign, getter = isOpened) BOOL opened;

@property (nonatomic,retain) NSArray *chapters;
@property (nonatomic,assign) int count;//缓存的Count
@end
