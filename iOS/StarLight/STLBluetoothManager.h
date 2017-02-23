//
//  STLBluetoothManager.h
//  StarLight
//
//  Created by Brian Olencki on 12/22/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class CBPeripheral;

typedef void (^STLDeviceFailed)(NSError *error);
typedef void (^STLDeviceDiscovery)(NSArray<CBPeripheral*>*peripherals);
typedef void (^STLDeviceConnectionSuccess)(CBPeripheral *peripheral);


@interface STLBluetoothManager : NSObject
@property (nonatomic ,retain, readonly) NSArray <CBPeripheral*> *peripherals;
@property (nonatomic, retain, readonly) CBPeripheral *connectedPeripheral;
+ (STLBluetoothManager*)sharedManager;
- (void)startScanningForDevices:(STLDeviceDiscovery)block;
- (void)stopScanning;
- (void)connectToPeripheral:(CBPeripheral*)peripheral success:(STLDeviceConnectionSuccess)success failed:(STLDeviceFailed)failed;
- (void)disconnnectFromPeripheral:(CBPeripheral*)peripheral;
@end
