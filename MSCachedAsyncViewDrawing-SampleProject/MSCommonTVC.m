//
//  MSCommonTVC.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSCommonTVC.h"

#import "MSCustomDrawnViewCell.h"

#define kNumberOfRows 200
#define kRowHeight 100.0f

@interface MSCommonTVC ()

@property (nonatomic, assign) Class cellClass;

@end

@implementation MSCommonTVC

- (id)initWithCellClass:(Class)cellClass
{
    if ((self = [super initWithStyle:UITableViewStylePlain]))
    {
        self.cellClass = cellClass;
    }

    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:self.cellClass forCellReuseIdentifier:[self cellID]];

    self.tableView.backgroundColor = kBackgroundColor;
    self.tableView.rowHeight = kRowHeight;
}

#pragma mark - Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<MSCustomDrawnViewCell> *cell = [tableView dequeueReusableCellWithIdentifier:[self cellID]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.circleColors = [self circleColorsForIndexPath:indexPath];

    return cell;
}

#pragma mark - 

/**
 * @discussion using consistent colors between calls so that the view can be cached and reused (as opposed to using just random colors)
 */
- (NSArray *)circleColorsForIndexPath:(NSIndexPath *)indexPath
{
    const NSUInteger row = indexPath.row;

    NSMutableArray *circleColors = [NSMutableArray array];
    for (NSUInteger i = 0; i < kViewsPerRow; i++)
    {
        const CGFloat componentValue = (row + i) / (CGFloat)kNumberOfRows;

        UIColor *color = [UIColor colorWithRed:componentValue + i / 10.f
                                         green:componentValue + i / 20.0f
                                          blue:componentValue + i / 30.0f
                                         alpha:1.0f];

        [circleColors addObject:color];
    }

    return circleColors;
}

- (NSString *)cellID
{
    return NSStringFromClass(self.cellClass);
}

@end
