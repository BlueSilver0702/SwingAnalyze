//
//  ShareViewController.h
//  GolfSwingAnalysis
//
//  Created by Top1 on 9/8/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView/SwipeView.h>
#import "TLTagsControl.h"

@interface ShareViewController : UIViewController <UITextFieldDelegate ,SwipeViewDelegate, SwipeViewDataSource ,UIAlertViewDelegate>
{    
    NSString *                  _moviePath;
    NSString *                  _description;
}

@property (nonatomic ,assign) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet SwipeView *swipeView;
@property (nonatomic ,assign) IBOutlet TLTagsControl *tagView;

@property (nonatomic ,strong) JGProgressHUD *hud;

@property(nonatomic, weak) UIViewController *parent;
@property (nonatomic ,strong) NSMutableArray *selectedStudentArr;
@property (nonatomic ,strong) NSMutableArray *selectedAvatarArr;

@property (nonatomic ,strong) VideoEntity *entity;

- (IBAction)OnBack:(id)sender;
- (IBAction)OnShareToWebSite:(id)sender;
- (IBAction)OnSaveToCameraRoll:(id)sender;
@end
