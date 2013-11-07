# HTTPKit
HTTPKit is a very simple and exteremly lightweight block-based and asynchronous Objective-C library for making HTTP requests. It's perfect for working with RESTful APIs.

## Adding HTTPKit to your project
1. Download the [latest version](https://github.com/soheilpro/HTTPKit/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
2. Open your project in Xcode, then drag and drop all the source files onto your project (use the "Product Navigator view"). Make sure to select Copy items when asked if you extracted the code archive outside of your project.
3. Include HTTPKit wherever you need it with `#import "HTTPKit.h"`.

## Usage
Create an instance of HKRequest class, set its properties and call the send method:

```objective-c
HKRequest* request = [[HKRequest alloc] init];
request.method = @"POST";
request.baseUrl = @"https://api.example.com";
request.path = @"users/%@/posts/%@/comments";
[request.pathParams addObject:userId];
[request.pathParams addObject:postId];
[request.queryParams setObject:accessToken forKey:@"access_token"];
[request.headers setObject:@"My User-Agent" forKey:@"User-Agent"];
[request.data setObject:userId forKey:"user_id"];
[request.data setObject:commentBody forKey:@"comment_body"];
[request.data setObject:@(YES) forKey:@"share"];

[request send:^(HKResponse* response, NSError* error)
{
    if (error != nil)
    {
        // Deal with the error
        return;
    }
    
	if (response.statusCode != 201)
	{
		// Something went wrong
		return;
	}
	
	NSLog(@"Comment Id: %@", [response.data objectForKey:@"comment_id"]);
}];

```

## Version History
+ **1.0**
	+ Initial release

## Author
**Soheil Rashidi**

+ http://soheilrashidi.com
+ http://twitter.com/soheilpro
+ http://github.com/soheilpro

## Copyright and License
Copyright 2013 Soheil Rashidi

Licensed under the The MIT License (the "License");
you may not use this work except in compliance with the License.
You may obtain a copy of the License in the LICENSE file, or at:

http://www.opensource.org/licenses/mit-license.php

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
