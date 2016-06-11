//
//  FrameSeekScroller.h
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/28/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@class FrameSeekScroller;
@protocol FrameSeekScrollerDelegate <NSObject>
@optional
- (void)frameSeekScrollerTapped:(FrameSeekScroller *)frameSeekScroller isBackButton:(BOOL)isBackButton;
@end

@interface FrameSeekScroller : UIView
{
    iCarousel *     mScroller;
    UIButton *      mBackwardButton;
    UIButton *      mForwardButton;
}

@property(nonatomic, weak) id<FrameSeekScrollerDelegate> delegate;
@property(nonatomic, readonly) iCarousel *scroller;

- (void)setup;

+ (CGRect)frameBasedOnFrameScroller:(CGRect)frameScrollerFrame;
- (IBAction)OnBackward:(id)sender;
- (IBAction)OnForward:(id)sender;

@end
