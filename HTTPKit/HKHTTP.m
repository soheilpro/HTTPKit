//
//  HKHTTP.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKHTTP.h"

@implementation HKHTTP

+ (NSString*)queryStringWithParams:(NSDictionary*)params
{
    if (params.count == 0)
        return @"";

    NSMutableArray* args = [NSMutableArray array];

    for (NSString* key in params)
    {
        NSString* value = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
        NSString* encodedKey = [self urlEncodedString:key];
        NSString* encodedValue = [self urlEncodedString:value];
        NSString* arg = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];

        [args addObject:arg];
    }

    return [args componentsJoinedByString:@"&"];
}

+ (NSString*)urlEncodedString:(NSString*)string
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!;/?:@&=$+{}()<>,", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

@end
