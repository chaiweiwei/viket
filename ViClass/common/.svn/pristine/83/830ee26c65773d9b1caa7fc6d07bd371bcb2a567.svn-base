//
//  NSFileManager+Additions.m
//  ZhiDuoPing
//
//  Created by alidao on 14-6-27.
//  Copyright (c) 2014年 chen yulong. All rights reserved.
//

#import "NSFileManager+Additions.h"

@implementation NSFileManager (Additions)

+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([NSFileManager isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    
    return filenamelist;
}

+(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}
@end
