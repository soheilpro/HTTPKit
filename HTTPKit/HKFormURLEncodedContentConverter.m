//
//  HKFormURLEncodedContentConverter.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import "HKFormURLEncodedContentConverter.h"
#import "HKHTTP.h"

@implementation HKFormURLEncodedContentConverter

- (BOOL)supportsContentType:(NSString*)contentType
{
    if ([contentType caseInsensitiveCompare:@"application/x-www-form-urlencoded"] == NSOrderedSame)
        return YES;

    return NO;
}

- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType
{
    NSString* queryString = [HKHTTP queryStringWithParams:content];

    return [queryString dataUsingEncoding:NSASCIIStringEncoding];
}

- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType
{
    return nil;
}

@end
