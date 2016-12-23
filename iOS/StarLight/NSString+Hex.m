//
//  NSString+Hex.m
//  StarLight
//
//  Created by Brian Olencki on 12/22/16.
//  Copyright © 2016 Brian Olencki. All rights reserved.
//

#import "NSString+Hex.h"

@implementation NSString (Hex)
- (NSData *)hexData {
    const char *chars = [self UTF8String];
    NSInteger i = 0;
    NSInteger len = self.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}
@end
