//
//  BaseTabBarController.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "BaseTabBarController.h"
#import "VideoRecordViewController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addCenterButtonWithImage:[UIImage imageNamed:IS_IPAD ? @"recordTabUp_iPhone.png" : @"recordTabUp_iPhone.png"]
                    highlightImage:[UIImage imageNamed:IS_IPAD ? @"recordTabDown_iPhone.png" : @"recordTabDown_iPhone.png"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Main2VideoRecord"])
    {
        VideoRecordViewController *vc = (VideoRecordViewController *)[segue destinationViewController];
        vc.parent = self;
    }
}

#pragma mark - Add Center Button
- (void)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    UITabBar *tabBar = self.tabBar;
    CGFloat heightDifference = buttonImage.size.height - tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = tabBar.center;
    else
    {
        CGPoint center = tabBar.center;
        center.y = center.y - heightDifference/2.0 - 5.0f;
        button.center = center;
    }
    
    [self.view addSubview:button];
    [button addTarget:self action:@selector(OnRecord:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)OnRecord:(id)sender
{
    [self performSegueWithIdentifier:@"Main2VideoRecord" sender:nil];
//    [self setSelectedIndex:2];
}

@end
