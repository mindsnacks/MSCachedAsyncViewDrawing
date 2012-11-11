# MSCachedAsyncViewDrawing

Helper class that allows you to draw views (a)synchronously to a UIImage with caching for great performance.

## Description

(This assumes you know a bit about CoreGraphics and how some things like blending work. If not, go read [this post](http://engineering.twitter.com/2012/02/simple-strategies-for-smooth-animation.html) in the Twitter Engineering Blog).

So you have a UITableView in your application that scrolls slow. You decide to implement the cell drawing entirely in CoreGraphics implementing ```-[UIView drawRect:]``` in your cell. This is perfect, until you have to draw images. ```CGContextDrawImage``` is **really slow** compared to using ```UIImageView```.

For this reason, many times you'll find yourself preferring to use ```UIImageView``` even if some compositing has to happen on the cell, because rendering images with it is **FAST**.

But sometimes you do have to use ```CGContextDrawImage```, because you have to do something more complex like masking, clipping, etc. Wouldn't it be great if you could still do that, but pass the result to a ```UIImageView``` easily? That's what ```MSCachedAsyncViewDrawing``` does.

## Sample Project

The sample project contains two view controllers that contain a table view in which every row has 3 views that implement `-drawInRect:`. One of them uses ```MSCachedAsyncViewDrawing``` and the other one doesn't. This is a very good example on how to use this class and its performance benefit. Install the sample app on your iOS device and compare.

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

If you prefer to block the UI while the rendering is happening, beacuse you want to make sure that the image view is not empty at any point, you can use this other method, which inmediately returns the ```UIImage``` object:

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