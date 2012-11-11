//
//  MSCustomDrawnViewCell.h
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kViewsPerRow 3
#define kBackgroundColor [UIColor lightGrayColor]

/**
 * @see MSTraditionalDrawingCell
 * @see MSAsyncDrawingCell
 */
@protocol MSCustomDrawnViewCell <NSObject>

@property (nonatomic, copy) NSArray *circleColors;

@end
