//
//  MSCachedAsyncViewDrawing.m
//  MindSnacks
//
//  Created by Javier Soto on 11/8/12.
//
//

#import "MSCachedAsyncViewDrawing.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    #define MSTreatQueuesAsObjects (0)
#else
    #define MSTreatQueuesAsObjects (1)
#endif

#if MSTreatQueuesAsObjects
    #define MS_dispatch_queue_t_property_qualifier strong
#else
    #define MS_dispatch_queue_t_property_qualifier assign
#endif

@interface MSCachedAsyncViewDrawing ()

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) NSMutableDictionary *inProgessKeyToCompletionBlocksDictionary;

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
        
        self.inProgessKeyToCompletionBlocksDictionary = [[NSMutableDictionary alloc] init];
        
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

    drawBlock = [drawBlock copy];
    completionBlock = [completionBlock copy];
    
    NSArray *completionBlocksForCacheKey = [self.inProgessKeyToCompletionBlocksDictionary objectForKey:cacheKey];
    if (completionBlocksForCacheKey)
    {
        completionBlocksForCacheKey = [completionBlocksForCacheKey arrayByAddingObject:completionBlock];
        [self.inProgessKeyToCompletionBlocksDictionary setObject:completionBlocksForCacheKey forKey:cacheKey];
        return;
    }
    else
    {
        completionBlocksForCacheKey = @[completionBlock];
        [self.inProgessKeyToCompletionBlocksDictionary setObject:completionBlocksForCacheKey forKey:cacheKey];
    }
    
    dispatch_block_t loadImageBlock = ^{
        BOOL opaque = [self colorIsOpaque:backgroundColor];

        UIImage *resultImage = nil;

        UIGraphicsBeginImageContextWithOptions(imageSize, opaque, 0);
        {
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
            
            drawBlock(rectToDraw);
            
            resultImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext();
        
        if (resultImage) [self.cache setObject:resultImage forKey:cacheKey];
        
        if (waitUntilDone)
        {
            [self callCompletionBlocksForCacheKey:cacheKey image:resultImage];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self callCompletionBlocksForCacheKey:cacheKey image:resultImage];
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

- (void)callCompletionBlocksForCacheKey:(NSString *)cacheKey image:(UIImage *)image
{
    for (MSCachedAsyncViewDrawingCompletionBlock completionBlock in [self.inProgessKeyToCompletionBlocksDictionary objectForKey:cacheKey])
    {
        completionBlock(image);
    }
    [self.inProgessKeyToCompletionBlocksDictionary removeObjectForKey:cacheKey];
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
