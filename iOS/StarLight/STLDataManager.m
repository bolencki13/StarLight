//
//  STLDataManager.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDataManager.h"
#import "NS2DArray+CGRect.h"

#import <UIKit/UIKit.h>

#define FILE_NAME (@"starlight.info")

@interface STLDataManager () {
    NSMutableSet<STLHub*> *hubs;
}
@end

@implementation STLDataManager
+ (instancetype)sharedManager {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        [_sharedObject loadData];
    });
    return _sharedObject;
}

#pragma mark - File Handling
- (BOOL)writeToFile:(NSArray*)json {
    NSString *fileAtPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:FILE_NAME];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    return [[NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil] writeToFile:fileAtPath atomically:NO];
}
- (NSArray*)readFile {
    NSString *fileAtPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:FILE_NAME];
    
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:fileAtPath] options:0 error:nil];
}

#pragma mark - Data
- (void)loadData {
    hubs = [NSMutableSet new];
    
    for (NSDictionary *hub in [self readFile]) {
        [hubs addObject:[STLHub hubWithJSON:hub]];
    }
}
- (BOOL)saveData:(NSError *__autoreleasing *)error {
    NSMutableArray *json = [NSMutableArray new];
    
    for (STLHub *hub in [self hubs]) {
        [json addObject:[hub JSON]];
    }
    
    BOOL success = [self writeToFile:json];
    [self loadData];
    return success;
}

#pragma mark Data (Hub)
- (NSSet<STLHub *> *)hubs {
    return hubs;
}
- (STLHub*)hubWithName:(NSString *)name {
    STLHub *hub_ = nil;
    
    for (STLHub *hub in [self hubs]) {
        if ([hub.name isEqualToString:name]) {
            hub_ = hub;
            break;
        }
    }
    
    return hub_;
}
- (STLHub*)registerHubWithLights:(NSArray<NSValue *> *)lights error:(NSError *__autoreleasing *)error {
    STLHub *newHub = [STLHub hub];
    
    NSMutableSet *setLights = [NSMutableSet new];
    NS2DArray *matrix = [NS2DArray arrayFromCoordinates:lights];
    [matrix enumerateObjectsUsingBlock:^(NSValue *obj, NSIndexPath *indexPath, BOOL *stop) {
        if (!CGRectIsEmpty([obj CGRectValue])) {
            STLLight *newLight = [STLLight lightWithHub:newHub];
            newLight.coordinate = [obj CGRectValue].origin;
            [setLights addObject:newLight];
        }
    }];
    
    [self saveData:error];
    if (error) {
        return nil;
    } else {
        return newHub;
    }
}

#pragma mark Data (Light)


@end
