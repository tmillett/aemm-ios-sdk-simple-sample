/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2015 Adobe Systems Incorporated
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

#import "RemoteResponseParser.h"
#import "JSONHelpers.h"

@interface JSONRemoteResponseParser : RemoteResponseParser

/**
	Parse a dictionary
	@param responseDict - The dictionary to parse
	@param error - The error that will be populated iff an error occurs
	@return the parsed dictionary, or nothing in case of an error
 */
- (NSDictionary*)parseDict:(NSDictionary*)responseDict withError:(NSError**)error;

/**	Return an appropriate error for the case where a required value is missing
	from the parsed dict.
	@param key is the key for the required value
	@return an error
 */
- (NSError*)missingRequiredValueErrorForKey:(NSString*)key;

/**	Return an appropriate error for the case where a required value is missing
	from the parsed dict.
	@param key is a nil-terminated list of the keys for the required value
	@return an error
 */
- (NSError*)missingRequiredValueErrorForKeys:(NSString*)key,...;

@end
