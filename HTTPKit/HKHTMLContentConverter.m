//
//  HKHTMLContentConverter.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/21/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import "HKHTMLContentConverter.h"

@implementation HKHTMLContentConverter

- (BOOL)supportsContentType:(NSString*)contentType
{
    if ([contentType caseInsensitiveCompare:@"text/html"] == NSOrderedSame)
        return YES;

    return NO;
}

- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType
{
    return [((NSString*)content) dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType
{
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
