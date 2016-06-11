//
//  VideoRecordViewController.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "VideoRecordViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "FSManager.h"
#import "VideoManager.h"
#import "VideoTabItemViewController.h"

@interface VideoRecordViewController (AVCamCaptureManagerDelegate)  <AVCamCaptureManagerDelegate>

@end

@implementation VideoRecordViewController
@synthesize videoPreviewView, poseButton, settingsButton, switchCameraButton, goBackButton, toggleReocrdButton, browseButton;
@synthesize grid1DifX;
@synthesize grid1DifY;
@synthesize grid1StartPoint;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_bIsRecording) {
        _vcState = VC_NEED_STOP;
        [[self captureManager] stopRecording];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		;
	} else {
		CGRect frame;
		
		frame = self.poseButton.frame;
		frame.origin.y += 20;
		self.poseButton.frame = frame;
		
		frame = self.settingsButton.frame;
		frame.origin.y += 20;
		self.settingsButton.frame = frame;
		
		frame = self.switchCameraButton.frame;
		frame.origin.y += 20;
		self.switchCameraButton.frame = frame;
		
	}
	
    //init params
    _vcState = VC_NORMAL;
    _bIsRecording = NO;
    
    //init UI
    [self updateButtonState:_bIsRecording];
    self.gridView.hidden = YES;
    
	// Do any additional setup after loading the view.
	if ([self captureManager] == nil) {
		AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
		[self setCaptureManager:manager];
		
		[[self captureManager] setDelegate:self];
        
		if ([[self captureManager] setupSession]) {
            // Create video preview layer and add it to the UI
			_newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[[self captureManager] session]];
			UIView *view = [self videoPreviewView];
			CALayer *viewLayer = [view layer];
			[viewLayer setMasksToBounds:YES];
			
			CGRect bounds = [view bounds];
			[_newCaptureVideoPreviewLayer setFrame:bounds];
			
			if ([_newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
				[_newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
			}
			
			[_newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			
			[viewLayer insertSublayer:_newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			[self setCaptureVideoPreviewLayer:_newCaptureVideoPreviewLayer];
			
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[[self captureManager] session] startRunning];
			});
			
            self.poseType = 0;
            [self updatePoseState];

            [self updateCamSwitchButtonStates];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(deviceOrientationDidChange)
                                                         name:UIDeviceOrientationDidChangeNotification object:nil];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIView *view = [self videoPreviewView];
    CGRect bounds = [view bounds];
    [_newCaptureVideoPreviewLayer setFrame:bounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auto Rotatation
- (NSUInteger)shouldAutorotateToInterfaceOrientation
{
    return (UIInterfaceOrientationMaskAllButUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskAllButUpsideDown);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return (UIInterfaceOrientationPortrait);
}

- (void)deviceOrientationDidChange
{
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation orientation;
    
	if (deviceOrientation == UIDeviceOrientationPortrait) {
		orientation = AVCaptureVideoOrientationPortrait;
	} else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	} else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		orientation = AVCaptureVideoOrientationLandscapeRight;
	} else {
		orientation = AVCaptureVideoOrientationLandscapeLeft;
	}
    
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
    CGRect previewBounds = [[self videoPreviewView] bounds];
    [_newCaptureVideoPreviewLayer setFrame:previewBounds];
    
    
    [_newCaptureVideoPreviewLayer.connection setVideoOrientation:orientation];
}

#pragma mark - Timer
- (void)onRecordingTimer:(id)sender
{
    self.toggleReocrdButton.selected = !self.toggleReocrdButton.selected;
    
    int recordedTimeInSec = [[self captureManager] recordedTime];
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", recordedTimeInSec / 60, recordedTimeInSec % 60];
}

#pragma mark - AVCamCaptureManagerDelegate
- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
        
        _bIsRecording = NO;
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        //record start
        _bIsRecording = YES;
        [self updateButtonState:_bIsRecording];
        
        _recordingUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                 target:self
                                                               selector:@selector(onRecordingTimer:)
                                                               userInfo:nil
                                                                repeats:YES];
    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager error:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        _bIsRecording = NO;
        [self updateButtonState:_bIsRecording];
        self.toggleReocrdButton.selected = NO;

        [_recordingUpdateTimer invalidate];
        _recordingUpdateTimer = nil;
        
        //record stop
        switch (_vcState) {
            case VC_NORMAL:
            {
                //copy video
                if (self.recordedVidePath == nil) {
                    NSString *videoName = [VideoManager nextVideoName];
                    BOOL isCopied = [FSManager copyVideoAtPath:[AVCamCaptureManager tempFilePath] name:videoName];
                    if (isCopied)
                    {
                        [FSManager makeThumb:videoName];
                        
                        //add video list
                        [[VideoManager sharedManager] addVideo:videoName];
                        
                        //update video list
                        if ([self.delegate respondsToSelector:@selector(didRecordFinished:)]) {
                            [self.delegate didRecordFinished:self];
                        }

                        [self goBack];
                    }
                } else {
                    BOOL isCopied = [FSManager copyAtPath:[AVCamCaptureManager tempFilePath] toPath:self.recordedVidePath];
                    if (isCopied) {
                        //update video list
                        if ([self.delegate respondsToSelector:@selector(didRecordFinished:)]) {
                            [self.delegate didRecordFinished:self];
                        }
                    
                        [self goBack];
                    }
                }
            }
                break;
            case VC_NEED_GOBACK:
                [self goBack];
                break;
            case VC_NEED_PICKUP:
                [self showVideoPicker];
                break;
            case VC_NEED_STOP:
                break;
            default:
                break;
        }
        
        _vcState = VC_NORMAL;
    });
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
	[self updateCamSwitchButtonStates];
}

#pragma mark - UIImagePicker Delegate
- (void)didPickVideoProc:(NSString *)videoName
{
    //add video list
    [[VideoManager sharedManager] addVideo:videoName];
    
    //update video list
    if ([self.delegate respondsToSelector:@selector(didRecordFinished:)]) {
        [self.delegate didRecordFinished:self];
    }
    
    self.view.userInteractionEnabled = YES;
    [self goBack];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *pickedVideoPath = [videoUrl path];
    NSString *videoName = [VideoManager nextVideoName];
    
    if (self.recordedVidePath == nil) {
        BOOL isCopied = [FSManager copyVideoAtPath:pickedVideoPath name:videoName];
        
        if (isCopied)
        {
            [FSManager makeThumb:videoName];
            
            [self performSelector:@selector(didPickVideoProc:) withObject:videoName afterDelay:1.0f];
        } else {
            self.view.userInteractionEnabled = YES;
        }
    } else {
        BOOL isCopied = [FSManager copyAtPath:pickedVideoPath toPath:self.recordedVidePath];
        if (isCopied) {
            //update video list
            if ([self.delegate respondsToSelector:@selector(didRecordFinished:)]) {
                [self.delegate didRecordFinished:self];
            }
            
            [self goBack];
        } else {
            self.view.userInteractionEnabled = YES;
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //delete
        _vcState = VC_NEED_STOP;
        [[self captureManager] stopRecording];
    }
}

#pragma mark - UI
- (void)updateButtonState:(BOOL)bIsRecording
{
    self.trashButton.hidden = !bIsRecording;
    self.timeLabel.hidden = !bIsRecording;
    self.timeLabelBG.hidden = !bIsRecording;
    
    self.goBackButton.hidden = bIsRecording;
    self.browseButton.hidden = bIsRecording;
    self.poseButton.hidden = bIsRecording;
    self.settingsButton.hidden = bIsRecording;
    self.switchCameraButton.hidden = bIsRecording;
    
    self.timeLabel.text = @"00:00";
}

- (void)updateCamSwitchButtonStates
{  
	NSUInteger cameraCount = [[self captureManager] cameraCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self switchCameraButton] setEnabled:NO];
            
            if (cameraCount < 1) {
            } else {
                [[self toggleReocrdButton] setEnabled:YES];
            }
        } else {
            [[self switchCameraButton] setEnabled:YES];
            [[self toggleReocrdButton] setEnabled:YES];
        }
    });    
}

- (void)updatePoseState
{
    NSString *poseBtnImageName = nil;
    NSString *posImageName = nil;

    CGPoint centerPt;
    CGRect frameRt;
    centerPt = self.poseView.center;
    frameRt = self.poseView.frame;
    
    switch (self.poseType) {
        case POSE_OFF:
            poseBtnImageName = (IS_IPAD) ? @"silhouetteDTL_iPad.png" : @"silhouetteDTL_iPhone.png";
            posImageName = nil;
            break;
        case POSE_DTL:
            poseBtnImageName = (IS_IPAD) ? @"silhouetteFRONT_iPhone.png" : @"silhouetteFRONT_iPhone.png";
            posImageName = (IS_IPAD) ? @"downTheLineOutlineLighteriPad.png" : @"downTheLineOutlineLighter.png";
            frameRt.size.width = 170;
            break;
        case POSE_FRONT:
            poseBtnImageName = (IS_IPAD) ? @"silhouetteOFF_iPhone.png" : @"silhouetteOFF_iPhone.png";
            posImageName = (IS_IPAD) ? @"frontOutlineLighteriPad.png" : @"frontOutlineLighter.png";
            frameRt.size.width = 90;
            break;
        default:
            poseBtnImageName = nil;
            posImageName = nil;
            break;
    }
    
    self.poseView.frame = frameRt;
    self.poseView.center = centerPt;
    
    [self.poseButton setImage:[UIImage imageNamed:poseBtnImageName] forState:UIControlStateNormal];
    [self.poseView setImage:[UIImage imageNamed:posImageName]];
}

#pragma mark - UI Action
- (void)goBack
{
    [self.parent dismissViewControllerAnimated:YES completion:nil];
}

- (void)showVideoPicker
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
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - User Action
- (IBAction)OnPoseButton:(id)sender
{
    self.poseType++;
    if (self.poseType == POSE_TYPE_COUNT)
        self.poseType = POSE_OFF;
    
    [self updatePoseState];
}

- (IBAction)OnToggleSettings:(id)sender
{
    self.gridView.hidden = !self.gridView.hidden;
    
    if (self.gridView.hidden == NO)
    {
        
        [self redrawGrid:0];
        // [self redrawGrid:1];
        
    }
    else
    {
        self.grid1DifX = 0.0f;
        self.grid1DifY = 0.0f;
    
        self.gridView.image = Nil;
    
    }
}

- (void) redrawGrid:(int)index
{
         UIGraphicsBeginImageContext(self.gridView.frame.size);
        
        // Pass 1: Draw the original image as the background
        [self.gridView.image drawAtPoint:CGPointMake(0,0)];
        
        // Pass 2: Draw the line on top of original image
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, CGRectMake(0, 0, self.gridView.frame.size.width, self.gridView.frame.size.height));
        
        CGContextSetLineWidth(context, 0.5);
        
        for (int i = -70 ; i < self.gridView.frame.size.height + 50; i += 70)
        {
            if (self.grid1DifY > 0) {
                CGContextMoveToPoint(context, 0, i + (float)((int)fabs(self.grid1DifY) % 70));
                CGContextAddLineToPoint(context, self.gridView.frame.size.width, i + (float)((int)fabs(self.grid1DifY) % 70));
            }
            else {
                CGContextMoveToPoint(context, 0, i - (float)((int)fabs(self.grid1DifY) % 70));
                CGContextAddLineToPoint(context, self.gridView.frame.size.width, i - (float)((int)fabs(self.grid1DifY) % 70));
            }
            
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
            CGContextStrokePath(context);
        }
        
        for (int i = -60 ; i < self.gridView.frame.size.width + 50; i += 60)
        {
            if (self.grid1DifX > 0) {
                CGContextMoveToPoint(context, i + (float)((int)fabs(self.grid1DifX) % 60), 0);
                CGContextAddLineToPoint(context, i + (float)((int)fabs(self.grid1DifX) % 60),self.gridView.frame.size.height);
            }
            else{
                CGContextMoveToPoint(context, i - (float)((int)fabs(self.grid1DifX) % 60), 0);
                CGContextAddLineToPoint(context, i - (float)((int)fabs(self.grid1DifX) % 60),self.gridView.frame.size.height);
            }
            
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
            CGContextStrokePath(context);
        }
        
        // Create new image
        self.gridView.image = UIGraphicsGetImageFromCurrentImageContext();
        
        // Tidy up
        UIGraphicsEndImageContext();
        
    
}


- (IBAction)OnToggleCamera:(id)sender
{
    [[self captureManager] toggleCamera];
}

- (IBAction)OnGoBack:(id)sender
{
    if (_bIsRecording) {
        _vcState = VC_NEED_GOBACK;
        [[self captureManager] stopRecording];
    } else {
        [self goBack];
    }
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch1 = [touches anyObject];
    self.grid1StartPoint = [touch1 locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch1 = [touches anyObject];
    CGPoint currentPoint = [touch1 locationInView:self.view];
    
    self.grid1DifX = currentPoint.x - self.grid1StartPoint.x;
    self.grid1DifY = currentPoint.y - self.grid1StartPoint.y;
    
    [self redrawGrid:0];
    //[self redrawGrid:1];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


- (IBAction)OnToggleRecord:(id)sender
{
    if (![[[self captureManager] recorder] isRecording]) {
        if (!_bIsRecording) {
            [[self captureManager] startRecording];
        }
    } else {
        if (_bIsRecording) {
            _vcState = VC_NORMAL;
            [[self captureManager] stopRecording];
        }
    }
}

- (IBAction)OnPicker:(id)sender
{
    if (_bIsRecording) {
        _vcState = VC_NEED_PICKUP;
        [[self captureManager] stopRecording];
    } else {
        [self showVideoPicker];
    }
}

- (IBAction)OnTrash:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete the current video recording?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                               destructiveButtonTitle:@"Yes"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

@end
