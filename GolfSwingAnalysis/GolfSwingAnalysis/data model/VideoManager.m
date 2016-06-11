//
//  VideoManager.m
//  GolfSwingAnalysis
//
//  Created by Top1 on 8/28/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "VideoManager.h"
#import "FSManager.h"

static VideoManager * _sharedManager = nil;
@implementation VideoManager
- (id)init
{
    self = [super init];
    if (self) {
        _videoList = [[NSMutableArray alloc] initWithCapacity:10];
        
        self.model = [[RSTCoreDataModel alloc] initWithName:@"SwingAnalysis"];
        self.stack = [RSTCoreDataStack defaultStackWithStoreURL:self.model.storeURL modelURL:self.model.modelURL];
    }
    
    return self;
}

+ (id)sharedManager
{
    if (_sharedManager == nil)
    {
        @synchronized(self)
        {
            _sharedManager = [[VideoManager alloc] init];
        }
    }
    
    return _sharedManager;
}

#pragma mark - Video List Utils
+ (NSString *)date2FormattedString:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    
    return [df stringFromDate:date];
}

+ (NSString *)nextVideoName
{
    NSString *videoName = [VideoManager date2FormattedString:[NSDate date]];
    return videoName;
}

+ (NSString *)year:(NSString *)formattedVideoName
{
    return [formattedVideoName substringWithRange:NSMakeRange(0, 4)];
}

+ (NSString *)monthName:(NSString *)formattedVideoName
{
    NSString *monthString = [formattedVideoName substringWithRange:NSMakeRange(4, 2)];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    return [[df monthSymbols] objectAtIndex:[monthString intValue] - 1];
}

+ (NSString *)day:(NSString *)formattedVideoName
{
    return [formattedVideoName substringWithRange:NSMakeRange(6, 2)];
}

+ (NSString *)hour:(NSString *)formattedVideoName
{
    return [formattedVideoName substringWithRange:NSMakeRange(8, 2)];
}

+ (NSString *)minute:(NSString *)formattedVideoName
{
    return [formattedVideoName substringWithRange:NSMakeRange(10, 2)];
}

+ (NSString *)creationDate:(NSString *)formattedVideoName
{
    NSString *monthName = [VideoManager monthName:formattedVideoName];
    NSString *day = [VideoManager day:formattedVideoName];
    NSString *hour = [VideoManager hour:formattedVideoName];
    NSString *minute = [VideoManager minute:formattedVideoName];
    
    int iHour = [hour intValue];
    NSString *creationDate = nil;
    if (iHour == 0) {
        creationDate = [NSString stringWithFormat:@"%@ %@, %02d:%@ %@", monthName, day, 12, minute, @"am"];
    } else if (iHour < 12) {
        creationDate = [NSString stringWithFormat:@"%@ %@, %02d:%@ %@", monthName, day, iHour, minute, @"am"];
    } else if (iHour == 12) {
        creationDate = [NSString stringWithFormat:@"%@ %@, %02d:%@ %@", monthName, day, 12, minute, @"pm"];
    } else if (iHour < 24) {
        creationDate = [NSString stringWithFormat:@"%@ %@, %02d:%@ %@", monthName, day, iHour - 12, minute, @"pm"];
    }
    
    return creationDate;
}

#pragma mark - Video List Manage
- (int)videoCount
{
    return (int)[_videoList count];
}

- (void)addVideo:(NSString *)videoName
{
    VideoEntity *entity = [VideoEntity rst_insertNewObjectInManagedObjectContext:self.stack.managedObjectContext];
    entity.videoname = videoName;
    entity.videostate = @(VIDEO_STATE_NORMAL);
    entity.date = [NSDate date];
    entity.title = @"";
    entity.detail = @"";
    entity.tag = @"";
    entity.shared = @"";
    [RSTCoreDataContextSaver saveAndWait:self.stack.managedObjectContext];

}

- (void)addMixVideo:(NSString *)videoName
{
    VideoEntity *entity = [VideoEntity rst_insertNewObjectInManagedObjectContext:self.stack.managedObjectContext];
    entity.videoname = videoName;
    entity.videostate = @(VIDEO_STATE_MIX);
    entity.date = [NSDate date];
    entity.title = @"";
    entity.detail = @"";
    entity.tag = @"";
    entity.shared = @"";
    [RSTCoreDataContextSaver saveAndWait:self.stack.managedObjectContext];
    
}

- (void)deleteVideoAtIndex:(int)index
{

    if (index < 0 || index >= [_videoList count])
        return;
    
    NSDictionary *infoDic = (NSMutableDictionary *)[_videoList objectAtIndex:index];
    NSString *videoName = [infoDic objectForKey:kVideoNameKey];
    [FSManager deleteVideo:videoName];
    
    [_videoList removeObjectAtIndex:index];
}

- (NSMutableDictionary *)videoAtIndex:(int)index
{
    if (index < 0 || index >= [_videoList count])
        return nil;
    
    return (NSMutableDictionary *)[_videoList objectAtIndex:index];
}

- (void)updateVideoComment:(NSString *)comment index:(int)index
{

    NSMutableDictionary *infoDic = [self videoAtIndex:index];
    if (infoDic) {
        [infoDic setObject:comment forKey:kVideoCommentKey];
    }
}

- (void)updateVideoState:(VIDEO_STATE)videoState index:(int)index
{
    
    NSMutableDictionary *infoDic = [self videoAtIndex:index];
    if (infoDic) {
        [infoDic setObject:[NSString stringWithFormat:@"%d", videoState] forKey:kVideoStateKey];
    }
}

#pragma mark - Store / Restore
- (void)clearVideoList
{
    ;
}

- (BOOL)storeVideoList
{
    return [_videoList writeToFile:[FSManager videoPlistPath] atomically:YES];
}

- (NSArray *)restoreVideoList;
{
    /*
    NSArray *tmpList = [NSArray arrayWithContentsOfFile:[FSManager videoPlistPath]];
    if (!tmpList)
        return NO;
    
    [_videoList removeAllObjects];
    [_videoList addObjectsFromArray:tmpList];
    
    return true;*/
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"VideoEntity"  inManagedObjectContext: self.stack.managedObjectContext];
    [fetch setEntity:entityDescription];
    NSError * error = nil;
    NSArray *fetchedObjects = [self.stack.managedObjectContext executeFetchRequest:fetch error:&error];
    return fetchedObjects;
}

- (void)deleteVideo:(VideoEntity *)entity
{
    [self.stack.managedObjectContext deleteObject:entity];
    [RSTCoreDataContextSaver saveAndWait:self.stack.managedObjectContext];
}

- (void)updateComment:(VideoEntity *)entity comment:(NSString *)comment
{
    entity.detail = comment;
    [RSTCoreDataContextSaver saveAndWait:self.stack.managedObjectContext];

}

- (void)updateState:(VideoEntity *)entity state:(VIDEO_STATE)videoState
{
    entity.videostate = @(videoState);
    [RSTCoreDataContextSaver saveAndWait:self.stack.managedObjectContext];
}

- (void)updateVideo:(VideoEntity *)entity
{
    [RSTCoreDataContextSaver saveAndWait:self.stack.managedObjectContext];

}

@end
