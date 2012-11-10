//
//  MSSecondViewController.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSSecondViewController.h"

@interface MSSecondViewController ()

@end

@implementation MSSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
