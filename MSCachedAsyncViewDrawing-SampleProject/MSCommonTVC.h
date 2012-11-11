//
//  MSCommonTVC.h
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MSCustomDrawnViewCell.h"

@interface MSCommonTVC : UITableViewController

/**
 * @discussion designated initializer
 * @param cellClass has to conform to `MSCustomDrawnViewCell`
 */
- (id)initWithCellClass:(Class<MSCustomDrawnViewCell>)cellClass;

@end
