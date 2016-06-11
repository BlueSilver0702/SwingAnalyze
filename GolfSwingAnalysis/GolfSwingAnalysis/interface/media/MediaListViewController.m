//
//  MediaListViewController.m
//  GolfChannel
//
//  Created by AnCheng on 3/23/15.
//  Copyright (c) 2015 ancheng1114. All rights reserved.
//

#import "MediaListViewController.h"
#import "MediaCollectionViewCell.h"
#import "SwingViewController.h"
#import "NSDictionary+LinqExtensions.h"
#import "NSArray+LinqExtensions.h"
#import "MediaItem.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MediaListViewController ()

@end

@implementation MediaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = NO;
    _mediaArr = [NSMutableArray new];
    [self getMedia];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:_mediaCollectionView name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

#pragma mark - Auto Rotatation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}

- (void)getMedia
{
    JGProgressHUD *HUD = [CommonFunc showImmediateHud];
    [HUD showInView:self.navigationController.view];
    [[APIService sharedManager] getMedia:[AppSetttings userAcademyId] onCompletion:^(NSDictionary *object ,NSError *error){

        [HUD dismiss];
        if (error)
        {
            [CommonFunc showAlert:ERROR description:error.localizedDescription];
        }
        else if ([object isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *tempArr = [NSMutableArray new];
            [_mediaArr removeAllObjects];
            for (NSString *key in [object allKeys])
            {
                NSDictionary *dic = [object objectForKey:key];
                if ([dic[@"type"] isEqualToString:@"video"])
                {
                    MediaItem *item = [[MediaItem alloc] initDic:dic];
                    [tempArr addObject:item];
                }

            }
            
            // sort by created_at
            [_mediaArr addObjectsFromArray:[[tempArr linq_sort:^id(MediaItem *media) {
                return [media created_at];
            }] linq_reverse]];
            
            [self.mediaCollectionView reloadData];
            
        }
        
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{


}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mediaCell" forIndexPath:indexPath];
    MediaItem *item = [self.mediaArr objectAtIndex:indexPath.row];
    [cell setImageUrl:item.id share:item.viewable_by_academy];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    MediaItem *item = [self.mediaArr objectAtIndex:indexPath.row];
    NSString *mediaUrl = [NSString stringWithFormat:@"%@%@" ,AMAZON_VIDEO_LINK ,item.web_filename];
    NSURL *videoURL = [NSURL URLWithString:mediaUrl];
    MPMoviePlayerViewController* moviePlayer=[[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayer.moviePlayer prepareToPlay];
    [moviePlayer.moviePlayer play];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake((collectionView.bounds.size.width - 6) / 3, (collectionView.bounds.size.width - 6) / 3);
    if (IS_IPAD) size = CGSizeMake((collectionView.bounds.size.width - 6) / 4, (collectionView.bounds.size.width - 6) / 4);
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320, 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(320, 1);
}

@end
