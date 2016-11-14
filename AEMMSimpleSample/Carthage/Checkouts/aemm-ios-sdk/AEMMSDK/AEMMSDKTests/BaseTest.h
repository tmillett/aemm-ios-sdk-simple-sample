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

#import <XCTest/XCTest.h>

/** Base class for test cases
 */
@interface BaseTestCase : XCTestCase

/** Yield for timeInterval seconds
 */
- (void)waitFor:(NSTimeInterval)timeInterval;

/** @return the path to a test file for this test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSString*)testFilePath:(NSString*)testFileName;
- (NSString*)testFilePath:(NSString*)testFileName;

/** @return the path to the test files folder for this test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSString*)testFilesFolder;
- (NSString*)testFilesFolder;

/** @return the path to the test files folder for a test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSString*)testFilesFolderForClass:(NSString*)testClassName;
- (NSString*)testFilesFolderForClass:(NSString*)testClassName;

/** @return the contents of a test file for this test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName;
- (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName;

/** @return the contents of a test file for a test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName;
- (NSString*)stringWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName;

/** @return the contents of a test file for this test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName;
- (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName;

/** @return the contents of a test file for a test. Test files must be located in a
	folder that has the name as the test class and that is a sibling to the test case source file.
 */
+ (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName;
- (NSData*)dataWithContentsOfTestFile:(NSString*)testFileName forClass:(NSString*)testClassName;

@end
