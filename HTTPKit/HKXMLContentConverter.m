//
//  HKXMLContentConverter.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import "HKXMLContentConverter.h"
#import "XMLDictionary.h"

@implementation HKXMLContentConverter

- (BOOL)supportsContentType:(NSString*)contentType
{
    if ([contentType caseInsensitiveCompare:@"application/xml"] == NSOrderedSame)
        return YES;

    if ([contentType caseInsensitiveCompare:@"text/xml"] == NSOrderedSame)
        return YES;

    return NO;
}

- (NSData*)dataFromContent:(id)content contentType:(NSString**)contentType
{
    if ([content isKindOfClass:[NSDictionary class]])
    {
        NSString* innerXML = [((NSDictionary*)content) innerXML];

        return [innerXML dataUsingEncoding:NSUTF8StringEncoding];
    }

    return nil;
}

- (id)contentFromData:(NSData*)data contentType:(NSString*)contentType
{
    return [NSDictionary dictionaryWithXMLData:data];
}

@end
