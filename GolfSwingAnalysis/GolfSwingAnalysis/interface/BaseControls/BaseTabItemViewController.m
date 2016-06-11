//
//  BaseTabItemViewController.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "BaseTabItemViewController.h"

@interface BaseTabItemViewController ()

@end

@implementation BaseTabItemViewController

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
    
    //Set Background Image
    if(IS_IPHONE_5)
    {
        m_iviewBG.image = [UIImage imageNamed:@"mainBackground-568h@2x.png"];
    } else if (IS_IPAD) {
        m_iviewBG.image = [UIImage imageNamed:@"mainBackground.png"];
    } else {
        m_iviewBG.image = [UIImage imageNamed:@"mainBackground.png"];
    }
    
    //Set Tabbar Background Image
    [self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabBarBackground_iPhone.png"]];
    [self.tabBarController.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"tabButtonBackgroundDown_iPhone.jpg"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
