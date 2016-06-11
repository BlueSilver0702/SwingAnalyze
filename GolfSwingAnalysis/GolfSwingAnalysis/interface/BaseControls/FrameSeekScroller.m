//
//  FrameSeekScroller.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/28/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "FrameSeekScroller.h"

#define kButtonWidth 0.0f
#define kFrameWheelItemWidth 10

@implementation FrameSeekScroller

@synthesize scroller = mScroller;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //[self setup];
    }
    
    return self;
}

- (void)setup
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor lightGrayColor];
    
    mScroller = [[iCarousel alloc] init];
    [self addSubview:mScroller];
    [mScroller autoPinEdgesToSuperviewMargins];
    
}

- (void)setFrame:(CGRect)frame2
{
    [super setFrame:frame2];
    CGRect frame = self.bounds;
    
    mScroller.frame = CGRectMake(kButtonWidth, 0, frame.size.width - kButtonWidth * 2, frame.size.height);
    mBackwardButton.frame = CGRectMake(0, 0, kButtonWidth, frame.size.height);
    mForwardButton.frame = CGRectMake(frame.size.width - kButtonWidth, 0, kButtonWidth, frame.size.height);
}

#pragma mark - Interface
+ (CGRect)frameBasedOnFrameScroller:(CGRect)frameScrollerFrame
{
    return CGRectMake(frameScrollerFrame.origin.x - kButtonWidth, frameScrollerFrame.origin.y, frameScrollerFrame.size.width + kButtonWidth * 2, frameScrollerFrame.size.height);
}

- (IBAction)OnBackward:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(frameSeekScrollerTapped:isBackButton:)])
        [self.delegate frameSeekScrollerTapped:self isBackButton:YES];
}

- (IBAction)OnForward:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(frameSeekScrollerTapped:isBackButton:)])
        [self.delegate frameSeekScrollerTapped:self isBackButton:NO];
}

@end
