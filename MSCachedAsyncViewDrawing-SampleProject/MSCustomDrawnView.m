//
//  MSCustomDrawnView.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSCustomDrawnView.h"

#define kStrokeColor [UIColor whiteColor]
#define kStrokeWidth 2.0f

#define kShadowHeight 1.0f

@implementation MSCustomDrawnView

@synthesize circleColor = _circleColor;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
                   circleColor:nil];
}

- (id)initWithFrame:(CGRect)frame
        circleColor:(UIColor *)circleColor
{
    NSParameterAssert(circleColor);

    if ((self = [super initWithFrame:frame]))
    {
        self.circleColor = circleColor;

        self.contentMode = UIViewContentModeRedraw;
    }

    return self;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    @synchronized(self)
    {
        if (circleColor != _circleColor)
        {
            _circleColor = circleColor;

            [self setNeedsDisplay];
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = frame.size.height;

    [super setFrame:frame];
}

- (UIColor *)circleColor
{
    @synchronized(self)
    {
        return _circleColor;
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    UIColor *circleColor = self.circleColor;

    CGRect circleFrame = CGRectIntegral(CGRectInset(rect, kStrokeWidth + kShadowHeight, kStrokeWidth + kShadowHeight));
    CGPathRef circlePath = CGPathCreateWithEllipseInRect(circleFrame, NULL);

    CGContextAddPath(ctx, circlePath);

    CGContextSaveGState(ctx);
    {
        CGContextClip(ctx);
        CGContextAddPath(ctx, circlePath);

        // Background
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, circleColor.CGColor);
            CGContextFillPath(ctx);
        }
        CGContextRestoreGState(ctx);

        CGContextSaveGState(ctx);
        {
            // Draw icon
            UIImage *mindsnacksLogoImage = [UIImage imageNamed:@"mindsnacks_logo"];

            CGSize imageSize = mindsnacksLogoImage.size;

            CGFloat imageRectWidth = (circleFrame.size.width * 0.9f);

            CGRect imageFrame = CGRectZero;
            imageFrame.size.width = imageRectWidth;
            imageFrame.size.height = (imageRectWidth / imageSize.width) * imageSize.height;
            imageFrame.origin.x = circleFrame.origin.x + (circleFrame.size.width - imageFrame.size.width) / 2.0f;
            imageFrame.origin.y = circleFrame.origin.y + (circleFrame.size.height - imageFrame.size.height) / 2.0f;

            [mindsnacksLogoImage drawInRect:imageFrame];
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);

    // Stroke + shadow
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, circlePath);

        CGContextSetStrokeColorWithColor(ctx, kStrokeColor.CGColor);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, kShadowHeight), 0.0f, [UIColor colorWithWhite:0.0 alpha:0.6f].CGColor);

        CGContextSetLineWidth(ctx, kStrokeWidth);

        CGContextStrokePath(ctx);
    }
    
    CGPathRelease(circlePath);

    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    [@"test" drawInRect:rect withFont:[UIFont systemFontOfSize:15.0f]];
}

@end
