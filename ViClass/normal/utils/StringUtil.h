//
//  StringUtil.h
//  TwitterFon
//
//  Created by kaz on 7/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;

-(id) strToJSON;

+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;
+ (NSString *)base64Decode:(NSString *)string;

+ (time_t) convertTimeStamp:(NSString*) stringTime;

+(BOOL) isEmpty:(NSString*) str;

//特殊字符串替换
+(NSString *) replaceString:(NSString *)str;

+(id) getJSONObjectFromString:(NSString *) str;

+(NSString *)getJSONStringFromObj:(id)obj;

+(NSString *)getJSONStringFromObj:(id)obj withError:(NSError **) error;

@end


