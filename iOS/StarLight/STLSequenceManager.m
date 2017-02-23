//
//  STLSequenceManager.m
//  StarLight
//
//  Created by Brian Olencki on 12/22/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "STLSequenceManager.h"
#import "STLBluetoothManager.h"
#import "STLDataManager.h"
#import "STLHub.h"
#import "STLLight.h"
#import "NSString+Hex.h"

#import <Chameleon.h>

@implementation STLSequenceManager
+ (STLSequenceManager *)sharedManager {
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

    }
    return self;
}

#pragma mark - Light Control
- (void)setLightAtPosition:(NSInteger)position on:(BOOL)on {
    CBPeripheral *peripheral = [STLBluetoothManager sharedManager].connectedPeripheral;
    
    NSData *command = [[[[NSString stringWithFormat:@"%02lx%@",(long)position,(on ? [[UIColor whiteColor] hexValue] : @"000000")] stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString] dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [peripheral writeValue:command forCharacteristic:[[peripheral.services objectAtIndex:0].characteristics objectAtIndex:0] type:CBCharacteristicWriteWithoutResponse];
}
- (void)setLightAtPosition:(NSInteger)position toColor:(UIColor *)color {
    CBPeripheral *peripheral = [STLBluetoothManager sharedManager].connectedPeripheral;
    
    NSString *strCommand = [[NSString stringWithFormat:@"%02lx%@",(long)position,[[color hexValue] stringByReplacingOccurrencesOfString:@"#" withString:@""]] uppercaseString];
    if (strCommand.length < 8) {
        strCommand = [NSString stringWithFormat:@"0%@",strCommand];
    }
    NSLog(@"Sending string of length: %lu",(unsigned long)strCommand.length);
    NSData *command = [strCommand dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([[peripheral.services objectAtIndex:0].characteristics objectAtIndex:0] != nil) {
        [peripheral writeValue:command forCharacteristic:[[peripheral.services objectAtIndex:0].characteristics objectAtIndex:0] type:CBCharacteristicWriteWithoutResponse];
    }
}
- (void)uploadToHub:(STLHub*)hub {
    if (_running) return;
    _running = YES;
    
    [self connectIfNecessary:hub success:^(CBPeripheral *peripheral) {
        NSLog(@"Connected");
        NSArray *aryItems = [hub.pattern.absolutePattern componentsSeparatedByString:[STLLightPattern frameIdentifier]];
        for (NSString *line in aryItems) {
            for (STLLight *light in hub.lights) {
                [self setLightAtPosition:light.index on:NO];
                [NSThread sleepForTimeInterval:DELAY_BLE];
            }
            for (NSInteger x = 0; x < (line.length/8); x++) {
                NSString *strLine = [line substringFromIndex:8*x];
                if (strLine.length > 8) strLine = [strLine substringToIndex:8];
                
                NSInteger position = [[strLine substringToIndex:3] integerValue];
                NSString *color = [strLine substringFromIndex:2];
                
                [self setLightAtPosition:position toColor:[UIColor colorWithHexString:[NSString stringWithFormat:@"#%@",color]]];
                [NSThread sleepForTimeInterval:DELAY_BLE];
            }
            [NSThread sleepForTimeInterval:(hub.pattern.delay/1000)];
        }
        _running = NO;
    } failed:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - Other
- (void)connectIfNecessary:(STLHub*)hub success:(STLDeviceConnectionSuccess)success failed:(STLDeviceFailed)failed {
    if ([STLBluetoothManager sharedManager].connectedPeripheral == nil) {
        CBPeripheral *peripheral = [self peripheralForHub:hub];
        if (peripheral) {
            [[STLBluetoothManager sharedManager] connectToPeripheral:[self peripheralForHub:hub] success:success failed:failed];
        } else {
            if (failed) failed([NSError errorWithDomain:@"com.bolencki13.starlight" code:-42 userInfo:@{
                                                                                                        NSLocalizedFailureReasonErrorKey : @"Peripheral is nil"
                                                                                                        }]);
        }
    } else {
        if (success) success([STLBluetoothManager sharedManager].connectedPeripheral);
    }
}
- (CBPeripheral*)peripheralForHub:(STLHub*)hub {
    CBPeripheral *peripheral = nil;
    NSArray *aryTemp =[STLBluetoothManager sharedManager].peripherals;
    for (CBPeripheral *_peripheral in aryTemp) {
        if ([[_peripheral.identifier UUIDString] isEqualToString:hub.identifer]) {
            peripheral = _peripheral;
            break;
        }
    }
    return peripheral;
}

@end
