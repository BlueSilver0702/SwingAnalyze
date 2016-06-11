//
//  VideoTabItemViewController.h
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "BaseTabItemViewController.h"
#import "VideoTableCell.h"
#import "VideoRecordViewController.h"

@interface VideoTabItemViewController : BaseTabItemViewController <UITableViewDelegate,
    UITableViewDataSource, VideoTableCellDelegate, UIActionSheetDelegate, VideoRecordViewControllerDelegate,
    UINavigationControllerDelegate, UIVideoEditorControllerDelegate ,UIPopoverControllerDelegate , UIImagePickerControllerDelegate>
{
    IBOutlet UITableView *          _videoTbl;
    IBOutlet UITextView *           _instructionView;
}

@property(nonatomic ,retain) UIPopoverController *popviewCtrl;
@property (nonatomic ,strong) NSMutableArray *videoArr;

@property (nonatomic ,assign) IBOutlet UIButton *libraryBtn;
@property (nonatomic ,assign) IBOutlet UIButton *sitelibraryBtn;
@property (nonatomic ,assign) IBOutlet UIButton *recordBtn;

- (void)onRefreshVideoList;
- (void)onPlayFinalVideo:(NSString *)videoPath;

- (IBAction)OnRecord:(id)sender;
- (IBAction)onLibrary:(id)sender;
- (IBAction)onSiteLibrary:(id)sender;
- (IBAction)onSearch:(id)sender;

@end
