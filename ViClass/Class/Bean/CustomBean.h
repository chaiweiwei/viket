#import <Foundation/Foundation.h>

//用户模型
@interface CustomBean : NSObject

@property (nonatomic,copy) NSString * sid; //用户编号
@property (nonatomic,copy) NSString *name; //用户名
@property (nonatomic,copy) NSString *avatar; //头像
@property (nonatomic,assign) int integral; //积分

@end

