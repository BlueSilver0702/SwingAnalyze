//
//  APIService.m
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/15/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import "APIService.h"

@implementation APIService

+ (id)sharedManager
{
    static APIService *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super alloc] init];
    });
    return sharedManager;
}

- (void)authoLogin:(NSString *)email password:(NSString *)password option:(NSString *)academyId waver:(BOOL)accept onCompletion:(RequestCompletionHandler)complete
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"email": email ,@"password" : password ,@"api_academy_id" : academyId};
    if (accept == YES)
        parameters = @{@"email": email ,@"password" : password ,@"api_academy_id" : academyId ,@"waiver_accepted" :@"y"};
    [manager POST:[NSString stringWithFormat:@"%@%@" ,MAIN_DOMAIN ,LOGIN_URL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Autho: %@", responseObject);
        complete(responseObject ,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error.localizedDescription);
        complete(nil ,error);
    }];
}

- (void)regenerateToken:(RequestCompletionHandler)complete
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[AppSetttings userToken] forHTTPHeaderField:@"Authorization"];
    manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:[NSString stringWithFormat:@"%@%@" ,MAIN_DOMAIN ,GENERATE_TOKEN] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Token: %@", responseObject);
        complete(responseObject ,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        complete(nil ,error);
        
    }];
}

- (void)getAcademyies:(RequestCompletionHandler1)complete
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@" ,MAIN_DOMAIN ,ACADEMY_LIST_URL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Academies: %@", responseObject);
        complete(responseObject ,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error.localizedDescription);
        complete(nil ,error);
        
    }];
}

- (void)getStudents:(RequestCompletionHandler)complete
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[AppSetttings userToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@%@" ,MAIN_DOMAIN ,STUDENTS_LIST_URL] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Students: %@", responseObject);
        complete(responseObject ,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error.localizedDescription);
        complete(nil ,error);
        
    }];
}

- (void)getMedia:(NSString *)academyId onCompletion:(RequestCompletionHandler)complete
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[AppSetttings userToken] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@%@%@" ,MAIN_DOMAIN ,MEDIA_LIST_UEL ,academyId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Media: %@", responseObject);
        complete(responseObject ,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        complete(nil ,error);
        
    }];
}

@end
