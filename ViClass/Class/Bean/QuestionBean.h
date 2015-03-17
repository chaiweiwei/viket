#import <Foundation/Foundation.h>
#import "OptionBean.h"
#import "JSONUtils.h"

//题目模型
@interface QuestionBean : NSObject

@property(nonatomic,copy) NSString *sid;//问题ID
@property(nonatomic,copy) NSString *code; //问题编号
@property(nonatomic,copy) NSString *name; //问题名称
@property(nonatomic,assign) int score; //问题分数
@property (nonatomic,retain) NSArray *options;//选项列表

@property (nonatomic, assign, getter = isOpened) BOOL opened;
@property(nonatomic,copy) NSString *selectedAsk;//选中答案

@end
