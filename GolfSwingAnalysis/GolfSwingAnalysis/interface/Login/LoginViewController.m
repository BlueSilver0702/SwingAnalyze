//
//  LoginViewController.m
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/15/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import "LoginViewController.h"
#import "NSString+HTML.h"

#pragma mark - AutoRotation In iOS6.0
@implementation UINavigationController (AutoRotation_In_iOS6)

- (BOOL)shouldAutorotate
{
    if (self.topViewController)
        return [self.topViewController shouldAutorotate];
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (self.topViewController)
        return [self.topViewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.topViewController)
        //return [self.topViewController interfaceOrientation];
        return [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationPortrait;
}
@end

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _rememberCheckbox.strokeColor = [UIColor whiteColor];
    _rememberCheckbox.checkColor = [UIColor whiteColor];
    _rememberCheckbox.tintColor = [UIColor clearColor];
    
    if (IS_IPAD)
        _rememberCheckbox.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    else
        _rememberCheckbox.titleLabel.font = [UIFont systemFontOfSize:12.0f];

    _rememberCheckbox.titleLabel.textColor = [UIColor whiteColor];
    _rememberCheckbox.titleLabel.text = @"Remember Me";
    _rememberCheckbox.checkAlignment = M13CheckboxAlignmentLeft;
    _rememberCheckbox.checkHeight = 20.0f;
    _rememberCheckbox.radius = 2.0f;
    
    if ([[AppSetttings remember] isEqualToString:@"YES"])
    {
        _emailField.text = [AppSetttings userEmail];
        _passwordField.text = [AppSetttings userPassword];
        _academyField.text = [AppSetttings userAcademyName];
        _rememberCheckbox.checkState = M13CheckboxStateChecked;
    }
    
    JGProgressHUD *hud = [CommonFunc showImmediateHud];
    [hud showInView:self.view];
    [[APIService sharedManager] getAcademyies:^(NSArray *result,NSError *error){
        
        [hud dismiss];
        if (error){
            
            [CommonFunc showAlert:ERROR description:error.localizedDescription];
            _academyField.text = @"";

        }
        else
            [self setAcademies:result];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Auto Rotatation
- (NSUInteger)shouldAutorotateToInterfaceOrientation
{
    return (UIInterfaceOrientationMaskPortrait);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (IBAction)onBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onLogin:(id)sender
{
    if (_emailField.text.length == 0 || _passwordField.text.length == 0)
    {
        [self showAlert:ERROR description:LOGIN_MAILPASSWORDEMPTY_ERROR];
        return;
    }
    
    if (_academyField.text.length == 0)
    {
        [self showAlert:ERROR description:LOGIN_ACADEMYEMPTY_ERROR];
        return;
    }
    
    NSDictionary *dic = [_academyArr objectAtIndex:_academyPicker.selectedIndex];
    JGProgressHUD  *HUD = [CommonFunc showImmediateHud];
    HUD.textLabel.text = @"Logging in...";
    [HUD showInView:self.view];
    [[APIService sharedManager] authoLogin:_emailField.text password:_passwordField.text option:dic[@"id"] waver:YES onCompletion:^(NSDictionary *result ,NSError *error){
        
        if (error)
        {
            [HUD dismiss];
            [self showAlert:ERROR description:error.localizedDescription];
        }
        else
        {
            NSString *token = [result objectForKey:@"token"];
            if (token)
            {
                [AppSetttings setUserToken:[NSString stringWithFormat:@"bearer %@" ,token]];
                [AppSetttings setUserEmail:_emailField.text];
                [AppSetttings setUserPassword:_passwordField.text];
                [AppSetttings setUserSubdomain:dic[@"sub_domain"]];
                [AppSetttings setUserAcademyName:dic[@"name"]];
                [AppSetttings setUserAcademyId:dic[@"id"]];
                
                if (_rememberCheckbox.checkState == M13CheckboxStateChecked)
                {
                    [AppSetttings setRemember:@"YES"];
                }
                else
                    [AppSetttings setRemember:@"NO"];
                
                [[APIService sharedManager] getStudents:^(NSDictionary *result,NSError *error){
                    
                    [HUD dismiss];

                    if (error)
                    {
                        [self showAlert:ERROR description:error.localizedDescription];
                    }
                    else
                    {
                        // change array , save NSUserDefaults
                        NSArray* studentArr = [result linq_toArray:^id(id key, NSDictionary *value) {
                            
                            return @[key , value[@"avatar"] ,value[@"fullname"]];
                            
                        }];
                        
                        [AppSetttings setStudents:studentArr];
                        [self performSegueWithIdentifier:@"mainSegue" sender:nil];
                    }

                }];
                
            }
            else
            {
                [self showAlert:ERROR description:result[@"message"]];
            }

        }
    }];
}

- (IBAction)dismissKey:(id)sender
{
    [(UITextField *)sender resignFirstResponder];
}

- (void)setAcademies:(NSArray *)academyArr
{
    _academyPicker = [[DownPicker alloc] initWithTextField:_academyField];
    [_academyPicker setPlaceholder:@"Select Academy"];
    _academyArr = [academyArr linq_sort:^id(NSDictionary* academy) {
        return academy[@"name"];
    }];
    
    NSArray *titleArr = [_academyArr linq_select:^id(NSDictionary *dic) {
        return [dic[@"name"] stringByDecodingHTMLEntities];
    }];
    
    [_academyPicker setData:titleArr];
}

- (UIAlertView *)showAlert:(NSString *)title description:(NSString *)description
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
    return av;
}

@end
