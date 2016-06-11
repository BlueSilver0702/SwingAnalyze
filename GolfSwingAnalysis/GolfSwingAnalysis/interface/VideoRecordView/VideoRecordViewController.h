//
//  VideoRecordViewController.h
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "BaseTabItemViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef enum _POSE_TYPE
{
    POSE_OFF = 0,
    POSE_DTL,
    POSE_FRONT,
    POSE_TYPE_COUNT
} POSE_TYPE;

typedef enum _VC_STATE
{
    VC_NORMAL = 0,
    VC_NEED_GOBACK,
    VC_NEED_PICKUP,
    VC_NEED_STOP,
} VC_STATE;

@class VideoRecordViewController;
@protocol VideoRecordViewControllerDelegate <NSObject>
@optional
- (void)didRecordFinished:(VideoRecordViewController *)vc;
@end

@class AVCamCaptureManager, AVCaptureVideoPreviewLayer;

@interface VideoRecordViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate
    , UIActionSheetDelegate>
{
    AVCaptureVideoPreviewLayer *    _newCaptureVideoPreviewLayer;
    VC_STATE                        _vcState;
    NSTimer *                       _recordingUpdateTimer;
    
    BOOL                            _bIsRecording;

}

@property(nonatomic, weak) UIViewController *parent;
@property(nonatomic, weak) id<VideoRecordViewControllerDelegate> delegate;
@property(nonatomic, strong) NSString *recordedVidePath;

@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@property (nonatomic,assign) IBOutlet UIView *videoPreviewView;
@property (nonatomic,assign) IBOutlet UIImageView *poseView;
@property (nonatomic,assign) IBOutlet UIImageView *gridView;
@property (nonatomic,assign) IBOutlet UIButton *poseButton;
@property (nonatomic,assign) IBOutlet UIButton *settingsButton;
@property (nonatomic,assign) IBOutlet UIButton *switchCameraButton;
@property (nonatomic,assign) IBOutlet UIButton *goBackButton;
@property (nonatomic,assign) IBOutlet UIButton *toggleReocrdButton;
@property (nonatomic,assign) IBOutlet UIButton *browseButton;
@property (nonatomic,assign) IBOutlet UIButton *trashButton;
@property (nonatomic,assign) IBOutlet UILabel *timeLabel;
@property (nonatomic,assign) IBOutlet UIImageView *timeLabelBG;

@property (nonatomic) POSE_TYPE poseType;

@property (nonatomic) CGFloat        grid1DifX;
@property (nonatomic) CGFloat        grid1DifY;
@property (nonatomic) CGPoint        grid1StartPoint;

- (IBAction)OnPoseButton:(id)sender;
- (IBAction)OnToggleSettings:(id)sender;
- (IBAction)OnToggleCamera:(id)sender;
- (IBAction)OnGoBack:(id)sender;
- (IBAction)OnToggleRecord:(id)sender;
- (IBAction)OnPicker:(id)sender;
- (IBAction)OnTrash:(id)sender;
@end
