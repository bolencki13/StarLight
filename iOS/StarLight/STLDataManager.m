//
//  STLDataManager.m
//  StarLight
//
//  Created by Brian Olencki on 12/20/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLDataManager.h"
#import "STLHub+CoreDataClass.h"
#import "STLLight+CoreDataClass.h"
#import "NS2DArray+CGRect.h"

#import <UIKit/UIKit.h>

@interface STLDataManager ()
@property (readonly, strong) NSPersistentContainer *persistentContainer;
@end

@implementation STLDataManager
@synthesize persistentContainer = _persistentContainer;
+ (instancetype)sharedManager {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark - CoreData
- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"StarLight"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Public
- (STLHub*)registerHubWithLights:(NSArray<NSValue *> *)lights error:(NSError *__autoreleasing *)error {
    STLHub *newHub = [NSEntityDescription insertNewObjectForEntityForName:@"Hub" inManagedObjectContext:self.persistentContainer.viewContext];
    
    NS2DArray *matrix = [NS2DArray arrayFromCoordinates:lights];
    [matrix enumerateObjectsUsingBlock:^(NSValue *obj, NSIndexPath *indexPath, BOOL *stop) {
        if (!CGRectIsEmpty([obj CGRectValue])) {
            NSValue *value = [NSValue valueWithCGPoint:[obj CGRectValue].origin];
            STLLight *newLight = [NSEntityDescription insertNewObjectForEntityForName:@"Light" inManagedObjectContext:self.persistentContainer.viewContext];
            
            NSUInteger size;
            const char *encoding = [value objCType];
            NSGetSizeAndAlignment(encoding, &size, NULL);
            void *ptr = malloc(size);
            [value getValue:ptr];
            NSData *data = [NSData dataWithBytes:ptr length:size];
            free(ptr);
            
            [newLight setCoordinate:data];
            [newLight setOn:NO];
            [newLight setHub:newHub];
            [newHub addLightsObject:newLight];
        }
    }];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Hub" inManagedObjectContext:self.persistentContainer.viewContext]];
    [request setIncludesSubentities:NO];
    
    NSUInteger count = [self.persistentContainer.viewContext countForFetchRequest:request error:nil];
    if (count == NSNotFound) {
        count = 0;
    }
    count++;
    
    [newHub setName:[NSString stringWithFormat:@"Hub #%lu",(unsigned long)count]];
    [newHub setLocation:@"Location"];
    
    [self saveData:error];
    
    if (error) {
        return nil;
    } else {
        return newHub;
    }
}
- (BOOL)saveData:(NSError *__autoreleasing *)error {
    if ([self.persistentContainer.viewContext hasChanges] && ![self.persistentContainer.viewContext save:error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"COREDATA:: (Saving) %@", *error);
        abort();
        return NO;
    }
    return YES;
}
@end
