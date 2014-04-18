//
//  HKFormData.m
//  HTTPKit
//
//  Created by Soheil Rashidi on 1/9/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import "HKFormData.h"

@implementation HKFormData

- (id)initWithContentType:(NSString*)contentType name:(NSString*)name filename:(NSString*)filename data:(NSData*)data
{
    self = [super init];

    if (self)
    {
        self.contentType = contentType;
        self.name = name;
        self.filename = filename;
        self.data = data;
    }

    return self;
}

@end
