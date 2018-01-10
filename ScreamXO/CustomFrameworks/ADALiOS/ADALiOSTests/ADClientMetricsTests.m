// Copyright © Microsoft Open Technologies, Inc.
//
// All Rights Reserved
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS
// OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A
// PARTICULAR PURPOSE, MERCHANTABILITY OR NON-INFRINGEMENT.
//
// See the Apache License, Version 2.0 for the specific language
// governing permissions and limitations under the License.

#import <XCTest/XCTest.h>
#import "../ADALiOS/ADClientMetrics.h"

@interface ADClientMetricsTests : XCTestCase

@end

@implementation ADClientMetricsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMetrics {
    
    ADClientMetrics* metrics = [ADClientMetrics new];
    NSMutableDictionary* header = [NSMutableDictionary new];
    
    NSDate* startTime = [NSDate new];
    [metrics addClientMetrics:header
                     endpoint:@"https://login.windows.net/common/oauth2/token"];
    [metrics endClientMetricsRecord:@"https://login.windows.net/common/oauth2/token"
                          startTime:startTime
                      correlationId:[NSUUID UUID]
                       errorDetails:@"error"];
    XCTAssertEqual([header count], 0);
    
    [metrics addClientMetrics:header
                     endpoint:@"https://login.windows.net/common/oauth2/token"];
    XCTAssertEqual([header count], 4);
}

- (void)testMetricsWithADFSEndpointFollowedByNonADFS
{
    ADClientMetrics* metrics = [ADClientMetrics new];
    NSMutableDictionary* header = [NSMutableDictionary new];
    
    NSDate* startTime = [NSDate new];
    [metrics addClientMetrics:header
                     endpoint:@"https://sts.contoso.com/adfs/oauth2/token"];
    XCTAssertEqual([header count], 0);
    [metrics endClientMetricsRecord:@"https://sts.contoso.com/adfs/oauth2/token"
                          startTime:startTime
                      correlationId:[NSUUID UUID]
                       errorDetails:@"error"];
    
    [metrics addClientMetrics:header
                     endpoint:@"https://login.windows.net/common/oauth2/token"];
    XCTAssertEqual([header count], 0);
    
    [metrics endClientMetricsRecord:@"https://login.windows.net/common/oauth2/token"
                          startTime:startTime
                      correlationId:[NSUUID UUID]
                       errorDetails:@"error"];
    
    [metrics addClientMetrics:header
                     endpoint:@"https://login.windows.net/common/oauth2/token"];
    XCTAssertEqual([header count], 4);
}

@end