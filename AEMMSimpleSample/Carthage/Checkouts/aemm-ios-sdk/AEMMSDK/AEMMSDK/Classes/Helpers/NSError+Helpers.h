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

// A recommended key for embedding NSExceptions from underlying calls in userInfo. The value of this key should be an NSException.
extern NSString* const NSUnderlyingExceptionKey;

// The error domain for User Errors
extern NSString* const UserErrorDomain;

typedef NS_ENUM(NSUInteger, UserErrorCode)
{
	UserErrorCodeNoError,
	UserErrorCodeNoInternetConnection,
	UserErrorCodeContentNotFound,
	UserErrorCodePreviewContentNotFound,
	UserErrorCodeInvalidAuthenticationCredentials,
	UserErrorCodeSearchResultNotFound
};

@interface NSError (Helpers)

/* Initializer. Domain cannot be nil; underlyingError may be nil if no userInfo desired.
 */
+ (id)errorWithDomain:(NSString*)domain code:(NSInteger)code underlyingError:(NSError*)underlyingError;

/** @return a new error with the same domain and code as the error parameter, combined with the additional userInfo parameter.
	If keys match then the userInfo key will override.
 */
+ (id)errorWithError:(NSError*)error withAdditionalUserInfo:(NSDictionary*)userInfo;

/** @return the value of the NSUnderlyingErrorKey from the userInfo dictionary.
	Returns nil if the dictionary does not exist or if the key is not found.
 */
- (NSError*)underlyingError;

/** @return the value of the http response key from the userInfo dictionary.
	Returns nil if the dictionary does not exist or if the key is not found.
 */
- (NSHTTPURLResponse*)underlyingResponse;

/** @return the value of the http response error from the userInfo dictionary.
	Returns nil if the dictionary does not exist or if the key is not found.
 */
- (NSString*)underlyingResponseError;

/** @return true if this error represents a networking error of any sort. 
 */
- (BOOL)isNetworkError;

/** @return the user-facing error code that corresponds to this internal error
	@param defaultErrorCode will be returned for internal errors that don't have an associated user error
 */
- (UserErrorCode)translateToUserErrorWithDefault:(UserErrorCode)defaultErrorCode;

/** @return the standard localized error string for user-facing error code that corresponds to this internal error
	@param defaultErrorCode will be used for internal errors that don't have an associated user error
 */
- (NSString*)errorStringWithDefaultErrorCode:(UserErrorCode)defaultErrorCode;

/** @return the standard localized error string for a user error
	@param errorCode is the user error
 */
+ (NSString*)errorStringForUserError:(UserErrorCode)errorCode;

@end
