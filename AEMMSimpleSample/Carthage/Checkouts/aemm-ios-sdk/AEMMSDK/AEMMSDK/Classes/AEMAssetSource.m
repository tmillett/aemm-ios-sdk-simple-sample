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

NSString * const kAEMAssetSourceIdentifierKey = @"identifier";
NSString * const kAEMAssetSourceRelativeCachePathKey = @"relativeCachePath";

@interface AEMAssetSource ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSString *relativeCachePath;
@property (nonatomic, weak) AEMAssetService *assetService;

@end

@implementation AEMAssetSource

+ (instancetype)assetSourceFromDictionary:(NSDictionary *)assetSourceDict withAssetService:(AEMAssetService *)assetService {
	AEMAssetSource *assetSource = nil;
	@try {
		NSLog(@"id: %@ class: %@",assetSourceDict[kAEMAssetSourceIdentifierKey], NSStringFromClass([assetSourceDict[kAEMAssetSourceIdentifierKey] class]));
		assetSource = [[AEMAssetSource alloc] initWithIdentifier:assetSourceDict[kAEMAssetSourceIdentifierKey] withRelativeCachePath:assetSourceDict[kAEMAssetSourceRelativeCachePathKey] withAssetService:assetService];
	} @catch (NSException *exception) {
		NSLog(@"Could not create assetSource with assetSourceDict:%@ exception:%@", assetSourceDict, exception);

	} @finally {
		return assetSource;
	}
}

- (AEMAssetSource *)initWithIdentifier:(NSString *)identifier withRelativeCachePath:(NSString *)relativeCachePath withAssetService:(AEMAssetService *)assetService
{
	if (self = [super init]) {
		if (identifier.length < 1) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"identifier must have a length" userInfo:nil];
		}
		self.identifier = identifier;

		if (![relativeCachePath hasPrefix:@"~/"]) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"relativeCachePath must begin with ~/" userInfo:nil];
		}

		self.relativeCachePath = relativeCachePath;

		NSError *fileIOError = nil;

		NSURL *fileURL = [NSURL fileURLWithPath:[self.relativeCachePath stringByExpandingTildeInPath] isDirectory:YES];
		if (!fileURL || ![fileURL isFileURL] || ![fileURL checkResourceIsReachableAndReturnError:&fileIOError] ) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"relativeCachePath must be reachable" userInfo:nil];
		}


		if (![[NSFileManager defaultManager] createDirectoryAtPath:[self.relativeCachePath stringByExpandingTildeInPath] withIntermediateDirectories:YES attributes:nil error:&fileIOError]) {
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

- (NSString *)existingManifestRelativePath {
	return [self.relativeCachePath stringByAppendingPathComponent:@"manifest.json"];
}

- (NSString *)latestManifestRelativePath {
	return [self.relativeCachePath stringByAppendingPathComponent:@"latestManifest.json"];
}

- (NSDictionary *)toDictionary {
	return @{kAEMAssetSourceIdentifierKey : self.identifier, kAEMAssetSourceRelativeCachePathKey : self.relativeCachePath};
}

#pragma mark - Equality

- (BOOL)isEqualToAssetSource:(AEMAssetSource *)otherSource {
	return	[self.identifier isEqualToString:otherSource.identifier] &&
			[self.relativeCachePath isEqualToString:otherSource.relativeCachePath];
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
	return [self.identifier hash] ^ [self.relativeCachePath hash];
}

@end

NS_ASSUME_NONNULL_END
