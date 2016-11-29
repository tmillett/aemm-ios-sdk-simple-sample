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

#import "AEMAssetSourceFactory.h"
#import "AEMAssetService.h"
#import "AEMAssetSource+Internal.h"
#import "NSPointerArray+Helpers.h"
#import "AEMAssetSourceSyncTask+Internal.h"

NS_ASSUME_NONNULL_BEGIN

@interface AEMAssetSourceFactory ()

@property (nonatomic, strong) NSPointerArray *assetSources;
@property (nonatomic, strong) AEMAssetService *assetService;

@end

@implementation AEMAssetSourceFactory

+ (instancetype)createAssetSourceFactoryWithBaseURL:(NSURL *)url {
	return [[AEMAssetSourceFactory alloc] initWithBaseURL:url];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL {

	if (self = [super init]) {
		self.assetService = [[AEMAssetService alloc] initWithBaseURL:baseURL];
		self.assetSources = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
	}

	return self;
}

- (id)createAssetSourceWithIdentifier:(NSString *)identifier withRelativeCachePath:(NSString *)relativeCachePath {

	AEMAssetSource *assetSource = [[AEMAssetSource alloc] initWithIdentifier:identifier withRelativeCachePath:relativeCachePath withAssetService:self.assetService];
	BOOL foundExisting = NO;
	for (AEMAssetSource *existingSource in self.assetSources) {
		if (existingSource != nil) {
			if ([existingSource isEqual:assetSource]) {
				assetSource = existingSource;
				foundExisting = YES;
				break;
			}
		}
	}

	if (!foundExisting) {
		[self.assetSources addObject:assetSource];
	}

	return assetSource;
}

- (id)createAssetSourceSyncTaskWithBackgroundURLSessionIdentifier:(NSString *)urlSessionIdentifier withBackgroundCompletionHandler:(void (^)())completionHandler {

	AEMAssetSourceSyncTask *syncTask = [AEMAssetSourceSyncTask assetSourceSyncTaskWithSessionIdentifier:urlSessionIdentifier withAssetService:self.assetService];

	syncTask.backgroundTransferCompletionHandler = completionHandler;

	return syncTask;
}

@end

NS_ASSUME_NONNULL_END
