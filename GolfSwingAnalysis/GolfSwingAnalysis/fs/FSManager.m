//
//  FSUtils.m
//  GolfSwingAnalysis
//
//  Created by Top1 on 8/28/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "FSManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation FSManager

#pragma mark - File Operation
+ (BOOL)isExistAtPath:(NSString *)filePath bPathIsDir:(BOOL)bPathIsDir
{
    BOOL bExist, bIsDir;
    bExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&bIsDir];
    
    return bExist && (bIsDir == bPathIsDir);
}

+ (BOOL)createAtPath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:filePath
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:nil];
}

+ (BOOL)deleteAtPath:(NSString *)filePath
{
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+ (BOOL)copyAtPath:(NSString *)srcFilePath toPath:(NSString *)dstFilePath
{
    if ([FSManager isExistAtPath:dstFilePath bPathIsDir:NO])
        [FSManager deleteAtPath:dstFilePath];
    
    return [[NSFileManager defaultManager] copyItemAtPath:srcFilePath
                                                   toPath:dstFilePath
                                                    error:nil];
}

+ (BOOL)copyAtURL:(NSURL *)srcFileURL toPath:(NSString *)dstFilePath
{
    if ([FSManager isExistAtPath:dstFilePath bPathIsDir:NO])
        [FSManager deleteAtPath:dstFilePath];
    
    return [[NSFileManager defaultManager] copyItemAtURL:srcFileURL
                                                   toURL:[NSURL fileURLWithPath:dstFilePath]
                                                   error:nil];
}

#pragma mark - App FIle
+ (NSString *)tempVideoPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *_tempVideoPath =  [NSString stringWithFormat:@"%@/temp.mov", documentsDirectory];
    
    return _tempVideoPath;
}

+ (NSString *)videoDirPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *_videoDirPath =  [NSString stringWithFormat:@"%@/me", documentsDirectory];
    
    if (![FSManager isExistAtPath:_videoDirPath bPathIsDir:YES])
    {
        [FSManager createAtPath:_videoDirPath];
    }
    
    return _videoDirPath;
}

+ (NSString *)videoFilePath:(NSString *)videoName
{
    return [NSString stringWithFormat:@"%@/%@.mov", [FSManager videoDirPath], videoName];
}


+ (NSString *)thumbFilePath:(NSString *)videoName
{
    return [NSString stringWithFormat:@"%@/%@.png", [FSManager videoDirPath], videoName];
}

+ (NSString *)videoPlistPath
{
    return [NSString stringWithFormat:@"%@/videoList.plist", [FSManager videoDirPath]];
}

+ (BOOL)copyVideoAtPath:(NSString *)srcPath name:(NSString *)dstName
{
    NSString *dstPath = [FSManager videoFilePath:dstName];
    return [FSManager copyAtPath:srcPath toPath:dstPath];
}

+ (BOOL)makeThumb:(NSString *)videoName
{
    NSURL *videoURL = [NSURL fileURLWithPath:[FSManager videoFilePath:videoName]];
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    generator.maximumSize = CGSizeMake(280, 210);
    CGImageRef thumbImageRef = [generator copyCGImageAtTime:CMTimeMake(1 * 60, 60) actualTime:nil error:nil];
    UIImage *thumbImage = [UIImage imageWithCGImage:thumbImageRef];
    CGImageRelease(thumbImageRef);
    
    NSData *pngData = UIImagePNGRepresentation(thumbImage);
    NSString *thumbPath = [FSManager thumbFilePath:videoName];
    
    if ([FSManager isExistAtPath:thumbPath bPathIsDir:NO])
        [FSManager deleteAtPath:thumbPath];
    
    return [pngData writeToFile:thumbPath atomically:YES];
}

+ (BOOL)deleteVideo:(NSString *)videoName
{
    NSString *videoPath = [FSManager videoFilePath:videoName];
    if ([FSManager isExistAtPath:videoName bPathIsDir:NO])
        [FSManager deleteAtPath:videoPath];
    
    NSString *thumbPath = [FSManager thumbFilePath:videoName];
    if ([FSManager isExistAtPath:thumbPath bPathIsDir:NO])
        [FSManager deleteAtPath:thumbPath];
    
    return YES;
}
@end
