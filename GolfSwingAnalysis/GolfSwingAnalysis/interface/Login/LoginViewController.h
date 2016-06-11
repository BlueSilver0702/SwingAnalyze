//
//  LoginViewController.h
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/15/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "M13Checkbox.h"
#import "DownPicker.h"

@interface LoginViewController : UIViewController

@property (nonatomic ,assign) IBOutlet UITextField *emailField;
@property (nonatomic ,assign) IBOutlet UITextField *passwordField;
@property (nonatomic ,assign) IBOutlet UITextField *academyField;
@property (nonatomic ,assign) IBOutlet M13Checkbox *rememberCheckbox;

@property (nonatomic ,strong) NSArray    *academyArr;
@property (nonatomic ,strong) DownPicker        *academyPicker;

- (IBAction)onBack:(id)sender;
- (IBAction)onLogin:(id)sender;
- (IBAction)dismissKey:(id)sender;

@end
