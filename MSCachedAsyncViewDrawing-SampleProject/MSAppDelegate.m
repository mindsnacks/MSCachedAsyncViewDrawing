//
//  MSAppDelegate.m
//  MSCachedAsyncViewDrawing-SampleProject
//
//  Created by Javier Soto on 11/10/12.
//  Copyright (c) 2012 MindSnacks. All rights reserved.
//

#import "MSAppDelegate.h"

#import "MSTraditionalDrawingTVC.h"
#import "MSAsyncDrawingTVC.h"

@interface MSAppDelegate ()

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end

@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    MSTraditionalDrawingTVC *vc1 = [[MSTraditionalDrawingTVC alloc] init];
    MSAsyncDrawingTVC *vc2 = [[MSAsyncDrawingTVC alloc] init];

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[vc1, vc2];

    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
