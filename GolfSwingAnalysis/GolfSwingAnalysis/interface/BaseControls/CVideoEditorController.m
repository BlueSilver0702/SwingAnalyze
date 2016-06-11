//
//  CVideoEditorController.m
//  GolfSwingAnalysis
//
//  Created by Top1 on 10/2/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "CVideoEditorController.h"

@implementation CVideoEditorController
- (void)viewDidLoad {
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

	[super viewDidLoad];
	
}

@end
