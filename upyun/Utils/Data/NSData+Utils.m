//
//  NSData+Utils.m
//  UpYunSDK2.0
//
//  Created by jack zhou on 13-8-29.
//  Copyright (c) 2013年 upyun. All rights reserved.
//
#import "NSData+Utils.h"
@implementation NSData (Utils)
- (NSString *)detectImageSuffix
{
    uint8_t c;
    NSString *imageFormat = @"";
    [self getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            imageFormat = @".jpg";
            break;
        case 0x89:
            imageFormat = @".png";
            break;
        case 0x47:
            imageFormat = @".gif";
            break;
        case 0x49:
        case 0x4D:
            imageFormat = @".tiff";
            break;
        case 0x42:
            imageFormat = @".bmp";
            break;
        default:
            break;
    }
    return imageFormat;
}
@end
