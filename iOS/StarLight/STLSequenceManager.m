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
    
    NSData *command = [[[[NSString stringWithFormat:@"%02lx%@",(long)position,(on ? [[UIColor whiteColor] hexValue] : @"000000")] stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString] hexData];
    
    [peripheral writeValue:command forCharacteristic:[[peripheral.services objectAtIndex:0].characteristics objectAtIndex:0] type:CBCharacteristicWriteWithoutResponse];
}
- (void)setLightAtPosition:(NSInteger)position toColor:(UIColor *)color {
    CBPeripheral *peripheral = [STLBluetoothManager sharedManager].connectedPeripheral;
    
    NSData *command = [[[NSString stringWithFormat:@"%02lx%@",(long)position,[[color hexValue] stringByReplacingOccurrencesOfString:@"#" withString:@""]] uppercaseString] hexData];
    
    [peripheral writeValue:command forCharacteristic:[[peripheral.services objectAtIndex:0].characteristics objectAtIndex:0] type:CBCharacteristicWriteWithoutResponse];
}
- (void)uploadPattern:(STLLightPattern *)pattern {
    NSData *command = [pattern dataPattern];
    NSLog(@"%@",command);
}

#pragma mark - Other
- (CBPeripheral*)peripheralForLight:(STLLight*)light {
    CBPeripheral *peripheral = nil;
    for (CBPeripheral *_peripheral in [STLBluetoothManager sharedManager].peripherals) {
        if ([_peripheral.name isEqualToString:light.hub.name]) {
            peripheral = _peripheral;
            break;
        }
    }
    return peripheral;
}
@end
