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

#import <Foundation/Foundation.h>

@class AEMAssetSource;
@class AEMAssetService;

NS_ASSUME_NONNULL_BEGIN

@interface AEMAssetSourceSyncTaskDownloadInfo : NSObject

+ (instancetype)assetSourceSyncTaskDownloadInfoWithSessionIdentifier:(NSString *)sessionIdentifier withAssetService:(AEMAssetService *)assetService;

+ (instancetype)assetSourceSyncTaskDownloadInfoWithSessionIdentifier:(NSString *)sessionIdentifier withAssetSource:(AEMAssetSource *)assetSource;

@property (nonatomic, strong, readonly) AEMAssetSource *assetSource;
@property (nonatomic, strong, readonly) NSMutableDictionary *assets;

- (void)save;

- (void)remove;

NS_ASSUME_NONNULL_END

@end
