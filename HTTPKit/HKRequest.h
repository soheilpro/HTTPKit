//
//  HKRequest.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 5/23/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import "HKResponse.h"
#import "HKRequestBase.h"
#import <Foundation/Foundation.h>

@class HKResponse;

@interface HKRequest : NSObject

@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) NSString* baseUrl;
@property (nonatomic, strong) NSString* path;
@property (nonatomic, strong) NSMutableArray* pathParams;
@property (nonatomic, strong) NSMutableDictionary* queryParams;
@property (nonatomic, strong) NSMutableDictionary* headers;
@property (nonatomic, strong) NSString* contentType;
@property (nonatomic, strong) NSData* body;
@property (nonatomic, strong) NSMutableDictionary* data;
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, strong, readonly) HKRequestBase* httpRequest;

- (void)send:(void (^) (HKResponse* response, NSError* error))callback;

@end
