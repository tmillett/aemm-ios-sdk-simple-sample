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

#import "AEMAssetSourceManifestResponseParser.h"

@implementation AEMAssetSourceManifestResponseParser

- (NSDictionary*)parseDict:(NSDictionary*)responseDict withError:(NSError**)error {

//	NSDictionary* superDict = [super parseDict:responseDict withError:error];
//	if (superDict == nil || (error && *error)) {
//		return nil;
//	}
//
//	NSMutableDictionary* parsedDict = [superDict mutableCopy];

	NSMutableDictionary *parsedDict = [NSMutableDictionary dictionary];

	NSArray *rawAssets = [responseDict valueForKey:@"assets" ofClass:NSArray.class];
	if (rawAssets)
	{
		NSMutableArray *assets = [NSMutableArray arrayWithCapacity:rawAssets.count];
		for (NSDictionary *rawAsset in rawAssets) {
			[assets addObject:[self parseRawAsset:rawAsset]];
		}
		parsedDict[@"assets"] = assets;
	}

	return parsedDict;
}

- (NSDictionary *)parseRawAsset:(NSDictionary *)rawAsset {

	NSMutableDictionary *asset = [NSMutableDictionary dictionaryWithCapacity:rawAsset.count];

	asset[@"url"] = rawAsset[@"url"];
	asset[@"length"] = rawAsset[@"length"];
	asset[@"md5"] = rawAsset[@"mD5"] ?: rawAsset[@"md5"];
	asset[@"localPath"] = rawAsset[@"localpath"] ?: rawAsset[@"localPath"];

	return asset;
}

@end
