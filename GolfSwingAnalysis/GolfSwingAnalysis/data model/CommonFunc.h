//
//  CommonFunc.h
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/26/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFunc : NSObject

+ (UIAlertView *)showAlert:(NSString *)title description:(NSString *)description;
+ (UIAlertView *)showAlert1:(NSString *)title description:(NSString *)description;

+ (JGProgressHUD *)showImmediateHud;
+ (JGProgressHUD *)showProgressHud;

@end
