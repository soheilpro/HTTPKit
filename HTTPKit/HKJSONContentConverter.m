//
//  HKJSONContentConverter.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import "HKJSONContentConverter.h"

@implementation HKJSONContentConverter

- (BOOL)supportsContentType:(NSString*)contentType
{
    if ([contentType caseInsensitiveCompare:@"application/json"] == NSOrderedSame)
        return YES;

    return NO;
}

- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType
{
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:&error];

    if (error != nil)
        return nil;

    return data;
}

- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType
{
    NSError* error = nil;
    id content = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error != nil)
        return nil;

    return content;
}

@end
