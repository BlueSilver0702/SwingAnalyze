//
//  MediaCollectionViewCell.m
//  GolfChannel
//
//  Created by AnCheng on 3/24/15.
//  Copyright (c) 2015 ancheng1114. All rights reserved.
//

#import "MediaCollectionViewCell.h"

@implementation MediaCollectionViewCell

- (void)setImageUrl:(NSString *)url share:(BOOL)byCademy
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager.imageDownloader setValue:[AppSetttings userToken] forHTTPHeaderField:@"Authorization"];
    [manager downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:MEDIATHUMB_LINK , MAIN_DOMAIN,url]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
        
        if (!error)
            self.imageView.image = image;
        else
            self.imageView.image = [UIImage imageNamed:@"place_holder"];
    }];
    
    if (byCademy)
        _watermarkImageView.hidden = NO;
    else
        _watermarkImageView.hidden = YES;
}

@end
