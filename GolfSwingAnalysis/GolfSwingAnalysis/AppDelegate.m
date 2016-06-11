//
//  AppDelegate.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/6/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoManager.h"
#import "RSTCoreDataKit.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],NSForegroundColorAttributeName,
                                               [UIFont systemFontOfSize:16.0f] ,NSFontAttributeName,
                                               nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#F58026"]];

    NSTimeInterval time = 60.0 * 30;
    self.tokenUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                             target:self
                                                           selector:@selector(updateToken)
                                                           userInfo:nil
                                                            repeats:YES];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[VideoManager sharedManager] restoreVideoList];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)updateToken
{
    NSLog(@"User Token refreshed !!");
    [[APIService sharedManager] regenerateToken:^(NSDictionary *result,NSError *error){
        
        if (!error)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString *token = [result objectForKey:@"token"];
                    [AppSetttings setUserToken:[NSString stringWithFormat:@"bearer %@" ,token]];
                    
                });
            });
        }
        
    }];
}

@end
