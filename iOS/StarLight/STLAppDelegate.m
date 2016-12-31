//
//  AppDelegate.m
//  StarLight
//
//  Created by Brian Olencki on 12/6/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLAppDelegate.h"
#import "STLDataManager.h"
#import <Chameleon.h>

#import "STLHub.h"
#import "STLLight.h"

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
    
#if DEBUG
    [self populateDummyData];
#endif
    
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
- (void)populateDummyData {
    NSString *jsonString = @"[{\"identifier\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"lights\":[{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":0,\"index\":1},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":1,\"index\":2},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":2,\"index\":5},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":5,\"index\":13},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":6,\"index\":14},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":8,\"index\":17},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":9,\"index\":18},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":10,\"index\":19},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":11,\"index\":20},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":12,\"index\":22},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":13,\"index\":24},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":15,\"index\":28},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":16,\"index\":30},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":17,\"index\":32},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":18,\"index\":33},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":19,\"index\":34},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":20,\"index\":35},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":21,\"index\":36},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":22,\"index\":37},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":23,\"index\":41},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":24,\"index\":43},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":25,\"index\":44},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":26,\"index\":45},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":28,\"index\":47},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":29,\"index\":50},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":30,\"index\":52},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":31,\"index\":53},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":32,\"index\":54},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":33,\"index\":55},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":34,\"index\":58},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":34,\"index\":59},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":36,\"index\":60},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":37,\"index\":61},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":39,\"index\":64},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":40,\"index\":65},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":43,\"index\":69},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":44,\"index\":71},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":45,\"index\":72},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":46,\"index\":73},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":47,\"index\":75},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":49,\"index\":78},{\"on\":false,\"hub\":\"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx\",\"position\":50,\"index\":79}],\"name\":\"StarLight-000\",\"location\":\"TestLights\",\"matrix\":{\"rows\":10,\"sections\":9}}]";
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString *fileAtPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"starlight.stl"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    NSLog(@"%@ dummy data",[[NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil] writeToFile:fileAtPath atomically:NO] ? @"Successfuly populated" : @"Failed to populate");
}
@end
