//
//  CommentViewController.m
//  GolfSwingAnalysis
//
//  Created by Top1 on 8/30/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "CommentViewController.h"
#import "VideoManager.h"
#import "VideoTabItemViewController.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

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
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
	
    [super viewDidLoad];

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

	}
	
	// Do any additional setup after loading the view.
    NSString *videoComment = self.entity.detail;
    _commentView.text = videoComment;
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

#pragma mark - User Action
- (IBAction)OnDone:(id)sender
{
    NSString *videoComment = _commentView.text;
    [[VideoManager sharedManager] updateComment:self.entity comment:videoComment];
    [(VideoTabItemViewController *)[self parent] onRefreshVideoList];
    [self.parent dismissViewControllerAnimated:YES completion:nil];
}
@end
