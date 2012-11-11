//
//  MSAsyncDrawingTVC.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSAsyncDrawingTVC.h"

@interface MSAsyncDrawingTVC ()

@end

@interface MSAsyncDrawingCell : NSObject

@end

@implementation MSAsyncDrawingTVC

- (id)init
{
    if ((self = [super initWithCellClass:[MSAsyncDrawingCell class]]))
    {
        self.title = @"MSCachedAsyncViewDrawing";
    }

    return self;
}

@end
