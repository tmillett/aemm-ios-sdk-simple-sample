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

NSString * const kAEMAssetDownloadInfoVersionKey = @"version";
NSString * const kAEMAssetDownloadInfoLocalPathKey = @"localPath";
NSString * const kAEMAssetDownloadInfoRemoteURLKey = @"remoteURL";
NSString * const kAEMAssetDownloadInfoDownloadCompleteKey = @"downloadComplete";
NSString * const kAEMAssetDownloadInfoTaskIdentifierKey = @"taskIdentifier";
NSString * const kAEMAssetDownloadInfoTaskSessionIdentifierKey = @"sessionIdentifier";

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

- (instancetype)initWithDictionary:(NSDictionary *)dict {

	if (self = [super init]) {

		self.version = [dict[kAEMAssetDownloadInfoVersionKey] integerValue];
		self.taskIdentifier = [dict[kAEMAssetDownloadInfoTaskIdentifierKey] integerValue] ?: -1;
		self.remoteURL = [NSURL URLWithString:dict[kAEMAssetDownloadInfoRemoteURLKey]];
		self.localPath = dict[kAEMAssetDownloadInfoLocalPathKey];
		self.sessionIdentifier = dict[kAEMAssetDownloadInfoTaskSessionIdentifierKey];
	}

	return self;
}

- (NSDictionary *)toDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];

	dict[kAEMAssetDownloadInfoVersionKey] = @(self.version);
	dict[kAEMAssetDownloadInfoTaskIdentifierKey] = @(self.taskIdentifier);
	dict[kAEMAssetDownloadInfoLocalPathKey] = self.localPath;
	dict[kAEMAssetDownloadInfoRemoteURLKey] = [self.remoteURL absoluteString];
	dict[kAEMAssetDownloadInfoDownloadCompleteKey] = @(self.downloadComplete);
	dict[kAEMAssetDownloadInfoTaskSessionIdentifierKey] = self.sessionIdentifier;


	return dict;
}

@end

NS_ASSUME_NONNULL_END
