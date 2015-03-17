//
//  NSFileManager+Additions.h
//  ZhiDuoPing
//
//  Created by alidao on 14-6-27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Additions)
/**
 *	@brief	获得指定目录下，指定后缀名的文件列表
 *
 *	@param 	type 	文件后缀名
 *	@param 	dirPath 	指定目录
 *
 *	@return	文件名列表
 */
+(NSArray *) getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;

@end
