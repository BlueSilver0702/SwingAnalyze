//
//  DrawBoardView.m
//  DrawTest
//
//  Created by xiangmi on 5/25/13.
//  Copyright (c) 2013 xiangmi. All rights reserved.
//

#import "DrawBoardView.h"
#include "CGUtils.h"
#import "Circle.h"
#import "Line.h"
#import "Angle.h"
#import "FreeDraw.h"

#define kLineWidth          2.0f

@implementation DrawBoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)dealloc
{
    [mCtrlLayer removeFromSuperlayer];
    [mShapeList removeAllObjects];
}

- (void)initialize
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    
    mShapeList = [[NSMutableArray alloc] init];
    
    mFirstPt = mLastPt = CGPointZero;
    mCandShape = mTempShape = nil;
    
    mShapeType = 0;
    mEditMode = EDIT_MODE_NONE;
    mTempIsCandi = NO;
    mIsDeletable = NO;
    
    [self setShapeColor:DRAWING_COLOR_RED];
    [self setShapeType:DRAWING_TOOL_CIRCLE];
}

- (void)setupCtrlLayer:(id)delegate
{
    mCtrlLayer = [[CALayer alloc] init];
    mCtrlLayer.frame = self.frame;
    mCtrlLayer.backgroundColor = [UIColor clearColor].CGColor;
    mCtrlLayer.delegate = delegate;
    [self.layer addSublayer:mCtrlLayer];
    
    [mCtrlLayer setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawShapesOnBoard:context];
    if (!mCtrlLayer)
        [self drawShapeCtrlsOnBoard:context];
}

#pragma mark - Draw
- (void)setNeedsDisplay
{
    [mCtrlLayer setNeedsDisplay];
    [super setNeedsDisplay];
}

- (void)drawDeletableMark:(CGContextRef)context atPoint:(CGPoint)pt
{
	CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGFloat halfRadius = kCtrlPtRadius * 1.5 / 2.0f;
    
    CGContextAddArc(context, pt.x, pt.y, kCtrlPtRadius * 1.5, 0.0f, M_PI * 2.0f, 0);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextMoveToPoint(context, pt.x - halfRadius, pt.y - halfRadius);
    CGContextAddLineToPoint(context, pt.x + halfRadius, pt.y + halfRadius);
    
    CGContextMoveToPoint(context, pt.x - halfRadius, pt.y + halfRadius);
    CGContextAddLineToPoint(context, pt.x + halfRadius, pt.y - halfRadius);
    
    CGContextStrokePath(context);
}

- (void)drawCircleCtrl:(CGContextRef)context withCircle:(Circle *)aCircle
{
	CGContextSetStrokeColorWithColor(context, aCircle.shapeColor.CGColor);
    
    if (mIsDeletable)
    {
        [self drawDeletableMark:context atPoint:aCircle.centerPt];
    } else {
        if (aCircle.isCandi)
        {
            CGContextAddArc(context, aCircle.centerPt.x, aCircle.centerPt.y, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            CGContextAddArc(context, aCircle.centerPt.x, aCircle.centerPt.y + aCircle.radius, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

- (void)drawCircle:(CGContextRef)context withCircle:(Circle *)aCircle
{
	CGContextSetStrokeColorWithColor(context, aCircle.shapeColor.CGColor);
    
    CGContextAddArc(context, aCircle.centerPt.x, aCircle.centerPt.y, aCircle.radius, 0.0f, M_PI * 2.0f, 0);
    CGContextStrokePath(context);
}

- (void)drawLineCtrl:(CGContextRef)context withLine:(Line *)aLine
{
	CGContextSetStrokeColorWithColor(context, aLine.shapeColor.CGColor);
    
    if (mIsDeletable)
    {
        [self drawDeletableMark:context atPoint:aLine.startPt];
    } else {
        if (aLine.isCandi)
        {
            CGContextAddArc(context, aLine.startPt.x, aLine.startPt.y, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            CGContextAddArc(context, aLine.endPt.x, aLine.endPt.y, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

- (void)drawLine:(CGContextRef)context withLine:(Line *)aLine
{
	CGContextSetStrokeColorWithColor(context, aLine.shapeColor.CGColor);
    
    CGContextMoveToPoint(context, aLine.startPt.x, aLine.startPt.y);
    CGContextAddLineToPoint(context, aLine.endPt.x, aLine.endPt.y);
    CGContextStrokePath(context);    
}

- (void)drawText:(CGContextRef)context atPosition:(CGPoint)pt withString:(NSString *)strText withColor:(UIColor *)textColor
{
	CGContextSetStrokeColorWithColor(context, textColor.CGColor);
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
    [strText drawAtPoint:pt withFont:font];
    
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
}

- (void)drawAngleCtrl:(CGContextRef)context withAngle:(Angle *)aAngle
{
	CGContextSetStrokeColorWithColor(context, aAngle.shapeColor.CGColor);
    
    if (mIsDeletable)
    {
        [self drawDeletableMark:context atPoint:aAngle.centerPt];
    } else {
        if (aAngle.isCandi)
        {
            CGContextAddArc(context, aAngle.startPt.x, aAngle.startPt.y, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            CGContextAddArc(context, aAngle.endPt.x, aAngle.endPt.y, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            CGContextAddArc(context, aAngle.centerPt.x, aAngle.centerPt.y, kCtrlPtRadius, 0.0f, M_PI * 2.0f, 0);
            CGContextDrawPath(context, kCGPathFillStroke);
        }
    }
}

- (void)drawAngle:(CGContextRef)context withAngle:(Angle *)aAngle
{
	CGContextSetStrokeColorWithColor(context, aAngle.shapeColor.CGColor);
    
    CGContextMoveToPoint(context, aAngle.startPt.x, aAngle.startPt.y);
    CGContextAddLineToPoint(context, aAngle.centerPt.x, aAngle.centerPt.y);
    CGContextStrokePath(context);

    CGContextMoveToPoint(context, aAngle.endPt.x, aAngle.endPt.y);
    CGContextAddLineToPoint(context, aAngle.centerPt.x, aAngle.centerPt.y);
    CGContextStrokePath(context);
    
    NSString *angleString = [NSString stringWithFormat:@"%d.%d˚", aAngle.valueMul10 / 10,  aAngle.valueMul10 % 10];
    [self drawText:context atPosition:CGPointMake(aAngle.centerPt.x + 20 ,aAngle.centerPt.y - 10.0f) withString:angleString withColor:aAngle.shapeColor];
}

- (void)drawFreeDrawCtrl:(CGContextRef)context withFreeDraw:(FreeDraw *)aFreedraw
{
	CGContextSetStrokeColorWithColor(context, aFreedraw.shapeColor.CGColor);
    
    if (mIsDeletable)
    {
        CGPoint pt = [aFreedraw pointAtIndex:0];
        [self drawDeletableMark:context atPoint:pt];
    }
}

- (void)drawFreeDraw:(CGContextRef)context withFreeDraw:(FreeDraw *)aFreedraw
{
    int pointCount = [aFreedraw pointCount];
    if (pointCount < 2)
        return;
    
	CGContextSetStrokeColorWithColor(context, aFreedraw.shapeColor.CGColor);
    
    CGPoint pt = [aFreedraw pointAtIndex:0];
    CGContextMoveToPoint(context, pt.x, pt.y);
    for (int i = 1; i < pointCount; i++)
    {
        pt = [aFreedraw pointAtIndex:i];
        CGContextAddLineToPoint(context, pt.x, pt.y);
    }
    CGContextStrokePath(context);
}

- (void)drawShape:(CGContextRef)context withShape:(Shape *)aShape
{
    if (!aShape)
        return;
    
    switch (aShape.shapeType) {
        case DRAWING_TOOL_CIRCLE:
            [self drawCircle:context withCircle:(Circle *)aShape];
            break;
        case DRAWING_TOOL_LINE:
            [self drawLine:context withLine:(Line *)aShape];
            break;
        case DRAWING_TOOL_ANGLE:
            [self drawAngle:context withAngle:(Angle *)aShape];
            break;
        case DRAWING_TOOL_FREEDRAW:
            [self drawFreeDraw:context withFreeDraw:(FreeDraw *)aShape];
            break;
        default:
            break;
    }
}

- (void)drawShapeCtrl:(CGContextRef)context withShape:(Shape *)aShape
{
    if (!aShape)
        return;
    
    switch (aShape.shapeType) {
        case DRAWING_TOOL_CIRCLE:
            [self drawCircleCtrl:context withCircle:(Circle *)aShape];
            break;
        case DRAWING_TOOL_LINE:
            [self drawLineCtrl:context withLine:(Line *)aShape];
            break;
        case DRAWING_TOOL_ANGLE:
            [self drawAngleCtrl:context withAngle:(Angle *)aShape];
            break;
        case DRAWING_TOOL_FREEDRAW:
            [self drawFreeDrawCtrl:context withFreeDraw:(FreeDraw *)aShape];
            break;
        default:
            break;
    }
}

- (void)drawShapesOnBoard:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(context, kLineWidth);
    
    int shapeCount = (int)[mShapeList count];
    for (int i = 0; i < shapeCount; i++)
    {
        Shape *aShape = (Shape *)[mShapeList objectAtIndex:i];
        [self drawShape:context withShape:aShape];
    }
    
    [self drawShape:context withShape:mTempShape];
    [self drawShape:context withShape:mCandShape];
    
    CGContextRestoreGState(context);
}

- (void)drawShapeCtrlsOnBoard:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(context, kLineWidth);
    
    int shapeCount = (int)[mShapeList count];
    for (int i = 0; i < shapeCount; i++)
    {
        Shape *aShape = (Shape *)[mShapeList objectAtIndex:i];
        [self drawShapeCtrl:context withShape:aShape];
    }
    
    [self drawShapeCtrl:context withShape:mTempShape];
    [self drawShapeCtrl:context withShape:mCandShape];
    
    CGContextRestoreGState(context);
}

- (void)selectNewCandiShape:(CGPoint)tapPt
{
    //Check Which is Selected
    if (mEditMode == EDIT_MODE_NONE)
    {
        Shape *mNearestShape = nil;
        float minDistance = FLT_MAX - 1;
        
        int shapeCount = (int)[mShapeList count];
        for (int i = 0; i < shapeCount; i++)
        {
            Shape *aShape = (Shape *)[mShapeList objectAtIndex:i];
            CGFloat distance = [aShape distanceFromPt:tapPt];
            
            if (distance < minDistance)
            {
                minDistance = distance;
                mNearestShape = aShape;
            }
        }
        
        if (mNearestShape)
        {
            mNearestShape.isCandi = YES;
            mCandShape = mNearestShape;
            
            [mShapeList removeObject:mNearestShape];
            
            mShapeType = mCandShape.shapeType;
            
            
            NSLog(@"%@", NSStringFromClass([mCandShape class]));
            
            if ([self.delegate respondsToSelector:@selector(drawBoardViewPropertyChanged:withInfo:)])
            {
                NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
                [infoDic setObject:[NSNumber numberWithInt:mCandShape.shapeColorType] forKey:kDrawingColorKey];
                [infoDic setObject:[NSNumber numberWithInt:mCandShape.shapeType] forKey:kDrawingShapeKey];
                
                [self.delegate drawBoardViewPropertyChanged:self withInfo:infoDic];
            }
        }
    }
}

- (void)selectDeletableCandiShape:(CGPoint)tapPt
{
    //Check Which is Selected
    if (mIsDeletable)
    {
        Shape *mNearestShape = nil;
        
        int shapeCount = (int)[mShapeList count];
        for (int i = 0; i < shapeCount; i++)
        {
            Shape *aShape = (Shape *)[mShapeList objectAtIndex:i];
            if ([aShape IsTappedDeleteCtrlPt:tapPt])
            {
                mNearestShape = aShape;
            }
        }
        
        if (mNearestShape)
        {
            mNearestShape.isCandi = YES;
            mTempShape = mNearestShape;
        }
    }
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
    if ([touch tapCount] > 1)
    {
        return;
    }
    
	mFirstPt = [touch locationInView:self];
	mLastPt = [touch locationInView:self];
    
    if (mIsDeletable)
    {
        [self selectDeletableCandiShape:mFirstPt];
        return;
    }
    
    mEditMode = EDIT_MODE_NONE;
    mTempIsCandi = NO;
    
    if (mCandShape)
    {
        switch (mCandShape.shapeType) {
            case DRAWING_TOOL_CIRCLE:
            {
                Circle *aCircle = (Circle *)mCandShape;
                
                CGPoint centerPt = aCircle.centerPt;
                CGPoint bottomPt = CGPointMake(centerPt.x, centerPt.y + aCircle.radius);
                
                if (isEqualPoint(bottomPt, mFirstPt, kCtrlPtRadius + kLineWidth))
                {
                    mEditMode = EDIT_MODE_END_PT;
                } else if (isEqualPoint(centerPt, mFirstPt, kCtrlPtRadius + kLineWidth)) {
                    mEditMode = EDIT_MODE_CENTER_PT;
                }
            }
                break;
                
            case DRAWING_TOOL_LINE:
            {
                Line *aLine = (Line *)mCandShape;
                
                if (isEqualPoint(aLine.endPt, mFirstPt, kCtrlPtRadius + kLineWidth))
                {
                    mEditMode = EDIT_MODE_END_PT;
                } else if (isEqualPoint(aLine.startPt, mFirstPt, kCtrlPtRadius + kLineWidth)) {
                    mEditMode = EDIT_MODE_START_PT;
                }
            }
                break;
                
            case DRAWING_TOOL_ANGLE:
            {
                Angle *aAngle = (Angle *)mCandShape;
                
                if (isEqualPoint(aAngle.centerPt, mFirstPt, kCtrlPtRadius + kLineWidth))
                {
                    mEditMode = EDIT_MODE_CENTER_PT;
                } else if (isEqualPoint(aAngle.endPt, mFirstPt, kCtrlPtRadius + kLineWidth)) {
                    mEditMode = EDIT_MODE_END_PT;
                } else if (isEqualPoint(aAngle.startPt, mFirstPt, kCtrlPtRadius + kLineWidth)) {
                    mEditMode = EDIT_MODE_START_PT;
                }
            }
                break;
                
            case DRAWING_TOOL_FREEDRAW:
            {
                ;
            }
                break;
                
            default:
                break;
        }
    }
    
    if (mEditMode == EDIT_MODE_NONE)
    {
        switch (mShapeType) {
            case DRAWING_TOOL_CIRCLE:
                mTempShape = [[Circle alloc] init];
                [(Circle *)mTempShape setCenterPt:mFirstPt];
                break;
            case DRAWING_TOOL_LINE:
                mTempShape = [[Line alloc] init];
                [(Line *)mTempShape setStartPt:mFirstPt];
                [(Line *)mTempShape setEndPt:mFirstPt];
                break;
            case DRAWING_TOOL_ANGLE:
                mTempShape = [[Angle alloc] init];
                [(Angle *)mTempShape setStartPt:CGPointMake(mFirstPt.x, mFirstPt.y - 1.0f)];
                [(Angle *)mTempShape setCenterPt:mFirstPt];
                [(Angle *)mTempShape setEndPt:CGPointMake(mFirstPt.x + 50.0f, mFirstPt.y + 50.0f)];
                [(Angle *)mTempShape calcValue];
                break;
            case DRAWING_TOOL_FREEDRAW:
                mTempShape = [[FreeDraw alloc] init];
                [(FreeDraw *)mTempShape addPoint:mFirstPt];
                [(FreeDraw *)mTempShape addPoint:mFirstPt];
                break;
            default:
                break;
        }
        
        mTempShape.shapeColorType = mShapeColorType;
        mTempShape.shapeColor = mShapeColor;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	mLastPt = [touch locationInView:self];

    if (mIsDeletable)
    {
        return;
    }
    
    if (mEditMode == EDIT_MODE_NONE)
    {
        if (mCandShape && !isEqualPoint(mFirstPt, mLastPt, kCtrlPtRadius + kLineWidth))
        {
            mTempIsCandi = YES;//(mTempShape.shapeType != DRAWING_TOOL_FREEDRAW) ? YES : NO;
            mCandShape = nil;
        }
        
        if (mTempShape) {
            switch (mTempShape.shapeType) {
                case DRAWING_TOOL_CIRCLE:
                {
                    CGFloat distance = distanceBetween2Points(mFirstPt, mLastPt);
                    [(Circle *)mTempShape setRadius:distance];
                }
                    break;
                case DRAWING_TOOL_LINE:
                {
                    [(Line *)mTempShape setEndPt:mLastPt];
                }
                    break;
                case DRAWING_TOOL_ANGLE:
                {
                    [(Angle *)mTempShape setCenterPt:mLastPt];
                    [(Angle *)mTempShape calcValue];
                }
                    break;
                case DRAWING_TOOL_FREEDRAW:
                {
                    [(FreeDraw *)mTempShape addPoint:mLastPt];
                }
                    break;
                default:
                    break;
            }
        }
    } else {
        switch (mCandShape.shapeType) {
            case DRAWING_TOOL_CIRCLE:
            {
                Circle *aCircle = (Circle *)mCandShape;
                if (mEditMode == EDIT_MODE_CENTER_PT)
                {
                    [aCircle setCenterPt:mLastPt];
                } else {
                    CGFloat distance = distanceBetween2Points(aCircle.centerPt, mLastPt);
                    [aCircle setRadius:distance];
                }
            }
                break;
                
            case DRAWING_TOOL_LINE:
            {
                Line *aLine = (Line *)mCandShape;
                if (mEditMode == EDIT_MODE_START_PT)
                {
                    [aLine setStartPt:mLastPt];
                } else if (mEditMode == EDIT_MODE_END_PT) {
                    [aLine setEndPt:mLastPt];
                }
            }
                break;
                
            case DRAWING_TOOL_ANGLE:
            {
                Angle *aAngle = (Angle *)mCandShape;
                if (mEditMode == EDIT_MODE_START_PT)
                {
                    [aAngle setStartPt:mLastPt];
                } else if (mEditMode == EDIT_MODE_END_PT) {
                    [aAngle setEndPt:mLastPt];
                } else if (mEditMode == EDIT_MODE_CENTER_PT) {
                    [aAngle setCenterPt:mLastPt];
                }
                [aAngle calcValue];
            }
                break;
            default:
                break;
        }
    }
    
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	mLastPt = [touch locationInView:self];

    if (mIsDeletable)
    {
        if (mTempShape && [mTempShape IsTappedDeleteCtrlPt:mLastPt])
        {
            [mShapeList removeObject:mTempShape];
        }

        mTempShape = nil;
        
        [self setNeedsDisplay];
        return;
    }
    
    if (mEditMode == EDIT_MODE_NONE)
    {
        if (mCandShape) {
            mCandShape.isCandi = NO;
            [mShapeList addObject:mCandShape];
            mCandShape = nil;
            
        } else if (mTempShape) {
            if (isEqualPoint(mFirstPt, mLastPt, 1.0f))
            {
                [self selectNewCandiShape:mLastPt];
            } else {
                switch (mTempShape.shapeType) {
                    case DRAWING_TOOL_CIRCLE:
                    {
                        CGFloat distance = distanceBetween2Points(mFirstPt, mLastPt);
                        [(Circle *)mTempShape setRadius:distance];
                    }
                        break;
                        
                    case DRAWING_TOOL_LINE:
                    {
                        [(Line *)mTempShape setEndPt:mLastPt];
                    }
                        break;
                        
                    case DRAWING_TOOL_ANGLE:
                    {
                        [(Angle *)mTempShape setCenterPt:mLastPt];
                        [(Angle *)mTempShape calcValue];
                    }
                        break;
                    case DRAWING_TOOL_FREEDRAW:
                    {
                        [(FreeDraw *)mTempShape addPoint:mLastPt];
                    }
                        break;
                    default:
                        break;
                }
                
                if (YES || mTempIsCandi)
                {
                    mCandShape = mTempShape;
                } else {
                    mTempShape.isCandi = NO;
                    [mShapeList addObject:mTempShape];
                }
            }
        }
        
        mTempShape = nil;
    } else {
//        switch (mCandShape.shapeType) {
//            case DRAWING_TOOL_CIRCLE:
//            {
//                Circle *aCircle = (Circle *)mCandShape;
//                if (mEditMode == EDIT_MODE_CENTER_PT)
//                {
//                    [aCircle setCenterPt:mLastPt];
//                } else {
//                    CGFloat distance = distanceBetween2Points(aCircle.centerPt, mLastPt);
//                    [aCircle setRadius:distance];
//                }
//            }
//                break;
//                
//            default:
//                break;
//        }
    }
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self touchesEnded:touches withEvent:event];
    
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Interface
- (void)clearBoard
{
    [mShapeList removeAllObjects];
    mCandShape = nil;
    mTempShape = nil;
    
    mIsDeletable = NO;
   
    [self setNeedsDisplay];
}

- (void)toggleDeletable
{
    mIsDeletable = !mIsDeletable;
    if (mIsDeletable)
    {
        if (mCandShape) {
            mCandShape.isCandi = NO;
            [mShapeList addObject:mCandShape];
            mCandShape = nil;
        }
    } else {
        ;
    }

    [self setNeedsDisplay];
}

- (void)finishDraw
{
    if (mCandShape) {
        mCandShape.isCandi = NO;
        [mShapeList addObject:mCandShape];
        mCandShape = nil;
    }
    
    [self setNeedsDisplay];
}

- (BOOL)isDeletable
{
    return mIsDeletable;
}

- (void)setShapeType:(DRAWING_TOOL)shapeType
{
    mShapeType = shapeType;
    if (mCandShape) {
        mCandShape.isCandi = NO;
        [mShapeList addObject:mCandShape];
        mCandShape = nil;
        
    }
    
    [self setNeedsDisplay];
}

- (void)setShapeColor:(DRAWING_COLOR)shapeColor
{
    switch (shapeColor) {
        case DRAWING_COLOR_RED:
            mShapeColor = [UIColor redColor];
            break;
            
        case DRAWING_COLOR_WHITE:
            mShapeColor = [UIColor whiteColor];
            break;
            
        case DRAWING_COLOR_YELLOW:
            mShapeColor = [UIColor yellowColor];
            break;

        default:
            break;
    }
    
    mShapeColorType = shapeColor;
}

@end
