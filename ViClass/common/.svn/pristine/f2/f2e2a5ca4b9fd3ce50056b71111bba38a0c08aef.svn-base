//
//  StringUtil.m
//  TwitterFon
//
//  Created by kaz on 7/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "StringUtil.h"
#import "SBJson.h"
#import "ALDUtils.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 

@implementation NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent
{
	const char* p = [self UTF8String];
	NSMutableString* result = [NSMutableString string];
	
	for (;*p ;p++) {
		unsigned char c = *p;
		if (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '-' || c == '_') {
			[result appendFormat:@"%c", c];
		} else {
			[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

+ (NSString*)base64encode:(NSString*)str 
{
    if ([str length] == 0)
        return @"";

    const char *source = [str UTF8String];
    NSInteger strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;

    NSUInteger length = 0;
    NSUInteger i = 0;

    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    NSString *result=[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    return ALDReturnAutoreleased(result);
}

/******************************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : 解码base64格式字符串数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64Decode:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return nil;
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    NSString *result = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
    free(bytes);
    return ALDReturnAutoreleased(result);
}

- (NSString*)escapeHTML
{
	NSMutableString* s = [NSMutableString string];
	
	NSInteger start = 0;
	NSInteger len = [self length];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = r.location + 1;
	}
	
	return s;
}

- (NSString*)unescapeHTML
{
	NSMutableString* s = [NSMutableString string];
	NSMutableString* target = ALDReturnAutoreleased([self mutableCopy]);
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

-(id) strToJSON{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id repr = [parser objectWithString:self];
    if (!repr)
        NSLog(@"-JSONValue failed. Error is: %@", parser.error);
    ALDRelease(parser);
    return repr;
}

+ (NSString*)localizedString:(NSString*)key
{
	return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
}

+ (time_t) convertTimeStamp:(NSString *)stringTime{
    time_t createdAt=0;
    struct tm created;
    time_t now;
    time(&now);
    
    if (stringTime) {
		if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
			strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
		}
		createdAt = mktime(&created);
	}
	return createdAt;
}

+(BOOL) isEmpty:(NSString*) str{
    if (str==nil || [str isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

//特殊字符串替换
+(NSString *) replaceString:(NSString *)str{
	NSString *returnStr = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"<P>" withString:@""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"</P>" withString:@""];
    returnStr = [returnStr stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
	returnStr = [returnStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
	return returnStr;
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
    SBJsonWriter *json = ALDReturnAutoreleased([[SBJsonWriter alloc] init]);
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *mt_array = [NSMutableArray array];
        NSArray *t_array = (NSArray *)obj;
        for (id t_obj in t_array) {
            if ([t_obj isKindOfClass:[NSString class]]) {
                [mt_array addObject:(NSString *)t_obj];
            } else {
                NSString *jsonStr = [NSString getJSONStringFromObj:t_obj];
                [mt_array addObject:jsonStr];
            }
        }
        return [json stringWithObject:mt_array];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *t_dict = (NSDictionary *)obj;
        NSMutableDictionary *mt_dict = [NSMutableDictionary dictionary];
        NSArray *keys = [t_dict allKeys];
        for (NSString *key in keys) {
            id t_obj = [t_dict objectForKey:key];
            if ([t_obj isKindOfClass:[NSString class]]) {
                [mt_dict setObject:t_obj forKey:key];
            } else {
                NSString *jsonStr = [NSString getJSONStringFromObj:t_obj];
                [mt_dict setObject:jsonStr forKey:key];
            }
        }
        return [json stringWithObject:mt_dict];
    } else if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else {
        return [[obj class] description];
    }
}

/**
 * 将字典和数组混合的多层多层次数据转化为JSON数据
 * @param obj为字典或数组
 * @param error 返回的错误
 * @return 返回json格式字符串
 */
+(NSString *) getJSONStringFromObj:(id)obj withError:(NSError **)error{
    SBJsonWriter *json = ALDReturnAutoreleased([[SBJsonWriter alloc] init]);
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *mt_array = [NSMutableArray array];
        NSArray *t_array = (NSArray *)obj;
        for (id t_obj in t_array) {
            if ([t_obj isKindOfClass:[NSString class]]) {
                [mt_array addObject:(NSString *)t_obj];
            } else {
                NSString *jsonStr = [NSString getJSONStringFromObj:t_obj];
                [mt_array addObject:jsonStr];
            }
        }
        return [json stringWithObject:mt_array];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *t_dict = (NSDictionary *)obj;
        NSMutableDictionary *mt_dict = [NSMutableDictionary dictionary];
        NSArray *keys = [t_dict allKeys];
        for (NSString *key in keys) {
            id t_obj = [t_dict objectForKey:key];
            if ([t_obj isKindOfClass:[NSString class]]) {
                [mt_dict setObject:t_obj forKey:key];
            } else {
                NSString *jsonStr = [NSString getJSONStringFromObj:t_obj];
                [mt_dict setObject:jsonStr forKey:key];
            }
        }
        return [json stringWithObject:mt_dict];
    } else if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    } else {
        return [[obj class] description];
    }
}

@end



