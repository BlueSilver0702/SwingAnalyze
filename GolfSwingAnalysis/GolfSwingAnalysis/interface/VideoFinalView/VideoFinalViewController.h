//
//  VideoFinalViewController.h
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/30/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <MediaPlayer/MediaPlayer.h>

@interface VideoFinalViewController : UIViewController
{
    MPMoviePlayerController * mPlayer;
	
	IBOutlet UIImageView *		_topBarImageView;
	IBOutlet UIButton *			_doneButton;
}

@property(nonatomic, weak) UIViewController *parent;
@property(nonatomic, strong) NSString *moviePath;

- (IBAction)OnBack:(id)sender;
@end
