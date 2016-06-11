//
//  MediaListViewController.h
//  GolfChannel
//
//  Created by AnCheng on 3/23/15.
//  Copyright (c) 2015 ancheng1114. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout ,UIActionSheetDelegate ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate>
{
    BOOL isRefresh;
}

@property (nonatomic ,assign) IBOutlet UICollectionView *mediaCollectionView;
@property (nonatomic ,strong) NSMutableArray *mediaArr;

@property (nonatomic ,assign) IBOutlet UIBarButtonItem *addItem;
@property (nonatomic ,strong) NSIndexPath *selectedIndexPath;

@property (nonatomic ,assign) IBOutlet NSLayoutConstraint *bottomHeight;
@property (nonatomic ,weak) UIViewController *parent;

@end
