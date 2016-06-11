//
//  FSUtils.h
//  GolfSwingAnalysis
//
//  Created by Top1 on 8/28/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSManager : NSObject
+ (BOOL)isExistAtPath:(NSString *)filePath bPathIsDir:(BOOL)bPathIsDir;
+ (BOOL)createAtPath:(NSString *)filePath;
+ (BOOL)deleteAtPath:(NSString *)filePath;
+ (BOOL)copyAtPath:(NSString *)srcFilePath toPath:(NSString *)dstFilePath;
+ (BOOL)copyAtURL:(NSURL *)srcFileURL toPath:(NSString *)dstFilePath;

+ (NSString *)tempVideoPath;
+ (NSString *)videoFilePath:(NSString *)videoName;
+ (NSString *)thumbFilePath:(NSString *)videoName;
+ (NSString *)videoPlistPath;

+ (BOOL)copyVideoAtPath:(NSString *)srcPath name:(NSString *)dstName;
+ (BOOL)makeThumb:(NSString *)videoName;
+ (BOOL)deleteVideo:(NSString *)videoName;

@end
