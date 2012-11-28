# MSCachedAsyncViewDrawing

Helper class that allows you to draw views (a)synchronously to a UIImage with caching for great performance.

## Description

(This assumes you know a bit about CoreGraphics and how some things like blending work. If not, go read [this post](http://engineering.twitter.com/2012/02/simple-strategies-for-smooth-animation.html) in the Twitter Engineering Blog).

So you have a UITableView in your application that scrolls slow. You decide to implement the cell drawing entirely in CoreGraphics implementing ```-[UIView drawRect:]``` in your cell. This is perfect, until you have to draw images. ```CGContextDrawImage``` is **really slow** compared to using ```UIImageView```.

For this reason, many times you'll find yourself preferring to use ```UIImageView``` even if some compositing has to happen on the cell, because rendering images with it is **FAST** due to the crazy optimizations that it implements internally.

But sometimes you do have to use ```CGContextDrawImage```, because you have to do something more complex like masking, clipping, etc. Wouldn't it be great if you could still do that, but pass the result to a ```UIImageView``` easily, so that you get the benefit from both worlds? That's what ```MSCachedAsyncViewDrawing``` does.

## When to use MSCachedAsyncViewDrawing
Needless to say you shouldn't just go ahead and apply this to all of the UIViews in your app. There's a drawback in this approach, as you're incurring in higher memory usage by storing the result of the all the drawing operations.
**The only way to know if using `MSCachedAsyncViewDrawing` improves or not the performance in your particular case, is to try it out and compare.**
As a general rule on when *it makes sense* to use it would be when -`drawRect:` is becoming a bottleneck, specially if it's using `CGContextDrawImage` inside. This can happen when you have many complex views in the cells of a `UITableView`.

## Sample Project

The sample project contains two view controllers that contain a table view in which every row has 3 views that implement `-drawInRect:`. One of them uses ```MSCachedAsyncViewDrawing``` and the other one doesn't. This is an example on how to use this class and its performance benefit. Install the sample app on your iOS device and compare.
It's also a typical use case for this class, since there are many views on screen at the same time, and they all have to render a `UIImage`, this becomes a bottleneck. `MSCachedAsyncViewDrawing` makes this asynchronous, hence not blocking the main thread and getting perfect scrolling performance, and it also prevents the views from rendering more than once.

## How to use it

This is the main method in ```MSCachedAsyncViewDrawing```:

```objc
- (void)drawViewAsyncWithCacheKey:(NSString *)cacheKey
                             size:(CGSize)imageSize
                  backgroundColor:(UIColor *)backgroundColor
                        drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock
                  completionBlock:(MSCachedAsyncViewDrawingCompletionBlock)completionBlock;
```

The block types are declared like this:

```objc
typedef void (^MSCachedAsyncViewDrawingDrawBlock)(CGRect frame);
typedef void (^MSCachedAsyncViewDrawingCompletionBlock)(UIImage *drawnImage);
```

```MSCachedAsyncViewDrawing``` is going to take the `drawBlock` and call it on a background thread, passing it the `CGRect` that you can pass to a `-drawRect:` method of a view. When it's done, it's going to cache the `UIImage` object with the specified `cacheKey` and call your `completionBlock` with it.

A subsequent call with the same `cacheKey` will result in the immediate call of the `completionBlock` without calling the drawBlock because it'll grab the rendered image from the cache.

The cache is implemented using `NSCache`, so you don't have to worry about putting caching too many images, because iOS is going to take care of evicting obejcts as the available memory goes low.

If you prefer to block the UI while the rendering is happening, beacuse you want to make sure that the image view is not empty at any point, you can use this other method, which immediately returns the ```UIImage``` object:

```objc
- (UIImage *)drawViewSyncWithCacheKey:(NSString *)cacheKey
                                 size:(CGSize)imageSize
                      backgroundColor:(UIColor *)backgroundColor
                            drawBlock:(MSCachedAsyncViewDrawingDrawBlock)drawBlock;
```


## Compatibility
- ```MSCachedAsyncViewDrawing``` is compatible with iOS5.0+.
- ```MSCachedAsyncViewDrawing``` uses ARC. To use in a non-ARC project, mark ```MSCachedAsyncViewDrawing.m``` with the linker flag ```-fobjc-arc.```

## License

Copyright 2012 MindSnacks

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.