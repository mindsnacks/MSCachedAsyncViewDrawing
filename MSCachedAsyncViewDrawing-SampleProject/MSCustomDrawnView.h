//
//  MSCustomDrawnView.h
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSCustomDrawnView : UIView

@property (atomic, strong) UIColor *circleColor;

- (id)initWithFrame:(CGRect)frame
        circleColor:(UIColor *)circleColor;

@end
