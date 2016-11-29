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
#import "AEMAssetSourceSyncTaskDownloadInfo+Testing.h"
#import "AEMAssetDownloadInfo.h"
#import "AEMAssetService.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kAssetSourceRelativeCachePath = @"~/Library/Caches/contentCache/id1";

@interface AEMAssetSourceSyncTaskDownloadInfoTests : BaseTestCase

@end

@implementation AEMAssetSourceSyncTaskDownloadInfoTests

- (void)testSave {

	NSString* localRootPath = [kAssetSourceRelativeCachePath stringByExpandingTildeInPath];

	NSError* fileRemoveError = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[AEMAssetSourceSyncTaskDownloadInfo baseFilePathForCachedAssetDownloadInfos] error:&fileRemoveError];
	XCTAssertTrue(success || ([fileRemoveError.domain isEqualToString:NSCocoaErrorDomain] && fileRemoveError.code == NSFileNoSuchFileError));

	AEMAssetService *assetService = [[AEMAssetService alloc] initWithBaseURL:[NSURL URLWithString:@"http://mywebservice.com"]];

	AEMAssetSourceSyncTaskDownloadInfo *loadedInfo = [AEMAssetSourceSyncTaskDownloadInfo assetSourceSyncTaskDownloadInfoWithSessionIdentifier:@"sessionId1" withAssetService:assetService];

	XCTAssertNil(loadedInfo);

	[[NSFileManager defaultManager] createDirectoryAtPath:localRootPath withIntermediateDirectories:YES attributes:nil error:nil];


	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://mywebservice.com"]];

	AEMAssetSource *assetSource = [factory createAssetSourceWithIdentifier:@"id1" withRelativeCachePath:kAssetSourceRelativeCachePath];

	AEMAssetSourceSyncTaskDownloadInfo *info = [AEMAssetSourceSyncTaskDownloadInfo assetSourceSyncTaskDownloadInfoWithSessionIdentifier:@"sessionId1" withAssetSource:assetSource];

	AEMAssetDownloadInfo *assetInfo1 = [[AEMAssetDownloadInfo alloc] init];
	assetInfo1.taskIdentifier = 1;
	assetInfo1.sessionIdentifier = @"sessionId1";
	assetInfo1.remoteURL = [NSURL URLWithString:@"http://www.assets.com/images/image1.jpg"];
	assetInfo1.localPath = [localRootPath stringByAppendingPathComponent:@"image1.jpg"];

	[info setAssetInfo:assetInfo1 forKey:assetInfo1.remoteURL.absoluteString];

	AEMAssetDownloadInfo *assetInfo2 = [[AEMAssetDownloadInfo alloc] init];
	assetInfo2.taskIdentifier = 2;
	assetInfo2.sessionIdentifier = @"sessionId1";
	assetInfo2.remoteURL = [NSURL URLWithString:@"http://www.assets.com/images/image2.jpg"];
	assetInfo2.localPath = [localRootPath stringByAppendingPathComponent:@"image2.jpg"];

	[info setAssetInfo:assetInfo2 forKey:assetInfo2.remoteURL.absoluteString];
	
	[info save];

	loadedInfo = [AEMAssetSourceSyncTaskDownloadInfo assetSourceSyncTaskDownloadInfoWithSessionIdentifier:@"sessionId1" withAssetService:assetService];

	XCTAssertEqualObjects(loadedInfo.assetSource.relativeCachePath, assetSource.relativeCachePath);
	XCTAssertEqualObjects(loadedInfo.assetSource.identifier, assetSource.identifier);

	XCTAssertEqual(loadedInfo.allAssetKeys.count, info.allAssetKeys.count);

	AEMAssetDownloadInfo *assetInfo1Saved = [loadedInfo assetInfoForKey:assetInfo1.remoteURL.absoluteString];
	XCTAssertEqual(assetInfo1Saved.taskIdentifier, assetInfo1.taskIdentifier);
	XCTAssertEqualObjects(assetInfo1Saved.sessionIdentifier, assetInfo1.sessionIdentifier);
	XCTAssertEqualObjects(assetInfo1Saved.remoteURL, assetInfo1.remoteURL);
	XCTAssertEqualObjects(assetInfo1Saved.localPath, assetInfo1.localPath);

	AEMAssetSourceSyncTaskDownloadInfo *loadedInfo2 = [AEMAssetSourceSyncTaskDownloadInfo assetSourceSyncTaskDownloadInfoWithSessionIdentifier:@"sessionId2" withAssetService:assetService];

	XCTAssertNil(loadedInfo2);

	success = [[NSFileManager defaultManager] removeItemAtPath:[AEMAssetSourceSyncTaskDownloadInfo baseFilePathForCachedAssetDownloadInfos] error:nil];
	XCTAssertTrue(success);
}

@end

NS_ASSUME_NONNULL_END
