//
//  APIService.h
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/15/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIService : NSObject

+ (id)sharedManager;

typedef void(^RequestCompletionHandler)(NSDictionary *result,NSError *error);
typedef void(^RequestCompletionHandler1)(NSArray *result,NSError *error);

- (void)authoLogin:(NSString *)email password:(NSString *)password option:(NSString *)academyId waver:(BOOL)accept onCompletion:(RequestCompletionHandler)complete;
- (void)regenerateToken:(RequestCompletionHandler)complete;
- (void)getAcademyies:(RequestCompletionHandler1)complete;
- (void)getStudents:(RequestCompletionHandler)complete;
- (void)getMedia:(NSString *)academyId onCompletion:(RequestCompletionHandler)complete;

@end
