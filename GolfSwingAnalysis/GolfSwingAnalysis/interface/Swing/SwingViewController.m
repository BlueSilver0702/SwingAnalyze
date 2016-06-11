//
//  SwingViewController.m
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/9/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import "SwingViewController.h"
#import "VideoTabItemViewController.h"
#import "VideoManager.h"
#import "FSManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kFrameWheelItemWidth 15
#define kFrameWheelItemGapWidth 3
#define kFrameWheelItemHeight 40

#define kFrameSeekCountMax 3

#define kTagMySeekBar 100
#define kTagOtherSeekBar 101

@interface SwingViewController ()
{
    NSTimer *       _progressmyTimer;
    NSTimer *       _progressotherTimer;
    
    IBOutlet NSLayoutConstraint *recordSpace;
    IBOutlet NSLayoutConstraint *toolbarSpace;
    
    int frameWheelItemCount;
    int frameWheelItemGapWidth;
    int frameWheelItemWidth;
    
}

@property (nonatomic ,strong) JGProgressHUD  *HUD;

@end

@implementation SwingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    _mydrawView.userInteractionEnabled = NO;
    _otherdrawView.userInteractionEnabled = NO;
    
    // Draw View
    self.mydrawView.delegate = self;
    self.otherdrawView.delegate = self;
    _mytableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    recordSpace.constant = - [[UIScreen mainScreen] bounds].size.width;
    toolbarSpace.constant = - [[UIScreen mainScreen] bounds].size.width;
    
    _mytableView.hidden = YES;
    self.drawingToolbar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"VideoPlay2VideoRecord"]) {
        VideoRecordViewController *vc = segue.destinationViewController;
        vc.parent = self;
        vc.delegate = self;
        vc.recordedVidePath = [[NSString alloc] initWithString:[FSManager tempVideoPath] ];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadVideo:self.videoPath isSelfVideo:YES];
    
    mRecorder = [[LayerRecorder alloc] init];
    _isRecording = NO;
    mRecordingUpdateTimer = nil;
    
    //Create Audio Recorder
    mAudioRecorder = [[AudioRecorder alloc] init];
    mAudioRecorder.delegate = self;
    
    //Create Mixer
    mMixer = [[AVMixer alloc] init];
    mMixer.delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    //if (self.myframeSeeker.subviews.count == 0)
        [self configFrameSeekBar];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [mRecorder stopRecording];
    [mRecordingUpdateTimer invalidate];
    mRecordingUpdateTimer = nil;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self adjustUIbyOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        frameWheelItemCount = self.view.frame.size.width / frameWheelItemWidth / 2;
    }
    else
        frameWheelItemCount = self.view.frame.size.width / frameWheelItemWidth;
    
    [self.myframeSeeker.scroller reloadData];
    [self.otherframeSeeker.scroller reloadData];
}

- (void)adjustUIbyOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //NSLog(@"Width : %f , Height : %f" ,[[UIScreen mainScreen] bounds].size.width ,[[UIScreen mainScreen] bounds].size.height);
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        recordSpace.constant = - [[UIScreen mainScreen] bounds].size.height;
        toolbarSpace.constant = - [[UIScreen mainScreen] bounds].size.height;
        _mytableView.hidden = YES;
        
    }
    else{
        
        recordSpace.constant = 0;
        toolbarSpace.constant = 0;
//         record , swing , neither
        if (_othervideoPath == nil && _imagerollUrl == nil)
            _mytableView.hidden = NO;
        else
            _mytableView.hidden = YES;
        
    }
}

- (void)configFrameSeekBar{
    
    frameWheelItemWidth = (IS_IPAD) ? kFrameWheelItemWidth * 2 : kFrameWheelItemWidth;
    frameWheelItemGapWidth = (IS_IPAD) ? kFrameWheelItemGapWidth * 2 : kFrameWheelItemGapWidth;
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        frameWheelItemCount = self.view.frame.size.width / frameWheelItemWidth / 2;
    }
    else
        frameWheelItemCount = self.view.frame.size.width / frameWheelItemWidth;
    
    [_myframeSeeker setup];
    _myframeSeeker.delegate = self;
    _myframeSeeker.scroller.dataSource = self;
    _myframeSeeker.scroller.delegate = self;
    _myframeSeeker.scroller.pastIndex = 0;
    _myframeSeeker.scroller.tag = kTagMySeekBar;
    
    [_otherframeSeeker setup];
    _otherframeSeeker.delegate = self;
    _otherframeSeeker.scroller.dataSource = self;
    _otherframeSeeker.scroller.delegate = self;
    _otherframeSeeker.scroller.pastIndex = 0;
    _otherframeSeeker.scroller.tag = kTagOtherSeekBar;
    
}

#pragma mark - Load Video
- (void)loadVideo:(NSString *)videoFilePath isSelfVideo:(BOOL)isSelfVideo
{
    NSURL *fileURL = [NSURL fileURLWithPath:videoFilePath];
    if (!isSelfVideo && bIsCameraRoll) fileURL = self.imagerollUrl;
    
    AVPlayerView *movieView = isSelfVideo ? _myPlayerView : _otherPlayerView;
    [movieView setLoop:YES];
    [movieView setFileURL:fileURL isAudio:NO];
    
}

#pragma mark -  iCarouselDataSource, iCarouselDelegate
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return frameWheelItemCount;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UIView *itemView = view;
    if (!itemView)
    {
        itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWheelItemWidth, kFrameWheelItemHeight)];
        itemView.backgroundColor = [UIColor lightGrayColor];
        
        UIView *gapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameWheelItemGapWidth, kFrameWheelItemHeight)];
        gapView.backgroundColor = [UIColor darkGrayColor];
        gapView.tag = 1;
        [itemView addSubview:gapView];
    }
    
    UIView *gapView = [itemView viewWithTag:1];
    gapView.backgroundColor = (index == 1) ? [UIColor redColor] : [UIColor darkGrayColor];
    
    return itemView;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    return 0;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return frameWheelItemWidth;
}

- (CATransform3D)carousel:(iCarousel *)_carousel transformForItemView:(UIView *)view withOffset:(CGFloat)offset
{
    return CATransform3DIdentity;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionWrap)
        return YES;
    
    return value;
}

- (void)carousel:(iCarousel *)carousel withCurrentIndex:(NSUInteger)index toIncrease:(BOOL)toIncrease
{
    if (carousel.pastIndex == index)
    {
        return;
    }
    
    NSInteger di = index - carousel.pastIndex;
    if (!toIncrease)
    {
        if (di < 0 )
            di += frameWheelItemCount;
        
        if (di > kFrameSeekCountMax)
            di = kFrameSeekCountMax;
    } else {
        if (di > 0)
            di -= frameWheelItemCount;
        
        if (di < -kFrameSeekCountMax)
            di = -kFrameSeekCountMax;
    }
    
    if (carousel.tag == kTagMySeekBar) {
        [self onProgressSelfTimer:nil];
        [_myPlayerView stepByCount:(int)di];
    }
    else
    {
        [self onProgressOtherTimer:nil];
        [_otherPlayerView stepByCount:(int)di];
    }
    
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    if (carousel.tag == kTagMySeekBar)
    {
        [_myPlayerView pause];
        [self stopUpdateProgress:YES];
    }
    
    if (carousel.tag == kTagOtherSeekBar)
    {
        [_otherPlayerView pause];
        [self stopUpdateProgress:NO];
    }
}

- (void)frameSeekScrollerTapped:(FrameSeekScroller *)frameSeekScroller isBackButton:(BOOL)isBackButton
{
    BOOL isMine = (frameSeekScroller.tag == kTagMySeekBar);
    
    if (isMine) {
        [_myPlayerView stepByCount:isBackButton ? -1 : 1];
        [self onProgressSelfTimer:nil];
    } else {
        [_otherPlayerView stepByCount:isBackButton ? -1 : 1];
        [self onProgressOtherTimer:nil];
    }
    
}

#pragma mark- DrawBoardViewDeleate
- (void)drawBoardViewPropertyChanged:(DrawBoardView *)aDrawBoardView withInfo:(NSDictionary *)dictionary
{
    DRAWING_COLOR drawingColorType = (DRAWING_COLOR)[(NSNumber *)[dictionary objectForKey:kDrawingColorKey] intValue];
    DRAWING_TOOL drawingShapeType = (DRAWING_TOOL)[(NSNumber *)[dictionary objectForKey:kDrawingShapeKey] intValue];
    
    self.drawingColor = drawingColorType;
    self.selectedDrawingTool = drawingShapeType;
}

- (void)initializeDrawToolbar
{
    self.drawingColor = DRAWING_COLOR_RED;
    self.selectedDrawingTool = DRAWING_TOOL_LINE;
    
    self.circleButton.tag = DRAWING_TOOL_CIRCLE;
    self.lineButton.tag = DRAWING_TOOL_LINE;
    self.angleButton.tag = DRAWING_TOOL_ANGLE;
    self.freeDrawButton.tag = DRAWING_TOOL_FREEDRAW;
    self.trashButton.tag = DRAWING_TOOL_TRASH;
    self.closeToolBarButton.tag = DRAWING_TOOL_CLOSE;
    
    [_mydrawView setShapeType:self.selectedDrawingTool];
    [_mydrawView setShapeColor:self.drawingColor];
    
    [_otherdrawView setShapeType:self.selectedDrawingTool];
    [_otherdrawView setShapeColor:self.drawingColor];
    
    [self showClearAllButton:NO];
    [self updateDrawToolbar];
}

- (void)showClearAllButton:(BOOL)showable
{
    self.circleButton.hidden = showable;
    self.lineButton.hidden = showable;
    self.angleButton.hidden = showable;
    self.freeDrawButton.hidden = showable;
    self.trashButton.hidden = NO;
    self.closeToolBarButton.hidden = NO;
    
    self.clearAllButton.hidden = !showable;
}

- (void)updateDrawToolbar
{
    [self.circleButton setImage:[UIImage imageNamed:@"circle_iPhone.png"] forState:UIControlStateNormal];
    [self.lineButton setImage:[UIImage imageNamed:@"lineTool_iPhone.png"] forState:UIControlStateNormal];
    [self.angleButton setImage:[UIImage imageNamed:@"angle_iPhone.png"] forState:UIControlStateNormal];
    [self.freeDrawButton setImage:[UIImage imageNamed:@"freeDraw_iPhone.png"] forState:UIControlStateNormal];
    [self.trashButton setImage:[UIImage imageNamed:@"trashCan_iPhone.png"] forState:UIControlStateNormal];
    [self.closeToolBarButton setImage:[UIImage imageNamed:@"closeDrawer_iPhone.png"] forState:UIControlStateNormal];
    
    UIButton *selectedButton = nil;
    NSString *imageBaseName = nil;
    switch (self.selectedDrawingTool) {
        case DRAWING_TOOL_CIRCLE:
            selectedButton = self.circleButton;
            imageBaseName = @"circle";
            break;
        case DRAWING_TOOL_LINE:
            selectedButton = self.lineButton;
            imageBaseName = @"lineTool";
            break;
        case DRAWING_TOOL_ANGLE:
            selectedButton = self.angleButton;
            imageBaseName = @"angle";
            break;
        case DRAWING_TOOL_FREEDRAW:
            selectedButton = self.freeDrawButton;
            imageBaseName = @"freeDraw";
            break;
        case DRAWING_TOOL_TRASH:
            selectedButton = self.trashButton;
            imageBaseName = @"trash";
            break;
        default:
            selectedButton = nil;
            imageBaseName = nil;
            break;
    }
    
    if (selectedButton)
    {
        NSString *colorName = @"";
        switch (self.drawingColor) {
            case DRAWING_COLOR_RED:
                colorName = @"Red";
                break;
            case DRAWING_COLOR_WHITE:
                colorName = @"White";
                break;
            case DRAWING_COLOR_YELLOW:
                colorName = @"Yellow";
                break;
            default:
                colorName = @"";
                break;
        }
        
        NSString *imageName = [NSString stringWithFormat:@"%@%@_iPhone.png", imageBaseName, colorName];
        [selectedButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

#pragma mark - Audio Recording
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [mRecordingUpdateTimer invalidate];
    mRecordingUpdateTimer = nil;
    self.recordButton.selected = NO;
    //todo
    
    //Start Mixing
    self.HUD = [CommonFunc showImmediateHud];
    [self.HUD showInView:self.view];
    [mMixer startMixingWithVideoPath:[LayerRecorder defaultOutputPath] withAudioPath:[AudioRecorder defaultOutputPath]];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [mRecordingUpdateTimer invalidate];
    mRecordingUpdateTimer = nil;
    self.recordButton.selected = NO;
    
    [self performSelectorOnMainThread:@selector(onBack:) withObject:nil waitUntilDone:YES];
}

#pragma mark - Mix Video & Audio Export
- (void)onBack:(NSString *)filePath
{

}

- (void)didMixProc:(id)sender {
    [self performSelector:@selector(onSaveAndBack:) withObject:nil afterDelay:1.0f];
}

- (void)onSaveAndBack:(NSString *)filePath
{
    
    [_myPlayerView stop];
    [_otherPlayerView stop];
    
    [self.HUD dismiss];

    VideoTabItemViewController *vc = (VideoTabItemViewController *)self.parent;
    
    //save
    NSString *videoName = [VideoManager nextVideoName];
    
    BOOL isCopied = [FSManager copyVideoAtPath:[AVMixer defaultOutputPath] name:videoName];
    if (isCopied)
    {
        [FSManager makeThumb:videoName];
        
        //add video list
        [[VideoManager sharedManager] addMixVideo:videoName];
        
        //update video list
        [vc onRefreshVideoList];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - AVMixerDelegate
- (void)mixDidFinished:(AVMixer *)aMixer
{
    [self performSelectorOnMainThread:@selector(didMixProc:) withObject:nil waitUntilDone:YES];
    
}

#pragma mark - ReocrdView Delegate
- (void)didRecordFinished:(VideoRecordViewController *)vc
{
    _mytableView.hidden = YES;
    _othervideoPath = vc.recordedVidePath;
    [self loadVideo:_othervideoPath isSelfVideo:NO];
    
}

#pragma mark - UITableViewDataSource ,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swingCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Recording a Swing";
            break;
        case 1:
            cell.textLabel.text = @"My Swings";
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        
        // Recording a Swing
        [self performSegueWithIdentifier:@"VideoPlay2VideoRecord" sender:nil];
        bIsCameraRoll = NO;
        
    }else{
        // My Swings
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        bIsCameraRoll = YES;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^(void){
        _mytableView.hidden = YES;

        // set video to other video player view
        self.imagerollUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        [self loadVideo:_videoPath isSelfVideo:NO];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - User Action
- (void)onPauseVideo:(BOOL)isMine
{
    if (isMine) {
        [self stopUpdateProgress:YES];
        [_myPlayerView pause];
    } else {
        [self stopUpdateProgress:NO];
        [_otherPlayerView pause];
    }
}

- (IBAction)onPlay:(id)sender
{
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.isSelected];
    BOOL isSelf = (button.tag == 0) ? YES : NO;
    if (isSelf)
    {
        if (button.isSelected)
            [_myPlayerView play];
        else
            [_myPlayerView pause];
    }
    else
    {
        if (button.isSelected)
            [_otherPlayerView play];
        else
            [_otherPlayerView pause];
    }
    
}

- (IBAction)onForward:(id)sender
{
    
    UIButton *button = (UIButton *)sender;
    BOOL isSelf = (button.tag == 0) ? YES : NO;
    if (isSelf)
    {
        [_myplayBtn setSelected:NO];
        [_myPlayerView pause];
        [_myPlayerView stepByCount:1];
    }
    else {
        [_otherplayBtn setSelected:NO];
        [_otherPlayerView pause];
        [_otherPlayerView stepByCount:1];
    }
}

- (IBAction)onBackward:(id)sender
{
    UIButton *button = (UIButton *)sender;
    BOOL isSelf = (button.tag == 0) ? YES : NO;
    if (isSelf)
    {
        [_myplayBtn setSelected:NO];
        [_myPlayerView pause];
        [_myPlayerView stepByCount:-1];

    }
    else {
        [_otherplayBtn setSelected:NO];
        [_otherPlayerView pause];
        [_otherPlayerView stepByCount:-1];
    }
}

- (IBAction)onStop:(id)sender
{
    [_myPlayerView stop];
    [_otherPlayerView stop];

}

- (IBAction)onRecord:(id)sender
{
    // Record Code
    if (_isRecording)
    {
        [mRecorder stopRecording];
        [mAudioRecorder stopRecording];
        
        if (mRecordingUpdateTimer != nil) {
            [mRecordingUpdateTimer invalidate];
            mRecordingUpdateTimer = nil;
        }
        
    } else {
        
        mRecordingUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(onRecordingTimer:) userInfo:nil repeats:YES];
        
        [mRecorder setLayer:_allrecordingView.layer];
        
        [mRecorder startRecording];
        [mAudioRecorder startRecording];
        
    }
    
    _isRecording = !_isRecording ;
    
}

- (IBAction)OnShowDrawToolbar:(id)sender
{
    CGRect frame;
    frame = self.drawingToolbar.frame;
    frame.origin.x = 0.0f;
    [self initializeDrawToolbar];
    self.drawingToolbar.hidden = NO;
    
    [UIView animateWithDuration:0.2
                     animations:^ {
                         self.drawingToolbar.frame = frame;
                     }
                     completion:^ (BOOL finished) {
                         self.showToolBarButton.hidden = YES;
                         
                         _mydrawView.userInteractionEnabled = YES;
                         _otherdrawView.userInteractionEnabled = YES;
                         
                     }
     ];
}

- (IBAction)OnCloseDrawToolbar:(id)sender
{
    if ([_mydrawView isDeletable])
        [_mydrawView toggleDeletable];
    
    [_mydrawView finishDraw];
    
    if ([_otherdrawView isDeletable])
        [_otherdrawView toggleDeletable];
    
    [_otherdrawView finishDraw];
    
    CGRect frame;
    frame = self.drawingToolbar.frame;
    frame.origin.x = 320.0f;
    [UIView animateWithDuration:0.2
                     animations:^ {
                         self.drawingToolbar.frame = frame;
                     }
                     completion:^ (BOOL finished) {
                         self.showToolBarButton.hidden = NO;
                         
                         self.drawingToolbar.hidden = YES;
                         _mydrawView.userInteractionEnabled = NO;
                         _otherdrawView.userInteractionEnabled = NO;
                         
                     }
     ];
}

- (IBAction)OnToolbarButton:(id)sender
{
    UIButton *selectedButton = (UIButton *)sender;
    
    self.selectedDrawingTool = (int)selectedButton.tag;
    
    self.drawingColor++;
    if (self.drawingColor == DRAWING_COLOR_COUNT)
        self.drawingColor = DRAWING_COLOR_RED;
    
    [_mydrawView setShapeType:self.selectedDrawingTool];
    [_mydrawView setShapeColor:self.drawingColor];
    [_otherdrawView setShapeType:self.selectedDrawingTool];
    [_otherdrawView setShapeColor:self.drawingColor];
    
    [self updateDrawToolbar];
}

- (IBAction)OnTrashButton:(id)sender
{
    self.selectedDrawingTool = DRAWING_TOOL_NONE;
    
    [_mydrawView toggleDeletable];
    [_otherdrawView toggleDeletable];
    
    [self showClearAllButton:self.clearAllButton.hidden];
    [self updateDrawToolbar];
}

- (IBAction)OnClearAll:(id)sender
{
    [_mydrawView clearBoard];
    [_otherdrawView clearBoard];
    
    [self showClearAllButton:NO];
}

- (IBAction)onPop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [self.HUD dismiss];
    if (error != nil) {
        NSLog(@"Try to save video and got error: %@", [error description]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRecordingTimer:(id)sender
{
    self.recordButton.selected = !self.recordButton.selected;
    self.recordButton.highlighted = !self.recordButton.highlighted;
}

- (void)starUpdateProgress:(BOOL)isSelfVideo
{
    if (isSelfVideo)
        _progressmyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 5.0 target:self selector:@selector(onProgressSelfTimer:) userInfo:nil repeats:YES];
    else
        _progressotherTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 5.0 target:self selector:@selector(onProgressOtherTimer:) userInfo:nil repeats:YES];
    
}

- (void)stopUpdateProgress:(BOOL)isSelfVideo
{
    if (isSelfVideo)
    {
        [_progressmyTimer invalidate];
        _progressmyTimer = nil;
    }
    else
    {
        [_progressotherTimer invalidate];
        _progressotherTimer = nil;
    }
    
}

#pragma mark - Playback Progress
- (void)onProgressSelfTimer:(id)sender
{
    //float selfVideoCurrentTime = [_myvideoPlayerCtrl currentTime];
    //_mytimeSlider.value = selfVideoCurrentTime;
}

- (void)onProgressOtherTimer:(id)sender
{
    //float selfVideoCurrentTime = [_othervideoPlayerCtrl currentTime];
    //_othertimeSlider.value = selfVideoCurrentTime;
}

@end
