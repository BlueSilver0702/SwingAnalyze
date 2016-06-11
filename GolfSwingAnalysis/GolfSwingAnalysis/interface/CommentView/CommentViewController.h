//
//  CommentViewController.h
//  GolfSwingAnalysis
//
//  Created by Top1 on 8/30/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController
{
    IBOutlet UITextView *       _commentView;
	
	IBOutlet UIImageView *		_topBarImageView;
	IBOutlet UIButton *			_doneButton;
}

@property(nonatomic, weak) UIViewController *parent;
@property (nonatomic ,strong) VideoEntity *entity;

- (IBAction)OnDone:(id)sender;
@end
