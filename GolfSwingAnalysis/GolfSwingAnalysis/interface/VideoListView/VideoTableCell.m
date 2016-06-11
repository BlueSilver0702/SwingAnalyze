//
//  VideoTableCell.m
//  GolfSwingAnalysis
//
//  Created by Zhemin Yin on 5/7/13.
//  Copyright (c) 2013 Zhemin Yin. All rights reserved.
//

#import "VideoTableCell.h"
#import "M13Checkbox.h"
#import "FSManager.h"
#import "VideoManager.h"

@implementation VideoTableCell

@synthesize thumbWrapView;
@synthesize thumbView;
@synthesize creationDateLbl;
@synthesize playBtn;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    //Changes done directly here, we have an object
    
    [self.extraLbl setFont:[UIFont fontWithName:@"MaterialIcons-Regular" size:25.0f]];
    self.extraLbl.text = @"\ue5d3";
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"\U0000e8b8 Setting"];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"MaterialIcons-Regular" size:20.0f]
                   range:NSMakeRange(0,1)]; // The first character
    [string addAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"9e9e9e"] } range:NSMakeRange(0, 9)];
    [string addAttribute:NSBaselineOffsetAttributeName
                    value:[NSNumber numberWithFloat:-4.0]  //adjust this number till text appears to be centered
                    range:NSMakeRange(0, 1)];
    [self.settingBtn setAttributedTitle:string forState:UIControlStateNormal];
    
    NSMutableAttributedString *astring = [[NSMutableAttributedString alloc] initWithString:@"\U0000e80d Share"];
    [astring addAttribute:NSFontAttributeName
                    value:[UIFont fontWithName:@"MaterialIcons-Regular" size:20.0f]
                    range:NSMakeRange(0,1)]; // The first character
    [astring addAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"9e9e9e"] } range:NSMakeRange(0, 7)];
    [astring addAttribute:NSBaselineOffsetAttributeName
                   value:[NSNumber numberWithFloat:-4.0]  //adjust this number till text appears to be centered
                   range:NSMakeRange(0, 1)];

    [self.shareBtn setAttributedTitle:astring forState:UIControlStateNormal];

    self.thumbWrapView.layer.cornerRadius = 1.0f;
    self.thumbWrapView.layer.borderWidth = 1.0f;
    self.thumbWrapView.layer.borderColor = [UIColor blackColor].CGColor;
    
    _sharedView.delegate = self;
    _sharedView.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)OnShare:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onShare:index:)]) {
        [self.delegate onShare:self index:self.index];
    }
}

- (IBAction)OnComment:(id)sender;
{
    if ([self.delegate respondsToSelector:@selector(onComment:index:)]) {
        [self.delegate onComment:self index:self.index];
    }
}

- (IBAction)OnExtraAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onExtraAction:index:)]) {
        [self.delegate onExtraAction:self index:self.index];
    }
}

- (IBAction)OnPlay:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(onPlay:index:)]) {
        [self.delegate onPlay:self index:self.index];
    }
}

- (void)setEntity:(VideoEntity *)entity
{
    NSString *videoName = entity.videoname;
    NSString *thumbPath = [FSManager thumbFilePath:videoName];
    
    //Thumb
    self.thumbView.image = [UIImage imageWithContentsOfFile:thumbPath];
    
    //State & Top Label
    VIDEO_STATE videoState = (VIDEO_STATE)[entity.videostate intValue];
    if (videoState == VIDEO_STATE_NORMAL) {
        [self.playBtn setImage:[UIImage imageNamed:@"main_play_btn_normal.png"] forState:UIControlStateNormal];
    } else if (videoState == VIDEO_STATE_MIX) {
        [self.playBtn setImage:[UIImage imageNamed:@"main_mix_btn_normal.png"] forState:UIControlStateNormal];
    }
    
    self.creationDateLbl.text = [NSString stringWithFormat:@"Review: %@", [NewDateFormatter() stringFromDate:entity.date]];
    NSString *timeStr = [NSString stringWithFormat:@"\U0000e855 %@", [NewTimeFormatter() stringFromDate:entity.date]]; //\U0000e855
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:timeStr];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"MaterialIcons-Regular" size:10.0f]
                   range:NSMakeRange(0,1)]; // The first character
    [string addAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithHexString:@"9e9e9e"] } range:[timeStr rangeOfString:timeStr]];
    [string addAttribute:NSBaselineOffsetAttributeName
                   value:[NSNumber numberWithFloat:0.0]  //adjust this number till text appears to be centered
                   range:NSMakeRange(0, 1)];
    self.creationTimeLbl.attributedText = string;
    
    _tagLabel.text = entity.tag;
    //Shared
    if (entity.shared.length > 0)
    {
        _sharedArr = [entity.shared componentsSeparatedByString:@","];
        [_sharedView reloadData];
        _swipeHeightConstraint.constant = 36;

    }
    else
        _swipeHeightConstraint.constant = 0;

    //Comment
    NSString *comment = entity.detail;
    if ([comment length] > 0) {
        self.commentLabel.text = [NSString stringWithFormat:@"%@", comment];
        self.commentLabel.hidden = NO;
    } else {
        self.commentLabel.text = @"";
        self.commentLabel.hidden = YES;
    }

}

#pragma mark - SwipeViewDelegate, SwipeViewDataSource
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return _sharedArr.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[NSBundle mainBundle] loadNibNamed:@"SharedCell" owner:self options:nil][0];
        
    }
    
    UIImageView *avatarImageView = (UIImageView *)[view viewWithTag:1];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:[_sharedArr objectAtIndex:index]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
        
        if (finished && !error) avatarImageView.image = image;
        else avatarImageView.image = [UIImage imageNamed:@"dfm_member"];
    }];
    
    return view;
}

static inline NSDateFormatter *NewDateFormatter() {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd,yyyy"];
    return formatter;
}

static inline NSDateFormatter *NewTimeFormatter() {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    return formatter;
}

@end
