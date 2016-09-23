//
//  FSAdditionalTest.m
//  FSJUnitTestLogExample
//
//  Created by Dhanush Balachandran on 9/23/16.
//  Copyright © 2016 Felix Schulze. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FSAdditionalTest : XCTestCase

@end

@implementation FSAdditionalTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAdditionalPassExample
{
    XCTAssertEqual(22, 11+11, @"Test should pass");
}

- (void)testAdditionalFailExample
{
    XCTAssertEqual(21, 12+10, @"Test should pass");
}


@end
