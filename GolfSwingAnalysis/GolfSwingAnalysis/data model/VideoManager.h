//
//  VideoManager.h
//  GolfSwingAnalysis
//
//  Created by Top1 on 8/28/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _VIDEO_STATE {
    VIDEO_STATE_NORMAL = 0,
    VIDEO_STATE_MIX,
} VIDEO_STATE;

#define kVideoNameKey           @"VideoName"
#define kVideoCommentKey        @"VideoComment"
#define kVideoStateKey          @"VideoState"

@interface VideoManager : NSObject
{
    NSMutableArray *           _videoList;
}

@property (strong, nonatomic) RSTCoreDataModel *model;
@property (strong, nonatomic) RSTCoreDataStack *stack;

+ (id)sharedManager;

+ (NSString *)nextVideoName;
+ (NSString *)creationDate:(NSString *)formattedVideoName;

- (int)videoCount;
- (void)addVideo:(NSString *)videoName;
- (void)addMixVideo:(NSString *)videoName;

//- (NSMutableDictionary *)videoAtIndex:(int)index;
//- (void)deleteVideoAtIndex:(int)index;
//- (void)updateVideoComment:(NSString *)comment index:(int)index;
//- (void)updateVideoState:(VIDEO_STATE)videoState index:(int)index;

- (void)deleteVideo:(VideoEntity *)entity;
- (void)updateComment:(VideoEntity *)entity comment:(NSString *)comment;
- (void)updateState:(VideoEntity *)entity state:(VIDEO_STATE)videoState;
- (void)updateVideo:(VideoEntity *)entity;

//- (BOOL)storeVideoList;
- (NSArray *)restoreVideoList;

@end
