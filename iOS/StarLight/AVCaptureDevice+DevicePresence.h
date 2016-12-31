//
//  AVCaptureDevice+DevicePresence.h
//  StarLight
//
//  Created by Brian Olencki on 12/26/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVCaptureDevice (DevicePresence)
+ (BOOL)supportsDeviceType:(AVCaptureDevicePosition)type;
@end
