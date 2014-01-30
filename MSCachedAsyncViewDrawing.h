//
//  MSCachedAsyncViewDrawing.h
//  MindSnacks
//
//  Created by Javier Soto on 11/8/12.
//
//

#import <Foundation/Foundation.h>

typedef void (^MSCachedAsyncViewDrawingDrawBlock)(CGRect frame);
typedef void (^MSCachedAsyncViewDrawingCompletionBlock)(UIImage *drawnImage);

@protocol MSCachedAsyncViewDrawingCache;

@interface MSCachedAsyncViewDrawing : NSObject

/**
 * You can use the shared instance to have a shared cache.
 * Uses in-memory caching by default.
 * @note It's perfectly valid to create separate instances of `MSCachedAsyncViewDrawing`, they will just have independent caches.
 */
+ (MSCachedAsyncViewDrawing *)sharedInstance;

/**
 * Initialize instance using in-memory caching.
 */
- (instancetype)init;

/**
 * Designated initializer.
 * @param cache: must be thread safe.
 */
- (instancetype)initWithCache:(id<MSCachedAsyncViewDrawingCache>)cache;

/**
 * This method will call `drawBlock` _on a background thread_ passing a `CGRect` that you can pass to a `drawRect:` method
 * of a view or a layer.
 * Once finished, it'll call the completion block on the main thread with the drawn `UIImage` object.
 * `MSCachedAsyncViewDrawing` objects keep an internal cache so multiple calls to this method with the same `cacheKey`
 * will result in the immediate call of `completionBlock`.
 * @param cacheKey make sure you create a string with the paremeters of the view. Two views configured
 * differently (say, different text or font color) should have different cache keys to avoid collisions)
 * @param backgroundColor if you want a transparent image, just pass `[UIColor clearColor]`.
 * To generate an opaque image, pass a color with alpha = 1.
 * @param drawBlock this method is called from a background thread, so you must pay special attention to the thread safety of
 * anything you do in it. It's safe to use UIKit methods like `-[UIImage drawInRect:]` or `-[NSString drawInRect:]`.
 */
- (void)drawViewAsyncWithCacheKey:(NSString *)cacheKey
                             size:(CGSize)imageSize
                  backgroundColor:(UIColor *)backgroundColor
                        drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock
                  completionBlock:(MSCachedAsyncViewDrawingCompletionBlock)completionBlock;

/**
 * This is the synchronous version of the other method.
 * It waits until the image is loaded and returns it instead of calling a completion block.
 * @param drawBlock is called on the caller thread.
 */
- (UIImage *)drawViewSyncWithCacheKey:(NSString *)cacheKey
                                 size:(CGSize)imageSize
                      backgroundColor:(UIColor *)backgroundColor
                            drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock;


@end

@protocol MSCachedAsyncViewDrawingCache <NSObject>

/**
 * @return `nil` if the image for `key` is not available.
 */
- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

@end