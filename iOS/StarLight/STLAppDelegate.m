//
//  AppDelegate.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLAppDelegate.h"
#import "STLDataManager.h"

#import <ChameleonFramework/Chameleon.h>

@interface STLAppDelegate ()

@end

@implementation STLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /* BLUE: #65C1FC GREEN: #26C281 */
    [Chameleon setGlobalThemeUsingPrimaryColor:[UIColor colorWithHexString:@"#65C1FC"] withContentStyle:UIContentStyleContrast];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UINavigationBar appearance].tintColor, NSFontAttributeName : [UIFont boldSystemFontOfSize:[UIFont systemFontSize]+6]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[NSClassFromString(@"STLRootViewController") new]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[STLDataManager sharedManager] saveData:nil];
}

#pragma mark - Other
- (void)executeOnQueue:(dispatch_queue_t)queue withTimeConstraint:(NSTimeInterval)time withName:(NSString*)name block:(void(^)())block {
    static NSMutableDictionary *dictItems;
    if (!dictItems) {
        dictItems = [NSMutableDictionary new];
    }
    
    if (![[dictItems objectForKey:name] boolValue]) {
        dispatch_async(queue, ^{
            [dictItems setObject:[NSNumber numberWithBool:YES] forKey:name];
            block();
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), queue, ^{
            [dictItems setObject:[NSNumber numberWithBool:NO] forKey:name];
        });
    }
}
@end
