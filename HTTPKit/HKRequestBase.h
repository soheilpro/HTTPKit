//
//  HKRequestBase.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 6/16/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKResponseBase.h"
#import <Foundation/Foundation.h>

@class HKResponseBase;

@interface HKRequestBase : NSObject<NSURLConnectionDelegate>

@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSMutableDictionary* headers;
@property (nonatomic, strong) NSData* body;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;

- (void)send:(void (^) (HKResponseBase* response, NSError* error))callback;
- (void)invalidateCachedResponse;

@end
