//
//  MSTraditionalDrawingCell.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSTraditionalDrawingCell.h"

#import "MSCustomDrawnView.h"

@interface MSTraditionalDrawingCell ()

@end

@implementation MSTraditionalDrawingCell

@synthesize circleColors = _circleColors;

- (void)setCircleColors:(NSArray *)circleColors
{
    if (circleColors != _circleColors)
    {
        _circleColors = circleColors;

        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (UIColor *)backgroundColor
{
    return kBackgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);
    {
        CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
        CGContextFillRect(ctx, rect);
    }
    CGContextRestoreGState(ctx);

    const CGFloat widthPerView = rect.size.width / (CGFloat)kViewsPerRow;
    const CGFloat viewHeight = rect.size.height;

    CGFloat currentX = 0.0f;

    for (UIColor *circleColor in self.circleColors)
    {
        CGRect frame = CGRectIntegral(CGRectMake(currentX,
                                                 0.0f,
                                                 widthPerView,
                                                 viewHeight));
        MSCustomDrawnView *view = [[MSCustomDrawnView alloc] initWithFrame:frame
                                                               circleColor:circleColor];
        [view drawRect:frame];

        currentX += widthPerView;
    }
}

@end
