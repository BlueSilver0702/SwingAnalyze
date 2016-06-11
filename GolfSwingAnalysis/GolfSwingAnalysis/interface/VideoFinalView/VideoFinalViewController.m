//
//  VideoFinalViewController.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/30/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "VideoFinalViewController.h"

@interface VideoFinalViewController ()

@end

@implementation VideoFinalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.moviePath = @"";
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [mPlayer.view removeFromSuperview];
}

- (void)viewDidLoad
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
	
    [super viewDidLoad];
	
	CGFloat topBarHeight = 44;
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		;
	} else {
		CGRect frame;
		
		frame = _topBarImageView.frame;
		frame.origin.y += 20;
		_topBarImageView.frame = frame;
		
		frame = _doneButton.frame;
		frame.origin.y += 20;
		_doneButton.frame = frame;
		
		topBarHeight += 20;
	}
	
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onExitFullScreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    
    mPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.moviePath]];
    
    [mPlayer.view setFrame:CGRectMake(0, topBarHeight, self.view.frame.size.width, self.view.frame.size.height - topBarHeight)];
    mPlayer.controlStyle = MPMovieControlStyleEmbedded;
    mPlayer.movieSourceType = MPMovieSourceTypeFile;
    mPlayer.repeatMode = MPMovieRepeatModeOne;
    [mPlayer prepareToPlay];
    
    [self.view addSubview: mPlayer.view];
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

#pragma mark - User Interface
- (void)onExitFullScreen:(id)sender
{
    [mPlayer setFullscreen:NO animated:YES];
}

- (IBAction)OnBack:(id)sender
{
    [mPlayer stop];
    [self.parent dismissViewControllerAnimated:YES completion:nil];
}

@end
