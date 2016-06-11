//
//  MMSeekSlider.m
//  MemoriesBuilder
//
//  Created by li taixu on 2/21/13.
//
//

#import "SeekSlider.h"

@implementation SeekSlider
{
    BOOL _isSeekingNow;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isSeekingNow = NO;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isSeekingNow = NO;
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    @synchronized(self)
    {
        _isSeekingNow = YES;
        [self.delegate seekSliderBeginTouch:self];
        
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    @synchronized(self)
    {
        _isSeekingNow = NO;
        [self.delegate seekSliderEndTouch:self];
        
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    @synchronized(self)
    {
        _isSeekingNow = NO;
        [self.delegate seekSliderEndTouch:self];
        
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    @synchronized(self)
    {
        _isSeekingNow = YES;
        [self.delegate seekSliderMovedTouch:self];
        
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)setValue:(float)value
{
    @synchronized(self)
    {
        if (!_isSeekingNow)
            [super setValue:value];
    }
}

@end
