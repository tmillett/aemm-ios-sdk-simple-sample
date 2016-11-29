/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2016 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by all applicable intellectual property
 * laws, including trade secret and copyright laws.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

#import "BaseTest.h"
#import "AEMMSDK.h"
#import "NSString+Helpers.h"

@interface AEMAssetSourceFactoryTests : BaseTestCase

@end

@implementation AEMAssetSourceFactoryTests

- (void)testAPI {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"
	XCTAssertThrows([AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:nil]);
#pragma clang diagnostic pop

	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"https://test.com"]];

	AEMAssetSource *source1 = [factory createAssetSourceWithIdentifier:@"id1" withRelativeCachePath:@"~/Library/Caches"];
	AEMAssetSource *source1Dup = [factory createAssetSourceWithIdentifier:@"id1" withRelativeCachePath:@"~/Library/Caches"];

	XCTAssertEqual(source1, source1Dup);

	AEMAssetSource *source2SameLocation = [factory createAssetSourceWithIdentifier:@"id2" withRelativeCachePath:@"~/Library/Caches"];

	XCTAssertNotEqual(source1, source2SameLocation);

	AEMAssetSource *source1DiffLocation = [factory createAssetSourceWithIdentifier:@"id1" withRelativeCachePath:@"~/Library"];

	XCTAssertNotEqual(source1, source1DiffLocation);
}

@end
