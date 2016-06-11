//
//  VideoTableCell.h
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"

@class VideoTableCell;
@protocol VideoTableCellDelegate <NSObject>
@optional
- (void)onPlay:(VideoTableCell *)aCell index:(int)index;

- (void)onShare:(VideoTableCell *)aCell index:(int)index;
- (void)onComment:(VideoTableCell *)aCell index:(int)index;
- (void)onExtraAction:(VideoTableCell *)aCell index:(int)index;

@end


@interface VideoTableCell : UITableViewCell <SwipeViewDataSource ,SwipeViewDelegate>

@property (nonatomic, assign) IBOutlet UIView *          thumbWrapView;
@property (nonatomic, assign) IBOutlet UIImageView *     thumbView;
@property (nonatomic, assign) IBOutlet UILabel *         creationDateLbl;
@property (nonatomic, assign) IBOutlet UILabel *         creationTimeLbl;
@property (nonatomic, assign) IBOutlet UIButton *        playBtn;
@property (nonatomic, assign) id<VideoTableCellDelegate> delegate;
@property (nonatomic, assign) IBOutlet UILabel *         commentLabel;
@property (nonatomic, assign) IBOutlet UILabel *         tagLabel;
@property (nonatomic ,assign) IBOutlet SwipeView *sharedView;

@property (nonatomic ,strong) VideoEntity *entity;

@property (nonatomic ,assign) IBOutlet UIButton *shareBtn;
@property (nonatomic ,assign) IBOutlet UIButton *settingBtn;
@property (nonatomic ,assign) IBOutlet UILabel *extraLbl;

@property (nonatomic) IBOutlet NSLayoutConstraint *swipeHeightConstraint;

@property (nonatomic ,strong) NSArray *sharedArr;

@property (nonatomic) int index;

- (IBAction)OnPlay:(id)sender;
- (IBAction)OnShare:(id)sender;
- (IBAction)OnComment:(id)sender;
- (IBAction)OnExtraAction:(id)sender;
- (void)setEntity:(VideoEntity *)entity;

@end
