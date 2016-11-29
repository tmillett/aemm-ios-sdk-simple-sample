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

#import <AEMMSDK/AEMMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class AEMAssetService;

@interface AEMAssetSource (Internal)

+ (instancetype)assetSourceFromDictionary:(NSDictionary *)assetSourceDict withAssetService:(AEMAssetService *)assetService;

- (AEMAssetSource *)initWithIdentifier:(NSString *)identifier withRelativeCachePath:(NSString *)relativeCachePath withAssetService:(AEMAssetService *)assetService;

- (NSURLSession *)createURLSessionInBackground:(BOOL)inBackground;

@property (nonatomic, weak, readonly) AEMAssetService *assetService;
@property (nonatomic, strong, readonly) NSURL *manifestURL;
@property (nonatomic, readonly) NSString *existingManifestRelativePath;
@property (nonatomic, readonly) NSString *latestManifestRelativePath;
@property (nonatomic, readonly) NSString *relativeCachePath;

- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
