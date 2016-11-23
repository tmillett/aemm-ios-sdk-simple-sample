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

#import "AEMAssetSource+Internal.h"
#import "AEMAssetSourceSyncTask+Internal.h"
#import "AEMAssetService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AEMAssetSource ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *rootFilePath;
@property (nonatomic, weak) AEMAssetService *assetService;

@end

@implementation AEMAssetSource

+ (instancetype)assetSourceFromDictionary:(NSDictionary *)assetSourceDict withAssetService:(AEMAssetService *)assetService {
	AEMAssetSource *assetSource = nil;
	@try {
		assetSource = [[AEMAssetSource alloc] initWithIdentifier:assetSourceDict[@"identifier"] withRootFilePath:assetSourceDict[@"rootFilePath"] withAssetService:assetService];
	} @catch (NSException *exception) {

	} @finally {
		return assetSource;
	}
}

- (AEMAssetSource *)initWithIdentifier:(NSString *)identifier withRootFilePath:(NSString *)rootFilePath withAssetService:(AEMAssetService *)assetService
{
	if (self = [super init]) {
		if (identifier.length < 1) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"identifier must have a length" userInfo:nil];
		}
		self.identifier = identifier;

		NSError *fileIOError = nil;

		NSURL *fileURL = [NSURL fileURLWithPath:rootFilePath];
		if (!fileURL || ![fileURL isFileURL] || ![fileURL checkResourceIsReachableAndReturnError:&fileIOError] ) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"rootFilePath must be reachable" userInfo:nil];
		}
		self.rootFilePath = rootFilePath;

		if (![[NSFileManager defaultManager] createDirectoryAtPath:self.rootFilePath withIntermediateDirectories:YES attributes:nil error:&fileIOError]) {
			//TODO: Handle error
			ASSERT_FAIL(@"");
		}
		
		self.assetService = assetService;
	}

	return self;
}

- (AEMAssetSourceSyncTask *)syncInBackground:(BOOL)inBackground {
	return [[AEMAssetSourceSyncTask alloc] initWithAssetSource:self inBackground:inBackground];
}

- (NSString *)existingManifestPath {
	return [self.rootFilePath stringByAppendingPathComponent:@"manifest.json"];
}

- (NSString *)latestManifestPath {
	return [self.rootFilePath stringByAppendingPathComponent:@"latestManifest.json"];
}

- (NSDictionary *)toDictionary {
	return @{@"identifier" : self.identifier, @"rootFilePath" : self.rootFilePath};
}

#pragma mark - Equality

- (BOOL)isEqualToAssetSource:(AEMAssetSource *)otherSource {
	return	[self.identifier isEqualToString:otherSource.identifier] &&
			[self.rootFilePath isEqualToString:otherSource.rootFilePath];
}

- (BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}

	if (![object isKindOfClass:[self class]]) {
		return NO;
	}

	return [self isEqualToAssetSource:(AEMAssetSource *)object];
}

- (NSUInteger)hash {
	return [self.identifier hash] ^ [self.rootFilePath hash];
}

@end

NS_ASSUME_NONNULL_END
