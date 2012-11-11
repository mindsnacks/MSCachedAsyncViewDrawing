//
//  MSTraditionalDrawingVC.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSTraditionalDrawingTVC.h"

#import "MSTraditionalDrawingCell.h"

@interface MSTraditionalDrawingTVC ()

@end

@implementation MSTraditionalDrawingTVC

- (id)init
{
    if ((self = [super initWithCellClass:[MSTraditionalDrawingCell class]]))
    {
        self.title = @"No MSCachedAsyncViewDrawing";
    }

    return self;
}

@end
