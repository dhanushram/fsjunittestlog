//  FSJUnitTestLog
//
//  Created by Felix Schulze on 9/20/2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "FSJUnitTestLog.h"
#import "GDataXMLNode.h"

@implementation FSJUnitTestLog

- (instancetype)init
{
    if (self = [super init]) {
        [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver:self];
    }
    return self;
}

- (void)startObserving {
    self.document = [[GDataXMLDocument alloc] init];
    self.document = [_document initWithRootElement:[GDataXMLElement elementWithName:@"testsuites"]];
    self.suitesElement = [_document rootElement];

}

- (void)stopObserving {
    [self _writeResultFile];
}

//-----------------------------------------------------------------
#pragma mark Test Bundle
//-----------------------------------------------------------------
- (void)testBundleWillStart:(NSBundle *)testBundle
{
    [self startObserving];
}

- (void)testBundleDidFinish:(NSBundle *)testBundle
{
    [self stopObserving];
}

//-----------------------------------------------------------------
#pragma mark Test Suite
//-----------------------------------------------------------------
- (void)testSuiteWillStart:(XCTestSuite *)testSuite {
    self.currentSuiteElement = [GDataXMLElement elementWithName:@"testsuite"];
    [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:[testSuite name]]];
}

- (void)testSuiteDidFinish:(XCTestSuite *)testSuite {
    XCTestSuiteRun *testSuiteRun = (XCTestSuiteRun *) testSuite.testRun;

    if (_currentSuiteElement) {
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:[[testSuiteRun test] name]]];
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"tests" stringValue:[NSString stringWithFormat:@"%lu", (unsigned long)[testSuiteRun testCaseCount]]]];
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"errors" stringValue:[NSString stringWithFormat:@"%lu", (unsigned long)[testSuiteRun unexpectedExceptionCount]]]];
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"failures" stringValue:[NSString stringWithFormat:@"%lu", (unsigned long)[testSuiteRun failureCount]]]];
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"skipped" stringValue:@"0"]];
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f", [testSuiteRun testDuration]]]];
        [_suitesElement addChild:_currentSuiteElement];
        self.currentSuiteElement = nil;
    }
}

- (void)testSuite:(XCTestSuite *)testSuite didFailWithDescription:(NSString *)description inFile:(nullable NSString *)filePath atLine:(NSUInteger)lineNumber
{
    if (_currentSuiteElement) {
        [_currentSuiteElement addAttribute:[GDataXMLNode attributeWithName:@"message" stringValue:[NSString stringWithFormat:@"%@:%lu", [filePath lastPathComponent], (unsigned long)lineNumber]]];
        [_suitesElement addChild:_currentSuiteElement];
        self.currentSuiteElement = nil;
    }
}

//-----------------------------------------------------------------
#pragma mark Test Case
//-----------------------------------------------------------------
- (void)testCaseWillStart:(XCTestCase *)testCase
{
    self.currentCaseElement = [GDataXMLElement elementWithName:@"testcase"];
    [_currentCaseElement addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:[testCase name]]];
}

- (void)testCaseDidFinish:(XCTestCase *)testCase {
    XCTestCaseRun *testCaseRun = (XCTestCaseRun *) testCase.testRun;
    XCTest *test = [testCaseRun test];

    [_currentCaseElement addAttribute:[GDataXMLNode attributeWithName:@"name" stringValue:[test name]]];
    [_currentCaseElement addAttribute:[GDataXMLNode attributeWithName:@"classname" stringValue:NSStringFromClass([test class])]];
    [_currentCaseElement addAttribute:[GDataXMLNode attributeWithName:@"time" stringValue:[NSString stringWithFormat:@"%f", [testCaseRun testDuration]]]];
    [_currentSuiteElement addChild:_currentCaseElement];
    self.currentCaseElement = nil;
}

- (void)testCase:(XCTestCase *)testCase didFailWithDescription:(NSString *)description inFile:(nullable NSString *)filePath atLine:(NSUInteger)lineNumber {
    GDataXMLElement *failureElement = [GDataXMLElement elementWithName:@"failure"];
    [failureElement setStringValue:description];
    [failureElement addAttribute:[GDataXMLNode attributeWithName:@"message" stringValue:[NSString stringWithFormat:@"%@:%lu", [filePath lastPathComponent], (unsigned long)lineNumber]]];
    [_currentCaseElement addChild:failureElement];
}

#pragma mark - Helper

- (void)_writeResultFile; {
    if (self.document) {
#if DEBUG
        NSString *filePath = @"/var/tmp/junit.xml";
#else
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"junit.xml"];
#endif

        BOOL saved = [[_document XMLData] writeToFile:filePath atomically:NO];
        if (saved) {
            NSLog(@"REPORT LOCATION: %@", filePath);
        }
        else {
            NSLog(@"REPORT LOCATION SAVE ERROR");
        }
    }
    else {
        NSLog(@"ERROR: No document to write.");
    }
}


@end
