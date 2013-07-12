//
//  MSCachedAsyncViewDrawing.m
//  MindSnacks
//
//  Created by Javier Soto on 11/8/12.
//
//

#import "MSCachedAsyncViewDrawing.h"

#if !__has_feature(objc_arc)
    #error MSCachedAsyncViewDrawing is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif

#define MSTreatQueuesAsObjects OS_OBJECT_USE_OBJC

#if MSTreatQueuesAsObjects
    #define MS_dispatch_queue_t_property_qualifier strong
#else
    #define MS_dispatch_queue_t_property_qualifier assign
#endif

@interface MSCachedAsyncViewDrawing ()

@property (nonatomic, strong) NSCache *cache;

@property (nonatomic, MS_dispatch_queue_t_property_qualifier) dispatch_queue_t dispatchQueue;

@end

@implementation MSCachedAsyncViewDrawing

+ (MSCachedAsyncViewDrawing *)sharedInstance
{
    static MSCachedAsyncViewDrawing *sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.cache = [[NSCache alloc] init];
        self.cache.name = @"com.mindsnacks.view_drawing.cache";
        self.dispatchQueue = dispatch_queue_create("com.mindsnacks.view_drawing.queue", DISPATCH_QUEUE_CONCURRENT);
    }

    return self;
}

- (void)dealloc
{
    #if !MSTreatQueuesAsObjects
        dispatch_release(_dispatchQueue);
    #endif
}

#pragma mark - Private

- (void)drawViewWithCacheKey:(NSString *)cacheKey
                        size:(CGSize)imageSize
             backgroundColor:(UIColor *)backgroundColor
                   drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock
             completionBlock:(MSCachedAsyncViewDrawingCompletionBlock)completionBlock
               waitUntilDone:(BOOL)waitUntilDone
{
    UIImage *cachedImage = [self.cache objectForKey:cacheKey];

    if (cachedImage)
    {
        completionBlock(cachedImage);
        return;
    }

    MSCachedAsyncViewDrawingDrawBlock _drawBlock = [drawBlock copy];
    MSCachedAsyncViewDrawingCompletionBlock _completionBlock = [completionBlock copy];
    
    dispatch_block_t loadImageBlock = ^{
        BOOL opaque = [self colorIsOpaque:backgroundColor];

        UIGraphicsBeginImageContextWithOptions(imageSize, opaque, 0);

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGRect rectToDraw = (CGRect){.origin = CGPointZero, .size = imageSize};

        BOOL shouldDrawBackgroundColor = ![backgroundColor isEqual:[UIColor clearColor]];

        if (shouldDrawBackgroundColor)
        {
            CGContextSaveGState(context);
            {
                CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
                CGContextFillRect(context, rectToDraw);
            }
            CGContextRestoreGState(context);
        }

        _drawBlock(rectToDraw);

        UIImage *imageResult = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        [self.cache setObject:imageResult forKey:cacheKey];

        if (waitUntilDone)
        {
            _completionBlock(imageResult);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _completionBlock(imageResult);
            });
        }
    };

    if (waitUntilDone)
    {
        loadImageBlock();
    }
    else
    {
        dispatch_async(self.dispatchQueue, loadImageBlock);
    }
}

#pragma mark - Public

- (void)drawViewAsyncWithCacheKey:(NSString *)cacheKey
                             size:(CGSize)imageSize
                  backgroundColor:(UIColor *)backgroundColor
                        drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock
                  completionBlock:(MSCachedAsyncViewDrawingCompletionBlock)completionBlock
{
    [self drawViewWithCacheKey:cacheKey
                          size:imageSize
               backgroundColor:backgroundColor
                     drawBlock:drawBlock
               completionBlock:completionBlock
                 waitUntilDone:NO];
}

- (UIImage *)drawViewSyncWithCacheKey:(NSString *)cacheKey
                                 size:(CGSize)imageSize
                      backgroundColor:(UIColor *)backgroundColor
                            drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock
{
    __block UIImage *image = nil;

    [self drawViewWithCacheKey:cacheKey
                          size:imageSize
               backgroundColor:backgroundColor
                     drawBlock:drawBlock
               completionBlock:^(UIImage *drawnImage) {
                   image = drawnImage;
               }
                 waitUntilDone:YES];

    return image;
}

#pragma mark - Aux

- (BOOL)colorIsOpaque:(UIColor *)color
{
    CGFloat alpha = -1.0f;
    [color getRed:NULL green:NULL blue:NULL alpha:&alpha];

    BOOL wrongColorSpace = (alpha == -1.0f);
    if (wrongColorSpace)
    {
        [color getWhite:NULL alpha:&alpha];
    }

    return (alpha == 1.0f);
}

@end
