//
//  ShareViewController.m
//  GolfSwingAnalysis
//
//  Created by Top1 on 9/8/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "ShareViewController.h"
#import "NSData+Base64.h"
#import "VideoManager.h"
#import "FSManager.h"
#import "M13Checkbox.h"
#import "VideoTabItemViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _moviePath = [NSString stringWithString:[FSManager videoFilePath:_entity.videoname]];
    _description = _entity.detail;
    
    CALayer *textLayer = [self.descriptionTextView layer];
    [textLayer setBorderColor:[UIColor colorWithRed:0.9
                                              green:0.91
                                               blue:0.925
                                              alpha:1].CGColor];
    textLayer.borderWidth = 1.0f;
    textLayer.cornerRadius = 4.0f;
    self.descriptionTextView.backgroundColor = [UIColor whiteColor];
    _tagView.tagPlaceholder = @"tag";
    _tagView.mode = TLTagsControlModeEdit;
    
    textLayer = [_tagView layer];
    [textLayer setBorderColor:[UIColor colorWithRed:0.9
                                              green:0.91
                                               blue:0.925
                                              alpha:1].CGColor];
    textLayer.borderWidth = 1.0f;
    textLayer.cornerRadius = 4.0f;
    
    _swipeView.alignment = SwipeViewAlignmentCenter;
    _swipeView.pagingEnabled = NO;
    _swipeView.itemsPerPage = 3;
    _swipeView.truncateFinalPage = NO;

    self.selectedStudentArr = [NSMutableArray new];
    self.selectedAvatarArr = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_swipeView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Video Save in Local
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self.hud dismiss];
    
    NSString *title = (error == nil) ? @"Info" : @"Warning";
    NSString *message = (error == nil) ? @"Successed Saving To Camera Roll." : @"Failed Saving To Camera Roll.";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView  show];
}

#pragma mark - User Action
- (IBAction)OnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SwipeViewDelegate, SwipeViewDataSource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return [AppSetttings students].count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[NSBundle mainBundle] loadNibNamed:@"UserCheckCell" owner:self options:nil][0];
        
    }
    
    UIImageView *avatarImageView = (UIImageView *)[view viewWithTag:1];
    UILabel *nameLbl = (UILabel *)[view viewWithTag:2];
    NSArray *user = (NSArray *)[[AppSetttings students] objectAtIndex:index];
    nameLbl.text = user[2];
    
    M13Checkbox * userCheckBox = (M13Checkbox *)[view viewWithTag:3];
    [userCheckBox addTarget:self action:@selector(pressedCheckButton:) forControlEvents:UIControlEventTouchUpInside];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:user[1]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
        
        if (finished && !error) avatarImageView.image = image;
        else avatarImageView.image = [UIImage imageNamed:@"dfm_member"];
    }];
    
    return view;
}

- (void)pressedCheckButton:(id)sender
{
    NSInteger index = [_swipeView indexOfItemViewOrSubview:sender];
    NSArray *user = (NSArray *)[[AppSetttings students] objectAtIndex:index];
    M13Checkbox *checkBox = (M13Checkbox *)sender;
    if (checkBox.checkState == M13CheckboxStateChecked)
    {
        [_selectedStudentArr addObject:user[0]];
        [_selectedAvatarArr addObject:user[1]];

    }
    else
    {
        [_selectedStudentArr removeObject:user[0]];
        [_selectedAvatarArr removeObject:user[1]];

    }
}

- (IBAction)OnShareToWebSite:(id)sender
{

    [self uploadVideo];

}

- (void)uploadVideo
{
    self.hud = [CommonFunc showProgressHud];
    [self.hud showInView:self.navigationController.view];
    
    NSString *tagStr = [_tagView.tags componentsJoinedByString:@","];
    NSString *studentStr = [_selectedStudentArr componentsJoinedByString:@","];
    NSDictionary *dic = @{@"tags" : tagStr , @"students" : studentStr , @"description" : _descriptionTextView.text};
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:MEDIA_UPLOAD_URL ,MAIN_DOMAIN] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:_moviePath] name:@"upload" error:nil];
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSProgress *progress = nil;
    
    [request setValue:[AppSetttings userToken] forHTTPHeaderField:@"Authorization"];
    AFJSONResponseSerializer *serialize = [AFJSONResponseSerializer serializer];
    serialize.acceptableContentTypes = [serialize.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer = serialize;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        [self.hud dismiss];
        
        if (error) {
            NSLog(@"Error: %@", error);
            [CommonFunc showAlert:ERROR description:error.localizedDescription];
            
        } else {
            NSLog(@"Response : %@", responseObject);
            
            UIAlertView *alertView = [CommonFunc showAlert1:SUCCESS description:@"Successfully Uploaded , would you like to save locally?"];
            alertView.delegate = self;
        }
        
    }];
    
    [progress addObserver:self forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [uploadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //update UI;
            self.hud.progress = progress.fractionCompleted;
        });
        
    }
}

- (IBAction)OnSaveToCameraRoll:(id)sender
{
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_moviePath)) {
        self.hud = [CommonFunc showImmediateHud];
        self.hud.textLabel.text = @"Wait...";
        [self.hud showInView:self.navigationController.view];
        
        UISaveVideoAtPathToSavedPhotosAlbum(_moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                            message:@"Access Denied for Server"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView  show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // update local database with upload information
        
        self.entity.tag = [_tagView.tags componentsJoinedByString:@","];
        self.entity.shared = [_selectedAvatarArr componentsJoinedByString:@","];
        self.entity.detail = self.descriptionTextView.text;
        [[VideoManager sharedManager] updateVideo:self.entity];
        
        VideoTabItemViewController *vc = (VideoTabItemViewController *)self.parent;
        [vc onRefreshVideoList];

    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
