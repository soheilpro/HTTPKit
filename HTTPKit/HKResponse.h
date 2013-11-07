//
//  HKResponse.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 6/17/12.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKResponse : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) NSString* contentType;
@property (nonatomic, strong) NSData* body;
@property (nonatomic, strong) NSDictionary* data;

@end
