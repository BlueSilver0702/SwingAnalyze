//
//  MMSeekSlider.h
//  MemoriesBuilder
//
//  Created by li taixu on 2/21/13.
//
//

#import <UIKit/UIKit.h>

@class SeekSlider;

@protocol SeekSliderDelegate <NSObject>
@optional
- (void)seekSliderBeginTouch:(SeekSlider *)seekSlider;
- (void)seekSliderEndTouch:(SeekSlider *)seekSlider;
- (void)seekSliderMovedTouch:(SeekSlider *)seekSlider;
@end

@interface SeekSlider : UISlider
{
}

@property(nonatomic, assign) id<SeekSliderDelegate> delegate;

@end
