//
//  AVCaptureDevice+DevicePresence.m
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "AVCaptureDevice+DevicePresence.h"

@implementation AVCaptureDevice (DevicePresence)
+ (BOOL)supportsDeviceType:(AVCaptureDevicePosition)type {
    BOOL exists = NO;
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == type) {
            exists = YES;
            break;
        }
    }
    return exists;
}
@end
