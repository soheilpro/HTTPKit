//
//  HKFormData.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 1/9/14.
//  Copyright (c) 2014 Soheil Rashidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKFormData : NSObject

@property (nonatomic, strong) NSString* contentType;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* filename;
@property (nonatomic, strong) NSData* data;

- (id)initWithContentType:(NSString*)contentType name:(NSString*)name filename:(NSString*)filename data:(NSData*)data;

@end
