//
//  AppDelegate.m
//  GithubJobs
//
//  Created by Gena on 04.06.2018.
//  Copyright © 2018 GM Groups. All rights reserved.
//

#import "AppDelegate.h"
#import "JobsListViewController.h"

@interface AppDelegate ()
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    JobsListViewController *vc = [JobsListViewController new];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = nc;
    [window makeKeyAndVisible];
    self.window = window;
    
    return YES;
}

@end
