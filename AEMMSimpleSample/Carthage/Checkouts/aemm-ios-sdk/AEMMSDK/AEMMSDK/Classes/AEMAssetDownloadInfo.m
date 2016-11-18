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

#import "AEMAssetDownloadInfo.h"

NS_ASSUME_NONNULL_BEGIN

static NSString* const kAEMAssetDownloadInfoVersionKey = @"version";
static NSString* const kAEMAssetDownloadInfoLocalPathKey = @"localPath";
static NSString* const kAEMAssetDownloadInfoRemoteURLKey = @"remoteURL";
static NSString* const kAEMAssetDownloadInfoDownloadCompleteKey = @"downloadComplete";
static NSString* const kAEMAssetDownloadInfoTaskIdentifierKey = @"taskIdentifier";

static NSInteger const kCurrentVersion = 0;

@interface AEMAssetDownloadInfo ()

@property (nonatomic, assign) NSInteger version;

@end

@implementation AEMAssetDownloadInfo

+ (instancetype)assetDownloadInfoFromDict:(NSDictionary *)dict {
	return [[self.class alloc] initWithDictionary:dict];
}

- (instancetype)init {

	if (self = [super init]) {

		self.version = kCurrentVersion;
		self.taskIdentifier = -1;
	}

	return self;
}

- (instancetype)initFromDictionary:(NSDictionary *)dict {

	if (self = [super init]) {

		self.version = [dict[kAEMAssetDownloadInfoVersionKey] integerValue];
		self.taskIdentifier = [dict[kAEMAssetDownloadInfoTaskIdentifierKey] integerValue] ?: -1;
		self.remoteURL = dict[kAEMAssetDownloadInfoRemoteURLKey];
		self.localPath = dict[kAEMAssetDownloadInfoLocalPathKey];
	}

	return self;
}

- (NSDictionary *)toDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];

	dict[kAEMAssetDownloadInfoVersionKey] = @(self.version);
	dict[kAEMAssetDownloadInfoLocalPathKey] = self.localPath;
	dict[kAEMAssetDownloadInfoRemoteURLKey] = self.remoteURL;
	dict[kAEMAssetDownloadInfoDownloadCompleteKey] = @(self.downloadComplete);


	return dict;
}

@end

NS_ASSUME_NONNULL_END
