//
//  AppSetttings.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "AppSetttings.h"

#define kUserEmailKey                           @"userEmail"
#define kUserPasswordKey                        @"userPassword"
#define kUserTokenKey                           @"token"
#define kAcademyIdKey                           @"acadeyid"
#define kAcademyNameKey                         @"acadeyname"
#define kSubdomainKey                           @"subdomain"
#define kRememberKey                            @"remember"
#define kStudentKey                             @"student"

#define kEnable10sDelayKey                      @"enable10sDelay"
#define kEnable10sDelayKey                      @"enable10sDelay"
#define kEnableTrimAfterRecordingKey            @"enableTrimAfterRecording"
#define kEnableLeftHandedKey                    @"enableLeftHanded"


@implementation AppSetttings
#pragma mark - User Info
+ (NSString *)userEmail
{
    NSString *userEmail = [[NSUserDefaults standardUserDefaults] stringForKey:kUserEmailKey];
    if (userEmail == nil)
        return @"";
    
    return userEmail;
}

+ (void)setUserEmail:(NSString *)userEmail
{
    [[NSUserDefaults standardUserDefaults] setObject:(userEmail != nil) ? userEmail : @"" forKey:kUserEmailKey];
}

+ (NSString *)userPassword
{
    NSString *userPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kUserPasswordKey];
    if (userPassword == nil)
        return @"";
    
    return userPassword;
}

+ (void)setUserPassword:(NSString *)userPassword
{
    [[NSUserDefaults standardUserDefaults] setObject:(userPassword != nil) ? userPassword : @"" forKey:kUserPasswordKey];
}

+ (NSString *)userToken
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserTokenKey];
    if (token == nil)
        return @"";
    
    return token;
}

+ (void)setUserToken:(NSString *)userToken
{
    [[NSUserDefaults standardUserDefaults] setObject:(userToken != nil) ? userToken : @"" forKey:kUserTokenKey];

}

+ (NSString *)userAcademyId
{
    NSString *academyId = [[NSUserDefaults standardUserDefaults] stringForKey:kAcademyIdKey];
    if (academyId == nil)
        return @"";
    
    return academyId;
}

+ (void)setUserAcademyId:(NSString *)userAcademyId
{
    [[NSUserDefaults standardUserDefaults] setObject:(userAcademyId != nil) ? userAcademyId : @"" forKey:kAcademyIdKey];

}

+ (NSString *)userAcademyName
{
    NSString *academyName = [[NSUserDefaults standardUserDefaults] stringForKey:kAcademyNameKey];
    if (academyName == nil)
        return @"";
    
    return academyName;
}

+ (void)setUserAcademyName:(NSString *)userAcademyName
{
    [[NSUserDefaults standardUserDefaults] setObject:(userAcademyName != nil) ? userAcademyName : @"" forKey:kAcademyNameKey];

}

+ (NSString *)userSubdomain
{
    NSString *subdomain = [[NSUserDefaults standardUserDefaults] stringForKey:kSubdomainKey];
    if (subdomain == nil)
        return @"";
    
    return subdomain;
}

+ (void)setUserSubdomain:(NSString *)userSubdomain
{
    [[NSUserDefaults standardUserDefaults] setObject:(userSubdomain != nil) ? userSubdomain : @"" forKey:kSubdomainKey];

}

+ (NSString *)remember
{
    NSString *rememberme = [[NSUserDefaults standardUserDefaults] stringForKey:kRememberKey];
    if (rememberme == nil)
        return @"";
    
    return rememberme;
}

+ (void)setRemember:(NSString *)remember;
{
    [[NSUserDefaults standardUserDefaults] setObject:(remember != nil) ? remember : @"" forKey:kRememberKey];

}

+ (NSArray *)students
{
    NSArray *studentsArr = [[NSUserDefaults standardUserDefaults] objectForKey:kStudentKey];
    if (studentsArr == nil)
        return [NSArray new];
    return studentsArr;
}

+ (void)setStudents:(NSArray *)studentsArr
{
    [[NSUserDefaults standardUserDefaults] setObject:studentsArr forKey:kStudentKey];
}

#pragma mark - Record Settings
+ (BOOL)isEnabled10sDelay
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnable10sDelayKey];
}


+ (void)enable10sDelay:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kEnable10sDelayKey];
}

+ (BOOL)isEnabledTrimAfterRecording
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableTrimAfterRecordingKey];
}


+ (void)enableTrimAfterRecording:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kEnableTrimAfterRecordingKey];
}

+ (BOOL)isEnabledLeftHanded
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kEnableLeftHandedKey];
}

+ (void)enableLeftHanded:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kEnableLeftHandedKey];
}

@end
