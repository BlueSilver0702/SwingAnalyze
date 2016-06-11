//
//  AppSetttings.h
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSetttings : NSObject

+ (NSString *)userEmail;
+ (void)setUserEmail:(NSString *)userEmail;
+ (NSString *)userPassword;
+ (void)setUserPassword:(NSString *)userPassword;

+ (NSString *)userToken;
+ (void)setUserToken:(NSString *)userToken;

+ (NSString *)userAcademyId;
+ (void)setUserAcademyId:(NSString *)userAcademyId;

+ (NSString *)userAcademyName;
+ (void)setUserAcademyName:(NSString *)userAcademyName;

+ (NSString *)userSubdomain;
+ (void)setUserSubdomain:(NSString *)userSubdomain;

+ (NSString *)remember;
+ (void)setRemember:(NSString *)remember;

+ (NSArray *)students;
+ (void)setStudents:(NSArray *)studentsArr;


+ (BOOL)isEnabled10sDelay;
+ (void)enable10sDelay:(BOOL)enable;
+ (BOOL)isEnabledTrimAfterRecording;
+ (void)enableTrimAfterRecording:(BOOL)enable;
+ (BOOL)isEnabledLeftHanded;
+ (void)enableLeftHanded:(BOOL)enable;

@end
