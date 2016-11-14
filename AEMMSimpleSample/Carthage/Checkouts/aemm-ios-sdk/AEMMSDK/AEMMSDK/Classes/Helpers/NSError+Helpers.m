/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2014 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

#import "NSError+Helpers.h"
#import "HttpHeaders.h"

NSString* const NSUnderlyingExceptionKey = @"underlyingException";
NSString* const UserErrorDomain = @"UserErrorDomain";

//Copied from AFURLResponseSerialization
NSString* const AFURLResponseSerializationErrorDomain = @"com.alamofire.error.serialization.response";
NSString* const AFNetworkingOperationFailingURLResponseErrorKey = @"com.alamofire.serialization.response.error.response";
NSString* const AFNetworkingOperationFailingURLResponseDataErrorKey = @"com.alamofire.serialization.response.error.data";

@implementation NSError (Helpers)

+ (id)errorWithDomain:(NSString*)domain code:(NSInteger)code underlyingError:(NSError*)underlyingError
{
	NSDictionary* userInfo = underlyingError ? [NSDictionary dictionaryWithObject:underlyingError forKey:NSUnderlyingErrorKey] : nil;
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

+ (id)errorWithError:(NSError*)error withAdditionalUserInfo:(NSDictionary*)userInfo
{
	NSMutableDictionary* combinedUserInfo = [error.userInfo mutableCopy];
	[combinedUserInfo addEntriesFromDictionary:userInfo];
	return [NSError errorWithDomain:error.domain code:error.code userInfo:combinedUserInfo];
}

- (NSError*)underlyingError
{
	return [[self userInfo] objectForKey:NSUnderlyingErrorKey];
}

- (NSHTTPURLResponse*)underlyingResponse
{
	NSHTTPURLResponse* response = self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
	ASSERT(response == nil || [response isKindOfClass:NSHTTPURLResponse.class], @"unexpected response class");
	return response;
}

- (NSString*)underlyingResponseError
{
	NSData* responseData = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
	ASSERT(responseData == nil || [responseData isKindOfClass:NSData.class], @"unexpected response data class");
	return [NSString stringWithData:responseData encoding:NSUTF8StringEncoding];
}

- (BOOL)isNetworkError
{
	return [self.domain isEqualToString:kHTTPErrorCodeDomain] && self.underlyingError.code >= 500;
}

- (UserErrorCode)translateToUserErrorWithDefault:(UserErrorCode)defaultErrorCode
{
	UserErrorCode errorCode = defaultErrorCode;
	
	if ([self.domain isEqualToString:NSURLErrorDomain] ||
	   [self.domain isEqualToString:AFURLResponseSerializationErrorDomain])
	{
		switch (self.code)
		{
			case NSURLErrorNetworkConnectionLost:	// -1005
			case NSURLErrorNotConnectedToInternet:	// -1009
			case NSURLErrorCannotFindHost:			// -1003
			{
				errorCode = UserErrorCodeNoInternetConnection;
				break;
			}
			case NSURLErrorBadServerResponse:		// - 1011
			{
				if (self.underlyingResponse.statusCode == kHTTPStatusCode401)
				{
					errorCode = UserErrorCodeInvalidAuthenticationCredentials;
				}
				else if (self.underlyingResponse.statusCode == kHTTPStatusCode404)
				{
					errorCode = UserErrorCodeContentNotFound;
				}
				break;
			}
		}
	}
	else if ([self.domain isEqualToString:UserErrorDomain])
	{
		errorCode = self.code;
	}
	
	return errorCode;
}

- (NSString*)errorStringWithDefaultErrorCode:(UserErrorCode)defaultErrorCode
{
	UserErrorCode errorCode = [self translateToUserErrorWithDefault:defaultErrorCode];
	return [NSError errorStringForUserError:errorCode];
}

+ (NSString*)errorStringForUserError:(UserErrorCode)errorCode
{
	switch (errorCode)
	{
		case UserErrorCodeNoError:
			ASSERT_FAIL(@"UserErrorCode is UserErrorCodeNoError");
			break;
		case UserErrorCodeNoInternetConnection:
			return NSLocalizedStringFromApplication(@"No Internet Connection");
		case UserErrorCodeContentNotFound:
		case UserErrorCodePreviewContentNotFound:
			return NSLocalizedStringFromApplication(@"Content Not Found");
		case UserErrorCodeInvalidAuthenticationCredentials:
			return NSLocalizedStringFromApplication(@"Your username or password is incorrect.");
		case UserErrorCodeSearchResultNotFound:
			return NSLocalizedStringFromApplication(@"No Results Found");
		default:
			ASSERT_FAIL(@"Unknown UserErrorCode");
			break;
	}
	
	return nil;
}

@end
