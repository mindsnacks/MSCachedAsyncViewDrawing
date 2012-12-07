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

@interface MSCachedAsyncViewDrawing : NSObject

/**
 * @discussion you can use the shared instance to have a shared cache.
 */
+ (MSCachedAsyncViewDrawing *)sharedInstance;

/**
 * @discussion this method will call `drawBlock` _on a background thread_ passing a CGRect that you can pass to a `drawRect:` method
 * of a view or a layer.
 * Once finished, it'll call the completion block on the main thread with the drawn UIImage object.
 * `MSCachedAsyncViewDrawing` objects keep an internal cache so multiple calls to this method with the same `cacheKey`
 * will result in the immediate call of `completionBlock`.
 * @param `synchronous` Passing YES will run synchronously and will call completionBlock before returning nil
 * @param `cacheKey` make sure you create a string with the paremeters of the view. Two views configured
 * differently (say, different text or font color) should have different cache keys to avoid collisions)
 * @param backgroundColor if you want a transparent image, just pass [UIColor clearColor].
 * To generate an opaque image, pass a color with alpha = 1.
 * @param drawBlock this method is called from a background thread, so you must pay special attention to the thread safety of
 * anything you do in it. It's safe to use UIKit methods like -[UIImage drawInRect:] or -[NSString drawInRect:].
 * @return NSOperation associated with the drawing. If you're enqueuing a lot of drawing, you may want to cancel the operation
 * before it finishes if the result is not needed anymore to save resources.
 */
- (NSOperation *)drawViewSynchronous:(BOOL)synchronous
                        withCacheKey:(NSString *)cacheKey
                                size:(CGSize)imageSize
                     backgroundColor:(UIColor *)backgroundColor
                           drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock
                     completionBlock:(MSCachedAsyncViewDrawingCompletionBlock)completionBlock;

@end