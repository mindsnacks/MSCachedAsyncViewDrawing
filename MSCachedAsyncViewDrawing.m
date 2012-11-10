//
//  MSCachedAsyncViewDrawing.m
//  MindSnacks
//
//  Created by Javier Soto on 11/8/12.
//
//

#import "MSCachedAsyncViewDrawing.h"

@interface MSCachedAsyncViewDrawing ()

@property (nonatomic, strong) NSCache *cache;

@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

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

    const CGFloat screenScale = [UIScreen mainScreen].scale;

    CGSize realImageSize    = imageSize;
    realImageSize.width     *= screenScale;
    realImageSize.height    *= screenScale;

    dispatch_block_t loadImageBlock = ^{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        BOOL opaque = [self colorIsOpaque:backgroundColor];

        const int bytesPerPixel = 4;
        CGBitmapInfo bitmapInfo = opaque ? kCGImageAlphaNoneSkipLast : kCGImageAlphaPremultipliedLast;
        const int bitsPerComponent = 8;

        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     (size_t)realImageSize.width,
                                                     (size_t)realImageSize.height,
                                                     bitsPerComponent,
                                                     (size_t)realImageSize.width * bytesPerPixel,
                                                     colorSpace,
                                                     bitmapInfo);

        CGColorSpaceRelease(colorSpace);
        colorSpace = NULL;

        if (!context)
        {
            _completionBlock(nil);
            return;
        }

        CGRect rectToDraw = (CGRect){.origin = CGPointZero, .size = realImageSize};

        // Flip the context upside down since the CGContext has an inverse coordinate space.
        CGContextTranslateCTM(context, 0, realImageSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);

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

        UIGraphicsPushContext(context);
        {
            _drawBlock(rectToDraw);
        }
        UIGraphicsPopContext();

        CGImageRef imageResult = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        context = NULL;

        UIImage *image = [[UIImage alloc] initWithCGImage:imageResult
                                                    scale:screenScale
                                              orientation:UIImageOrientationUp];
        CGImageRelease(imageResult);

        [self.cache setObject:image forKey:cacheKey];

        if (waitUntilDone)
        {
            _completionBlock(image);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _completionBlock(image);
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
    CGFloat alpha = 0.0f;
    [color getRed:NULL green:NULL blue:NULL alpha:&alpha];
    
    return (alpha == 1.0f);
}

@end
