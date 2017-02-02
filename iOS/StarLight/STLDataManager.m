//
//  STLDataManager.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDataManager.h"
#import "NS2DArray+CGRect.h"
#import "STLHub+Private.h"

#import <UIKit/UIKit.h>

#define FILE_NAME (@"starlight.stl")

NSString * const STLDataManagerDidFinishLoadingData = @"kSTLDataManagerDidFinishLoadingData";

@interface STLDataManager () {
    NSMutableSet<STLHub*> *hubs;
    BOOL reloading;
    BOOL saved;
    BOOL deleted;
}
@end

@implementation STLDataManager
+ (instancetype)sharedManager {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
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
    
    NSData *data = [NSData dataWithContentsOfFile:fileAtPath];
    if (!data) return nil;
    return [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:fileAtPath] options:0 error:nil];
}

#pragma mark - Data
- (void)loadData {
    if (reloading == YES) return;
    saved = NO;
    deleted = NO;
    reloading = YES;

    [STLHub resetHubs];
    
    hubs = [NSMutableSet new];
    dispatch_async(dispatch_queue_create("com.bolencki13.starlight.loadData", 0), ^(void){
        NSArray *json = [self readFile];
        NSInteger count = 0;
        for (NSDictionary *hub in json) {
            STLHub *_hub = [STLHub hubWithJSON:hub];
            [hubs addObject:_hub];
            count++;
        }
        reloading = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:STLDataManagerDidFinishLoadingData object:nil];
    });
}
- (BOOL)saveData:(NSError *__autoreleasing *)error {
    saved = YES;
    
    NSMutableArray *json = [NSMutableArray new];
    
    for (STLHub *hub in [self hubs]) {
        [json addObject:[hub JSON]];
    }
    
    BOOL success = [self writeToFile:json];
    [self loadData];
    while (reloading) {
        [NSThread sleepForTimeInterval:0];
    }
    return success;
}
- (void)reloadData:(STLDataManagerDidFinishLoading)complete {
    [self loadData];
    
    while (reloading) {
        [NSThread sleepForTimeInterval:0];
    }
    if (complete) complete([[STLHub allHubs] allObjects]);
}

#pragma mark Data (Hub)
- (NSSet<STLHub *> *)hubs {
    if (saved && !deleted) {
        [self loadData];
    }
    
    while (reloading) {
        [NSThread sleepForTimeInterval:0];
    }
    
    return [STLHub allHubs];
}
- (STLHub*)hubWithIdentifier:(NSString *)identifier {
    STLHub *hub_ = nil;
    
    NSSet *tempSet = [[NSSet alloc] initWithSet:[self hubs]];
    for (STLHub *hub in tempSet) {
        if ([hub.identifer isEqualToString:identifier]) {
            hub_ = hub;
            break;
        }
    }
    
    return hub_;
}
- (BOOL)removeHub:(STLHub *)hub error:(NSError *__autoreleasing *)error {
    if (![self saveData:error]) {
        return NO;
    }
    BOOL success = deleted = [STLHub removeHub:hub];
    if (![self saveData:error]) {
        return NO;
    }
    return success;
}

#pragma mark Data (Light)


@end
