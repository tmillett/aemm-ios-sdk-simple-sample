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

#import "AEMAssetService.h"
#import "AEMAssetSource+Internal.h"
#import "AEMAssetSourceManifestResponseParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AEMAssetService ()

@property (nonatomic, strong) NSURL *baseURL;

@end

@implementation AEMAssetService

- (instancetype)initWithBaseURL:(NSURL *)baseURL {

	if (self = [super init]) {
		if (baseURL == nil) {
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"baseURL must not be nil" userInfo:nil];
		}
		self.baseURL = baseURL;
	}

	return self;
}

- (NSURLSession*)createURLSessionWithIdentifier:(NSString *)identifier inBackground:(BOOL)inBackground withDelegate:(id<NSURLSessionDelegate>)sessionDelegate {

	NSURLSessionConfiguration *urlSessionConfiguration = nil;
	if (inBackground) {
		urlSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
	} else {
		urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
	}

/*
 // Configuring caching behavior for the default session
	NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
	NSString *cachePath = [cachesDirectory stringByAppendingPathComponent:@"MyCache"];

	NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
	urlSessionConfiguration.URLCache = cache;
	urlSessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
 */

	return [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:sessionDelegate delegateQueue:nil];
}

- (RemoteResponseParser *)createManifestParser {
	return [[AEMAssetSourceManifestResponseParser alloc] init];
}



@end

NS_ASSUME_NONNULL_END
