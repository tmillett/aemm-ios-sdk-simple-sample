/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2015 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

#import "BaseTest.h"
#import "CustomAssert.h"

@interface BaseTestCase ()

@end

@implementation BaseTestCase

+ (void)setUp
{
	[super setUp];
	
	gThrowExceptionOnAsserts = YES;
}

+ (void)tearDown
{
	gThrowExceptionOnAsserts = NO;
	
	[super tearDown];
}

- (void)tearDown
{
	[super tearDown];
}

- (void)waitFor:(NSTimeInterval)timeInterval
{
	XCTestExpectation* expection = [self expectationWithDescription:@"Time out after a short delay"];
	[expection performSelector:@selector(fulfill) withObject:nil afterDelay:timeInterval];
	[self waitForExpectationsWithTimeout:timeInterval*10 handler:nil];
}

+ (NSString*)testFilePath:(NSString*)testFileName
{
	return [self.testFilesFolder stringByAppendingPathComponent:testFileName];
}

- (NSString*)testFilePath:(NSString*)testFileName
{
	return [self.class testFilePath:testFileName];
}

+ (NSString*)testFilesFolder
{
	return [self testFilesFolderForClass:NSStringFromClass(self.class)];
}

- (NSString*)testFilesFolder
{
	return self.class.testFilesFolder;
}

+ (NSString*)testFilesFolderForClass:(NSString*)testClassName
{
	return [[NSBundle bundleForClass:self.class] pathForResource:testClassName ofType:@"" inDirectory:@"testfiles"];
}

- (NSString*)testFilesFolderForClass:(NSString*)testClassName
{
	return [self.class testFilesFolderForClass:testClassName];
}

+ (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName
{
	return [self stringWithContentsOfTestFile:testFileName forClass:NSStringFromClass(self.class)];
}

- (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName
{
	return [self.class stringWithContentsOfTestFile:testFileName];
}

+ (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName
{
	NSError* error = nil;
	NSString* contents = [NSString stringWithContentsOfFile:[[self testFilesFolderForClass:testClassName] stringByAppendingPathComponent:testFileName] encoding:NSUTF8StringEncoding error:&error];
	ASSERT(error == nil, @"%@", error);
	return contents;
}

- (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName
{
	return [self.class stringWithContentsOfTestFile:testFileName forClass:testClassName];
}

+ (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName;
{
	return [self dataWithContentsOfTestFile:testFileName forClass:NSStringFromClass(self.class)];
}

- (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName;
{
	return [self.class dataWithContentsOfTestFile:testFileName];
}

+ (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName
{
	return [NSData dataWithContentsOfFile:[[self testFilesFolderForClass:testClassName] stringByAppendingPathComponent:testFileName]];
}

- (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName;
{
	return [self.class dataWithContentsOfTestFile:testFileName forClass:testClassName];
}

@end
