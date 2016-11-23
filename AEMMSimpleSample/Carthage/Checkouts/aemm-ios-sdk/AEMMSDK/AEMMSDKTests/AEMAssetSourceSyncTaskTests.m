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
#import <OHHTTPStubs/OHHTTPStubsUmbrella.h>
#import "HttpHeaders.h"
#import "AEMAssetSourceSyncTask+Testing.h"

@interface AEMTaskListener : NSObject <AEMTaskSuccessListener, AEMTaskProgressListener, AEMTaskErrorListener>
@end

@implementation AEMTaskListener


- (void)taskDidComplete:(AEMTask *)task {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AEMAssetSourceSyncTaskCompleted" object:task];
}

- (void)task:(AEMTask *)task didSendProgress:(NSUInteger)progress {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AEMAssetSourceSyncTaskSentProgress" object:task];
}

- (void)task:(AEMTask *)task didCompleteWithError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AEMAssetSourceSyncTaskFailed" object:task];
}


@end

@interface AEMAssetSourceSyncTaskTests : BaseTestCase

@end

@implementation AEMAssetSourceSyncTaskTests

- (void)testAEMAssetSourceSyncTaskNoUpdate {

	// This test pulls down the same manifest content twice to
	// ensure content is not downloaded twice

	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString* localRootPath = [cachesDirectory stringByAppendingPathComponent:@"contentCache/id1"];

	NSError* fileRemoveError = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:&fileRemoveError];
	XCTAssertTrue(success || ([fileRemoveError.domain isEqualToString:NSCocoaErrorDomain] && fileRemoveError.code == NSFileNoSuchFileError));

	[[NSFileManager defaultManager] createDirectoryAtPath:localRootPath withIntermediateDirectories:YES attributes:nil error:nil];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"mywebservice.com"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSData* data = [self dataWithContentsOfTestFile:@"manifest.json"];
		return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeApplicationJSON}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_room.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSString* fixture = [self testFilePath:@"bg_hotel_room.png"];
		return [OHHTTPStubsResponse responseWithFileAtPath:fixture statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeImagePNG}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_facade-1.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSString* fixture = [self testFilePath:@"bg_hotel_facade-1.png"];
		return [OHHTTPStubsResponse responseWithFileAtPath:fixture statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeImagePNG}];
	}];

	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://mywebservice.com"]];

	AEMAssetSource *assetSource = [factory createAssetSourceWithIdentifier:@"id1" withRootFilePath:localRootPath];

	AEMAssetSourceSyncTask *task = [assetSource syncInBackground:NO];

	AEMTaskListener *taskListener = [[AEMTaskListener alloc] init];
	[task addSuccessListener:taskListener];
	[task addErrorListener:taskListener];
	[task addProgressListener:taskListener];

	[self expectationForNotification:@"AEMAssetSourceSyncTaskCompleted" object:task handler:^BOOL(NSNotification *notification) {
		AEMAssetSourceSyncTask* task = notification.object;
		XCTAssert([task isKindOfClass:AEMAssetSourceSyncTask.class]);
		BOOL isDir = NO;
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:assetSource.rootFilePath isDirectory:&isDir]);
		XCTAssertTrue(isDir);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_room.png"]] checkResourceIsReachableAndReturnError:nil]);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_facade-1.png"]] checkResourceIsReachableAndReturnError:nil]);

		XCTAssertEqual(task.assetsAdded.count, 2);

		return YES;
	}];
	[self waitForExpectationsWithTimeout:100 handler:nil];

	AEMAssetSourceSyncTask *task2 = [assetSource syncInBackground:NO];

	[task2 addSuccessListener:taskListener];
	[task2 addErrorListener:taskListener];
	[task2 addProgressListener:taskListener];

	[self expectationForNotification:@"AEMAssetSourceSyncTaskCompleted" object:task2 handler:^BOOL(NSNotification *notification) {
		AEMAssetSourceSyncTask* task = notification.object;
		XCTAssert([task isKindOfClass:AEMAssetSourceSyncTask.class]);
		BOOL isDir = NO;
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:assetSource.rootFilePath isDirectory:&isDir]);
		XCTAssertTrue(isDir);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_room.png"]] checkResourceIsReachableAndReturnError:nil]);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_facade-1.png"]] checkResourceIsReachableAndReturnError:nil]);

		XCTAssertEqual(task.assetsAdded.count, 0);

		return YES;
	}];
	[self waitForExpectationsWithTimeout:100 handler:nil];


	success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:nil];
	XCTAssertTrue(success);
}

- (void)testAEMAssetSourceSyncTaskUpdateAddedChangedRemoved {

	// This test pulls down a manifest and downloads content,
	// then downloads an updated manifest content twice to change, remove, and add content

	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString* localRootPath = [cachesDirectory stringByAppendingPathComponent:@"contentCache/id1"];

	NSError* fileRemoveError = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:&fileRemoveError];
	XCTAssertTrue(success || ([fileRemoveError.domain isEqualToString:NSCocoaErrorDomain] && fileRemoveError.code == NSFileNoSuchFileError));

	[[NSFileManager defaultManager] createDirectoryAtPath:localRootPath withIntermediateDirectories:YES attributes:nil error:nil];

	__block NSInteger manifestCallNumber = 0;

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"mywebservice.com"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSData* data = nil;

		if (manifestCallNumber == 0) {
			manifestCallNumber++;
			data = [self dataWithContentsOfTestFile:@"manifest.json"];
		} else {
			data = [self dataWithContentsOfTestFile:@"manifestV2.json"];
		}

		return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeApplicationJSON}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_room.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSString* fixture = [self testFilePath:@"bg_hotel_room.png"];
		return [OHHTTPStubsResponse responseWithFileAtPath:fixture statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeImagePNG}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_facade-1.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSString* fixture = [self testFilePath:@"bg_hotel_facade-1.png"];
		return [OHHTTPStubsResponse responseWithFileAtPath:fixture statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeImagePNG}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_room-3.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSString* fixture = [self testFilePath:@"bg_hotel_room-3.png"];
		return [OHHTTPStubsResponse responseWithFileAtPath:fixture statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeImagePNG}];
	}];

	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://mywebservice.com"]];

	AEMAssetSource *assetSource = [factory createAssetSourceWithIdentifier:@"id1" withRootFilePath:localRootPath];

	AEMAssetSourceSyncTask *task = [assetSource syncInBackground:NO];

	AEMTaskListener *taskListener = [[AEMTaskListener alloc] init];
	[task addSuccessListener:taskListener];
	[task addErrorListener:taskListener];
	[task addProgressListener:taskListener];

	[self expectationForNotification:@"AEMAssetSourceSyncTaskCompleted" object:task handler:^BOOL(NSNotification *notification) {
		AEMAssetSourceSyncTask* task = notification.object;
		XCTAssert([task isKindOfClass:AEMAssetSourceSyncTask.class]);
		BOOL isDir = NO;
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:assetSource.rootFilePath isDirectory:&isDir]);
		XCTAssertTrue(isDir);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_room.png"]] checkResourceIsReachableAndReturnError:nil]);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_facade-1.png"]] checkResourceIsReachableAndReturnError:nil]);

		XCTAssertEqual(task.assetsAdded.count, 2);

		return YES;
	}];
	[self waitForExpectationsWithTimeout:1 handler:nil];

	AEMAssetSourceSyncTask *task2 = [assetSource syncInBackground:NO];

	[task2 addSuccessListener:taskListener];
	[task2 addErrorListener:taskListener];
	[task2 addProgressListener:taskListener];

	[self expectationForNotification:@"AEMAssetSourceSyncTaskCompleted" object:task2 handler:^BOOL(NSNotification *notification) {
		AEMAssetSourceSyncTask* task = notification.object;
		XCTAssert([task isKindOfClass:AEMAssetSourceSyncTask.class]);
		BOOL isDir = NO;
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:assetSource.rootFilePath isDirectory:&isDir]);
		XCTAssertTrue(isDir);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_room.png"]] checkResourceIsReachableAndReturnError:nil]);
		XCTAssertFalse([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_facade-1.png"]] checkResourceIsReachableAndReturnError:nil]);
		XCTAssertTrue([[NSURL fileURLWithPath:[assetSource.rootFilePath stringByAppendingPathComponent:@"imgs/bg_hotel_room-3.png"]] checkResourceIsReachableAndReturnError:nil]);

		XCTAssertEqual(task.assetsAdded.count, 1);
		XCTAssertEqual(task.assetsRemoved.count, 1);
		XCTAssertEqual(task.assetsChanged.count, 1);

		return YES;
	}];
	[self waitForExpectationsWithTimeout:1 handler:nil];


	success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:nil];
	XCTAssertTrue(success);
}

- (void)testAEMAssetSourceSyncTaskMissingFile {

	// This test pulls down the same manifest content twice to
	// ensure content is not downloaded twice

	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString* localRootPath = [cachesDirectory stringByAppendingPathComponent:@"contentCache/id1"];

	NSError* fileRemoveError = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:&fileRemoveError];
	XCTAssertTrue(success || ([fileRemoveError.domain isEqualToString:NSCocoaErrorDomain] && fileRemoveError.code == NSFileNoSuchFileError));

	[[NSFileManager defaultManager] createDirectoryAtPath:localRootPath withIntermediateDirectories:YES attributes:nil error:nil];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.host isEqualToString:@"mywebservice.com"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSData* data = [self dataWithContentsOfTestFile:@"manifest.json"];
		return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeApplicationJSON}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_room.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSString* fixture = [self testFilePath:@"bg_hotel_room.png"];
		return [OHHTTPStubsResponse responseWithFileAtPath:fixture statusCode:200 headers:@{@"Content-Type":kHTTPContentTypeImagePNG}];
	}];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
		return [request.URL.path isEqualToString:@"/content/dam/bg_hotel_facade-1.png"];
	} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {

		NSData* data = [self dataWithContentsOfTestFile:@"manifest.json"];
		return [OHHTTPStubsResponse responseWithData:data statusCode:404 headers:@{@"Content-Type":kHTTPContentTypeApplicationJSON}];
	}];

	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://mywebservice.com"]];

	AEMAssetSource *assetSource = [factory createAssetSourceWithIdentifier:@"id1" withRootFilePath:localRootPath];

	AEMAssetSourceSyncTask *task = [assetSource syncInBackground:NO];

	AEMTaskListener *taskListener = [[AEMTaskListener alloc] init];
	[task addSuccessListener:taskListener];
	[task addErrorListener:taskListener];
	[task addProgressListener:taskListener];

	[self expectationForNotification:@"AEMAssetSourceSyncTaskFailed" object:task handler:^BOOL(NSNotification *notification) {
		AEMAssetSourceSyncTask* task = notification.object;
		XCTAssert([task isKindOfClass:AEMAssetSourceSyncTask.class]);
		BOOL isDir = NO;
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:assetSource.rootFilePath isDirectory:&isDir]);
		XCTAssertTrue(isDir);

		XCTAssertEqual(task.assetsAdded.count, 2);

		return YES;
	}];
	[self waitForExpectationsWithTimeout:1000 handler:nil];

	success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:nil];
	XCTAssertTrue(success);
}

- (void)xtestDownloadInBackground {

	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString* localRootPath = [cachesDirectory stringByAppendingPathComponent:@"contentCache"];

	NSError* fileRemoveError = nil;
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:&fileRemoveError];
	XCTAssertTrue(success || ([fileRemoveError.domain isEqualToString:NSCocoaErrorDomain] && fileRemoveError.code == NSFileNoSuchFileError));

	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://pepsi.sea.adobe.com/stage/tmillett/aemmsdk"]];

	[[NSFileManager defaultManager] createDirectoryAtPath:localRootPath withIntermediateDirectories:YES attributes:nil error:nil];


	AEMAssetSource *source = [factory createAssetSourceWithIdentifier:@"hotel1" withRootFilePath:localRootPath];
	AEMAssetSourceSyncTask *task = [source syncInBackground:YES];
	AEMTaskListener *taskListener = [[AEMTaskListener alloc] init];
	[task addSuccessListener:taskListener];
	[task addErrorListener:taskListener];
	[task addProgressListener:taskListener];

	[self expectationForNotification:@"AEMAssetSourceSyncTaskCompleted" object:task handler:^BOOL(NSNotification *notification) {
		AEMAssetSourceSyncTask* task = notification.object;
		XCTAssert([task isKindOfClass:AEMAssetSourceSyncTask.class]);
		BOOL isDir = NO;
		XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:task.assetSource.rootFilePath isDirectory:&isDir]);
		XCTAssertTrue(isDir);

		return YES;
	}];
	[self waitForExpectationsWithTimeout:100 handler:nil];

	success = [[NSFileManager defaultManager] removeItemAtPath:localRootPath error:nil];
	XCTAssertTrue(success);


}



@end
