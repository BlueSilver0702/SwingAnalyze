//
//  SwingViewController.h
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/9/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawBoardView.h"
#import "SeekSlider.h"
#import "FrameSeekScroller.h"
#import "iCarousel.h"
#import "LayerRecorder.h"
#import "AudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "AVMixer.h"

#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <sys/times.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "VideoRecordViewController.h"

@interface SwingViewController : UIViewController <DrawBoardViewDeleate ,iCarouselDataSource, iCarouselDelegate ,FrameSeekScrollerDelegate ,AVAudioRecorderDelegate, AVMixerDelegate ,UITableViewDataSource ,UITableViewDelegate ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate ,UIAlertViewDelegate ,UIActionSheetDelegate ,UIAlertViewDelegate ,VideoRecordViewControllerDelegate>
{
    LayerRecorder *     mRecorder;
    AudioRecorder *     mAudioRecorder;
    AVMixer *           mMixer;
    NSTimer *           mRecordingUpdateTimer;
    BOOL                _isRecording;
    
    float frameRate;
    BOOL includeAudio;
    BOOL bIsCameraRoll;

}

@property(nonatomic, weak) UIViewController *parent;

@property (nonatomic ,assign) IBOutlet UIView *allrecordingView;
@property (nonatomic ,assign) IBOutlet UIView *myrecordingView;
@property (nonatomic ,assign) IBOutlet UIView *otherrecordingView;
@property (nonatomic ,assign) IBOutlet UIButton *recordButton;

// my record view
@property (nonatomic ,assign) IBOutlet UIButton *myplayBtn;
@property (nonatomic ,assign) IBOutlet FrameSeekScroller *myframeSeeker;
@property (nonatomic ,assign) IBOutlet DrawBoardView *mydrawView;
@property (nonatomic ,assign) IBOutlet AVPlayerView  *myPlayerView;

//other record view
@property (nonatomic ,assign) IBOutlet UIButton *otherplayBtn;
@property (nonatomic ,assign) IBOutlet FrameSeekScroller *otherframeSeeker;
@property (nonatomic ,assign) IBOutlet DrawBoardView *otherdrawView;
@property (nonatomic ,assign) IBOutlet AVPlayerView  *otherPlayerView;

@property (nonatomic ,assign) IBOutlet UITableView *mytableView;
@property (nonatomic ,assign) IBOutlet UIView  *toolView;

@property (nonatomic ,strong) NSString *videoPath;
@property (nonatomic ,strong) NSString *othervideoPath;
@property (nonatomic ,retain) NSURL *imagerollUrl;

@property (nonatomic ,strong) UIImage  *swingImage;

@property(nonatomic) DRAWING_COLOR drawingColor;
@property(nonatomic) DRAWING_TOOL selectedDrawingTool;

// swing toolbar

@property(nonatomic, weak) IBOutlet UIButton *showToolBarButton;

@property(nonatomic, assign) IBOutlet UIView *drawingToolbar;
@property(nonatomic, assign) IBOutlet UIButton *circleButton;
@property(nonatomic, assign) IBOutlet UIButton *lineButton;
@property(nonatomic, assign) IBOutlet UIButton *angleButton;
@property(nonatomic, assign) IBOutlet UIButton *freeDrawButton;
@property(nonatomic, assign) IBOutlet UIButton *trashButton;
@property(nonatomic, assign) IBOutlet UIButton *clearAllButton;
@property(nonatomic, assign) IBOutlet UIButton *closeToolBarButton;

- (IBAction)onPlay:(id)sender;
- (IBAction)onStop:(id)sender;
- (IBAction)onForward:(id)sender;
- (IBAction)onBackward:(id)sender;

- (IBAction)onRecord:(id)sender;

//
- (IBAction)OnShowDrawToolbar:(id)sender;
- (IBAction)OnCloseDrawToolbar:(id)sender;
- (IBAction)OnToolbarButton:(id)sender;
- (IBAction)OnTrashButton:(id)sender;
- (IBAction)OnClearAll:(id)sender;

- (IBAction)onPop:(id)sender;

@end
