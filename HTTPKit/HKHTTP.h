//
//  HKHTTP.h
//  HTTPKit
//
//  Created by Soheil Rashidi on 4/18/14.
//  Copyright (c) 2013 Soheil Rashidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKHTTP : NSObject

+ (NSString*)queryStringWithParams:(NSDictionary*)params;
+ (NSString*)urlEncodedString:(NSString*)string;

@end
