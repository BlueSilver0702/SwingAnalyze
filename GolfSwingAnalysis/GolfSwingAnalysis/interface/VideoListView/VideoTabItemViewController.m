//
//  VideoTabItemViewController.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "VideoTabItemViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "VideoFinalViewController.h"
#import "VideoRecordViewController.h"
#import "CommentViewController.h"
#import "ShareViewController.h"
#import "LayerRecorder.h"
#import "VideoManager.h"
#import "FSManager.h"
#import "CVideoEditorController.h"
#import "SwingViewController.h"
#import "VideoEntity.h"
#import "SearchResultsViewController.h"

@interface VideoTabItemViewController () <UISearchResultsUpdating ,UISearchControllerDelegate>

@property (nonatomic, strong) UISearchController *controller;
@property (strong, nonatomic) NSArray *results;

@end

#pragma mark - VideoTabItemViewController
@implementation VideoTabItemViewController

@synthesize popviewCtrl;

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

    SearchResultsViewController *searchResults = (SearchResultsViewController *)self.controller.searchResultsController;
    [self addObserver:searchResults forKeyPath:@"results" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    //_videoTbl.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.navigationItem setHidesBackButton:YES];
    _libraryBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _sitelibraryBtn.titleLabel.textAlignment = NSTextAlignmentCenter;

    NSMutableAttributedString *astring = [[NSMutableAttributedString alloc] initWithString:@"\U0000e04B Record Video"];
    [astring addAttribute:NSFontAttributeName
                    value:[UIFont fontWithName:@"MaterialIcons-Regular" size:18.0f]
                    range:NSMakeRange(0,1)]; // The first character
    [astring addAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } range:NSMakeRange(0, 14)];
    [astring addAttribute:NSBaselineOffsetAttributeName
                    value:[NSNumber numberWithFloat:-4.0]  //adjust this number till text appears to be centered
                    range:NSMakeRange(0, 1)];
    
    [_recordBtn setAttributedTitle:astring forState:UIControlStateNormal];
    
    _instructionView.text = @"Please tap to record video.";
    [self onRefreshVideoList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VideoList2VideoComment"])
    {
        CommentViewController *vc = (CommentViewController *)[segue destinationViewController];
        vc.parent = self;
        vc.entity = sender;
    } else if ([segue.identifier isEqualToString:@"VideoList2VideoPlay"]) {

        
    }
    else if ([segue.identifier isEqualToString:@"swingSegue"]) {
        SwingViewController *vc = (SwingViewController *)[segue destinationViewController];
        vc.parent = self;
        vc.videoPath = sender;
    }
    else if ([segue.identifier isEqualToString:@"VideoList2VideoRecord"]) {
        VideoRecordViewController *vc = (VideoRecordViewController *)[segue destinationViewController];
        vc.parent = self;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"VideoList2VideoFinalPlay"]) {
        VideoFinalViewController *vc = (VideoFinalViewController *)[segue destinationViewController];
        vc.parent = self;
        if (sender != nil)
        {
            vc.moviePath = (NSString *)sender;
        } else {
            vc.moviePath = [LayerRecorder defaultOutputPath];
        }
    } else if ([segue.identifier isEqualToString:@"VideoList2VideoShare"]) {
        ShareViewController *vc = (ShareViewController *)[segue destinationViewController];
        vc.parent = self;
        vc.entity = sender;
    }
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

#pragma mark - UITableView Deleate & DataSource
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videoArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *VideoCellIndentifier = @"VideoCellIndentifier";
    VideoTableCell *videoCell = (VideoTableCell *)[tableView dequeueReusableCellWithIdentifier:VideoCellIndentifier forIndexPath:indexPath];
    videoCell.index = (int)indexPath.row;
    videoCell.delegate = self;
    
    VideoEntity *entity = [self.videoArr objectAtIndex:indexPath.row];
    [videoCell setEntity:entity];
    return videoCell;
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = self.controller.searchBar.text;

    NSMutableArray *compoundArr = [NSMutableArray new];
    [compoundArr addObject:[NSPredicate predicateWithFormat:@"%K contains[cd] %@" ,@"detail" ,searchString]];
    [compoundArr addObject:[NSPredicate predicateWithFormat:@"%K contains[cd] %@" ,@"tag" ,searchString]];
    NSPredicate *compoundPre = [NSCompoundPredicate orPredicateWithSubpredicates:compoundArr];
    self.results = [self.videoArr filteredArrayUsingPredicate:compoundPre];
}

- (UISearchController *)controller {
    
    if (!_controller) {
        
        // instantiate search results table view
        SearchResultsViewController *resultsController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResults"];
        
        // create search controller
        _controller = [[UISearchController alloc] initWithSearchResultsController:resultsController];
        _controller.searchResultsUpdater = self;
        _controller.hidesNavigationBarDuringPresentation = NO;
        _controller.dimsBackgroundDuringPresentation = NO;
        self.definesPresentationContext = YES;
        // optional: set the search controller delegate
        _controller.delegate = self;
        
    }
    return _controller;
}

# pragma mark - Search Controller Delegate (optional)

- (void)didDismissSearchController:(UISearchController *)searchController {
    
    // called when the search controller has been dismissed
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    
    // called when the serach controller has been presented
}

- (void)presentSearchController:(UISearchController *)searchController {
    
    // if you want to implement your own presentation for how the search controller is shown,
    // you can do that here
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
    // called just before the search controller is dismissed
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    // called just before the search controller is presented
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"Delete the current video?"]) { //Delete
        if (buttonIndex == 0) {
            int videoIndex = (int)actionSheet.tag - 100;
            VideoEntity *entity = [self.videoArr objectAtIndex:videoIndex];
            [[VideoManager sharedManager] deleteVideo:entity];
            [self onRefreshVideoList];
        }
    } else if ([actionSheet.title isEqualToString:@""]) {   //Main Menu has Delete / Trim
        if (buttonIndex == 0) {             //Prompt Delete Swing.
            UIActionSheet *deleteSheet = [[UIActionSheet alloc] initWithTitle:@"Delete the current video?"
                                                                     delegate:self
                                                            cancelButtonTitle:@"No"
                                                       destructiveButtonTitle:@"Yes"
                                                            otherButtonTitles:nil];
            
            deleteSheet.tag = actionSheet.tag;
            [deleteSheet showInView:self.view];
        } else if (buttonIndex == 1) {      //Trim Delete Swing
            int videoIndex = (int)actionSheet.tag - 100;
            VideoEntity *entity = [self.videoArr objectAtIndex:videoIndex];
            NSString *videoName = entity.videoname;
            NSString *videoPath = [FSManager videoFilePath:videoName];
            
            //Trim
            if ([UIVideoEditorController canEditVideoAtPath:videoPath]) {
                UIVideoEditorController *editor = [UIVideoEditorController new];
                editor.videoPath = videoPath;
                editor.videoMaximumDuration = 0;
                editor.delegate = self;
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                {
                    self.popviewCtrl = [[UIPopoverController alloc] initWithContentViewController:editor];
                    self.popviewCtrl.delegate = self;
                    
                    [self.popviewCtrl presentPopoverFromRect:CGRectMake(592, 790, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
                }
                else
                {
                    [self presentViewController:editor animated:YES completion:nil];
                
                }
                
                
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                    message:@"Trim Not Supported."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
}

#pragma mark - UIV.ideoEditorController Delegate
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    if ([FSManager copyAtPath:editedVideoPath toPath:editor.videoPath]) {
        NSString *videoName = [[editor.videoPath lastPathComponent] stringByDeletingPathExtension];
        [FSManager makeThumb:videoName];
        
        [self onRefreshVideoList];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cell Delegate
- (void)onShare:(VideoTableCell *)aCell index:(int)index
{
    VideoEntity *entity = [_videoArr objectAtIndex:index];
    [self performSegueWithIdentifier:@"VideoList2VideoShare" sender:entity];
}

- (void)onComment:(VideoTableCell *)aCell index:(int)index
{
    VideoEntity *entity = [_videoArr objectAtIndex:index];
    [self performSegueWithIdentifier:@"VideoList2VideoComment" sender:entity];
}

- (void)onExtraAction:(VideoTableCell *)aCell index:(int)index
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Delete video", @"Trim Swing",@"Cancel" , nil];

    actionSheet.tag = index + 100;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    
}

- (void)onPlay:(VideoTableCell *)aCell index:(int)index
{
    VideoEntity *entity = [_videoArr objectAtIndex:index];
    VIDEO_STATE videoState = (VIDEO_STATE)[entity.videostate intValue];
    if (videoState == VIDEO_STATE_NORMAL) {
        [self performSegueWithIdentifier:@"swingSegue" sender:[FSManager videoFilePath:entity.videoname]];
    } else if (videoState == VIDEO_STATE_MIX) {
        [self performSegueWithIdentifier:@"VideoList2VideoFinalPlay" sender:[FSManager videoFilePath:entity.videoname]];
    }
}

#pragma mark - RecordView Delegate
- (void)didRecordFinished:(VideoRecordViewController *)vc {
    [self onRefreshVideoList];
}

#pragma mark - User Interface
- (IBAction)OnRecord:(id)sender
{
    [self performSegueWithIdentifier:@"VideoList2VideoRecord" sender:nil];
}

- (void)onPlayFinalVideo:(NSString *)videoPath;
{
    if (videoPath != nil)
    {
        [self performSegueWithIdentifier:@"VideoList2VideoFinalPlay" sender:videoPath];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Recording Failed!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)onLibrary:(id)sender
{
    UIImagePickerController *picker;
    picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
        picker.delegate = self;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)onSiteLibrary:(id)sender
{
    [self performSegueWithIdentifier:@"mediaSegue" sender:nil];
}

- (void)onRefreshVideoList
{
    self.videoArr = [[NSMutableArray alloc] initWithArray:[[VideoManager sharedManager] restoreVideoList]];
    if (self.videoArr.count > 0)
    {
        [_videoTbl reloadData];
        _videoTbl.hidden = NO;
        _instructionView.hidden = YES;
    }
    else
    {
        _videoTbl.hidden = YES;
        _instructionView.hidden = NO;
    }
}

- (IBAction)onSearch:(id)sender
{
    [self presentViewController:self.controller animated:YES completion:nil];

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *pickedVideoPath = [videoUrl path];
    NSString *videoName = [VideoManager nextVideoName];
    
    BOOL isCopied = [FSManager copyVideoAtPath:pickedVideoPath name:videoName];
    
    if (isCopied)
    {
        [FSManager makeThumb:videoName];
        [self performSelector:@selector(didPickVideoProc:) withObject:videoName afterDelay:1.0f];
    } else {
        
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didPickVideoProc:(NSString *)videoName
{
    //add video list
    [[VideoManager sharedManager] addVideo:videoName];
    [self onRefreshVideoList];
}

@end
