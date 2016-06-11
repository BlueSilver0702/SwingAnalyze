//
//  VideoEntity+CoreDataProperties.h
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/26/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "VideoEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *detail;
@property (nullable, nonatomic, retain) NSString *tag;
@property (nullable, nonatomic, retain) NSString *shared;
@property (nullable, nonatomic, retain) NSNumber *videostate;
@property (nullable, nonatomic, retain) NSString *videoname;

@end

NS_ASSUME_NONNULL_END
