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

#import "AEMAssetSourceSyncTaskDownloadInfo.h"
#import "AEMAssetDownloadInfo.h"
#import "AEMAssetSource+Internal.h"

NS_ASSUME_NONNULL_BEGIN

static const NSString *kAssetsKey = @"assets";
static const NSString *kAssetSourceKey = @"assetSource";

@interface AEMAssetSourceSyncTaskDownloadInfo ()

@property (nonatomic, strong) AEMAssetSource *assetSource;
@property (nonatomic, strong) NSMutableDictionary <NSString *, AEMAssetDownloadInfo *> *assets;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation AEMAssetSourceSyncTaskDownloadInfo

+ (NSString *)cachedAssetDownloadInfosPathForSessionIdentifier:(NSString *)sessionIdentifier {
	NSData *sessionIdentifierData = [sessionIdentifier dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64SessionIdentifier = [sessionIdentifierData base64EncodedStringWithOptions:0];
	NSString *cachedAssetDownloadInfosPath = [self baseFilePathForCachedAssetDownloadInfos];
	return [[cachedAssetDownloadInfosPath stringByAppendingPathComponent:base64SessionIdentifier] stringByAppendingPathExtension:@"json"];
}

+ (NSString *)baseFilePathForCachedAssetDownloadInfos {
	return [NSString stringForPathComponentInCachesDirectory:@"AEMAssetSourceSyncTaskDownloadInfos"];
}

+ (NSMutableDictionary *)loadAssetSourceDownloadInfoFromFilePath:(NSString *)filePath withAssetService:(AEMAssetService *)assetService {

	NSMutableDictionary *assetSourceDownloadInfo = nil;
	NSMutableDictionary *loadedJSON = nil;
	NSError *error = nil;

	NSData *data = [NSData dataWithContentsOfFile:filePath];
	if (data) {
		loadedJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

		NSLog(@"loaded downloadInfo:%@",loadedJSON);

		if (loadedJSON.count) {

			assetSourceDownloadInfo = [NSMutableDictionary dictionary];
			assetSourceDownloadInfo[kAssetSourceKey] = [AEMAssetSource assetSourceFromDictionary:loadedJSON[kAssetSourceKey] withAssetService:assetService];

			NSMutableDictionary *assetDownloadInfos = [NSMutableDictionary dictionaryWithCapacity:loadedJSON.count];
			for (NSString *infoKey in loadedJSON[kAssetsKey]) {
				NSDictionary *info = loadedJSON[kAssetsKey][infoKey];
				assetDownloadInfos[infoKey] = [AEMAssetDownloadInfo assetDownloadInfoFromDict:info];
			}

			assetSourceDownloadInfo[kAssetsKey] = assetDownloadInfos;
		} else {
			ASSERT(error == nil || error.domain == NSCocoaErrorDomain && error.code == NSFileNoSuchFileError, @"error when reading assetDownloadInfo");
		}
	}

	return assetSourceDownloadInfo;
}

+ (instancetype)assetSourceSyncTaskDownloadInfoWithSessionIdentifier:(NSString *)sessionIdentifier withAssetService:(AEMAssetService *)assetService {
	NSString *filePath = [self.class cachedAssetDownloadInfosPathForSessionIdentifier:sessionIdentifier];
	NSMutableDictionary *assetSourceDownloadInfo = [self.class loadAssetSourceDownloadInfoFromFilePath:filePath withAssetService:assetService];

	if (assetSourceDownloadInfo) {
		AEMAssetSourceSyncTaskDownloadInfo *info = [[AEMAssetSourceSyncTaskDownloadInfo alloc] init];
		info.assetSource = assetSourceDownloadInfo[kAssetSourceKey];
		info.assets = assetSourceDownloadInfo[kAssetsKey];
		info.filePath = filePath;
		return info;
	} else {
		return nil;
	}
}

+ (instancetype)assetSourceSyncTaskDownloadInfoWithSessionIdentifier:(NSString *)sessionIdentifier withAssetSource:(AEMAssetSource *)assetSource {

	NSString *filePath = [self.class cachedAssetDownloadInfosPathForSessionIdentifier:sessionIdentifier];

	AEMAssetSourceSyncTaskDownloadInfo *info = [[AEMAssetSourceSyncTaskDownloadInfo alloc] init];
	info.assetSource = assetSource;
	info.assets = [NSMutableDictionary dictionary];
	info.filePath = filePath;
	return info;

}

- (AEMAssetDownloadInfo *)assetInfoForKey:(NSString *)assetInfoKey {
	return self.assets[assetInfoKey];
}

- (void)setAssetInfo:(AEMAssetDownloadInfo *)assetInfo forKey:(NSString *)assetInfoKey {
	self.assets[assetInfoKey] = assetInfo;
}

- (NSArray <AEMAssetDownloadInfo *> *)allAssets {
	return [self.assets allValues];
}

- (NSArray <NSString *> *)allAssetKeys {
	return [self.assets allKeys];
}

- (void)save {
	NSMutableDictionary *assetSourceDownloadInfo = [NSMutableDictionary dictionary];

	assetSourceDownloadInfo[kAssetSourceKey] = [self.assetSource toDictionary];

	NSMutableDictionary *assetDownloadInfos = [NSMutableDictionary dictionaryWithCapacity:self.assets.count];
	for (NSString *infoKey in self.assets) {
		AEMAssetDownloadInfo *info = self.assets[infoKey];
		assetDownloadInfos[infoKey] = [info toDictionary];
	}

	assetSourceDownloadInfo[kAssetsKey] = assetDownloadInfos;
	NSString *assetDownloadInfosJSON = [assetSourceDownloadInfo JSONRepresentation];

	NSError *fileError = nil;

	if (![[NSFileManager defaultManager] createDirectoryAtPath:[self.filePath stringByDeletingLastPathComponent]  withIntermediateDirectories:YES attributes:nil error:&fileError]) {

		//TODO: Handle error
		if (![fileError.domain isEqualToString:NSCocoaErrorDomain] ||
			fileError.code == NSFileWriteFileExistsError) {
			ASSERT_FAIL(@"%@", fileError);
		}
	}

	BOOL jsonSuccess = [assetDownloadInfosJSON writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:&fileError];

	//TODO: Handle error
	if (!jsonSuccess) {
		ASSERT_FAIL(@"%@", fileError);
	}

}

- (void)remove {

	NSError *error = nil;
	if (![[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error]) {
		//TODO: Handle error
		ASSERT_FAIL(@"%@", error);
	}
}

@end

NS_ASSUME_NONNULL_END
