//
//  MSAsyncDrawingCell.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSAsyncDrawingCell.h"

#import "MSCustomDrawnView.h"
#import "MSCachedAsyncViewDrawing.h"

/**
 * @discussion UIImageView is orders of magnitude faster than -[UIImage drawInRect].
 * Thanks to MSCachedAsyncViewDrawing, we can take the rendered UIImage and pass it to the UIImageView.
 */
@interface MSCustomDrawnViewImageView : UIImageView

@property (atomic, strong) UIColor *circleColor;

@end

@interface MSCustomDrawnViewImageView ()

@property (nonatomic, strong) NSOperation *imageLoadOperation;

@end

@implementation MSCustomDrawnViewImageView

@synthesize circleColor = _circleColor;

- (void)setFrame:(CGRect)frame
{
    const BOOL sizeHasChanged = !CGSizeEqualToSize(frame.size, self.frame.size);

    [super setFrame:frame];

    if (sizeHasChanged)
    {
        [self setNeedsImageReload];
    }
}

- (void)setCircleColor:(UIColor *)circleColor
{
    @synchronized(self)
    {
        if (circleColor != _circleColor)
        {
            _circleColor = circleColor;

            [self setNeedsImageReload];
        }
    }
}

- (UIColor *)circleColor
{
    @synchronized(self)
    {
        return _circleColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    const BOOL backgroundColorHasChanged = ![backgroundColor isEqual:self.backgroundColor];

    [super setBackgroundColor:backgroundColor];

    if (backgroundColorHasChanged)
    {
        [self setNeedsImageReload];
    }
}

- (void)setNeedsImageReload
{
    self.image = nil;
    [self loadImage];
}

- (void)loadImage
{
    if (CGSizeEqualToSize(self.frame.size, CGSizeZero) || !self.circleColor)
    {
        self.image = nil;

        return;
    }

    [self.imageLoadOperation cancel];

    NSString *cacheKey = [NSString stringWithFormat:@"com.mindsnacks.circle.%@.%@", self.circleColor, NSStringFromCGSize(self.frame.size)];
    self.imageLoadOperation = [[MSCachedAsyncViewDrawing sharedInstance] drawViewAsyncWithCacheKey:cacheKey
                                                                                              size:self.frame.size
                                                                                   backgroundColor:self.backgroundColor
                                                                                         drawBlock:^(CGRect frame)
                               {
                                   MSCustomDrawnView *view = [[MSCustomDrawnView alloc] initWithFrame:frame
                                                                                          circleColor:self.circleColor];

                                   [view drawRect:frame];
                               }
                                                                                   completionBlock:^(UIImage *drawnImage)
                               {
                                   self.image = drawnImage;
                               }];
}

@end

@interface MSAsyncDrawingCell ()

@property (nonatomic, strong) NSArray *imageViews;

@end

@implementation MSAsyncDrawingCell

@synthesize circleColors = _circleColors;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.contentView.backgroundColor = kBackgroundColor;

        NSMutableArray *imageViews = [NSMutableArray array];
        for (NSUInteger i = 0; i < kViewsPerRow; i++)
        {
            MSCustomDrawnViewImageView *imageView = [[MSCustomDrawnViewImageView alloc] init];
            imageView.backgroundColor = kBackgroundColor;
            [self addSubview:imageView];
            [imageViews addObject:imageView];
        }

        self.imageViews = imageViews;
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    const CGFloat widthPerView = self.bounds.size.width / (CGFloat)kViewsPerRow;
    const CGFloat viewHeight = self.bounds.size.height;

    __block CGFloat currentX = 0.0f;

    [self.imageViews enumerateObjectsUsingBlock:^(MSCustomDrawnViewImageView *imageView, NSUInteger idx, BOOL *stop) {
        imageView.frame = CGRectIntegral(CGRectMake(currentX,
                                                    0.0f,
                                                    widthPerView,
                                                    viewHeight));

        currentX += widthPerView;
    }];
}

- (void)setCircleColors:(NSArray *)circleColors
{
    if (circleColors != _circleColors)
    {
        _circleColors = circleColors;

        [circleColors enumerateObjectsUsingBlock:^(UIColor *color, NSUInteger idx, BOOL *stop) {
            [self.imageViews[idx] setCircleColor:color];
        }];
    }
}

@end
