//
//  MediaCollectionViewCell.h
//  GolfChannel
//
//  Created by AnCheng on 3/24/15.
//  Copyright (c) 2015 ancheng1114. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaCollectionViewCell : UICollectionViewCell

@property (nonatomic ,assign) IBOutlet UIImageView *imageView;
@property (nonatomic ,assign) IBOutlet UIImageView *watermarkImageView;

- (void)setImageUrl:(NSString *)url share:(BOOL)byCademy;

@end
