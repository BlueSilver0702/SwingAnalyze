//
//  CommonFunc.m
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/26/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import "CommonFunc.h"

@implementation CommonFunc

+ (UIAlertView *)showAlert:(NSString *)title description:(NSString *)description
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
    return av;
}

+ (UIAlertView *)showAlert1:(NSString *)title description:(NSString *)description
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [av show];
    return av;
}

+ (JGProgressHUD *)showImmediateHud
{
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    HUD.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    return HUD;
}

+ (JGProgressHUD *)showProgressHud
{
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    HUD.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
    HUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] initWithHUDStyle:HUD.style];
    HUD.textLabel.text = @"Uploading...";
    return HUD;
}

@end
