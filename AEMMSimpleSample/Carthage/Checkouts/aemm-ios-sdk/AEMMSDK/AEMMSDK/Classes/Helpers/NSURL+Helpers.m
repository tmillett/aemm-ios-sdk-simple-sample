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

BOOL fileResourceExists(NSURL* fileURL)
{
	NSError* fileError = nil;
	return [fileURL checkResourceIsReachableAndReturnError:&fileError] && fileError == nil;
}

BOOL fileResourceDoesntExist(NSURL* fileURL)
{
	NSError* fileError = nil;
	return ![fileURL checkResourceIsReachableAndReturnError:&fileError] && [fileError.underlyingError code] == ENOENT; /* No such file or directory*/
}

@implementation NSURL (Helpers)

- (NSDictionary*) queryDictionary
{
    return [self queryDictionaryWithXMLEncoding:NO];
}

- (NSDictionary*) queryDictionaryWithXMLEncoding:(BOOL)xmlEncoding
{
	NSArray* queryComponents = [self.query componentsSeparatedByString:@"&"];
	
	if (queryComponents && queryComponents.count > 0)
	{
		NSMutableDictionary* outDict = [NSMutableDictionary dictionaryWithCapacity:queryComponents.count];
		
		for (NSString* component in queryComponents)
		{
			NSArray* argComponents = [component componentsSeparatedByString:@"="];
			if (argComponents && argComponents.count == 2)
			{
				NSString * key = (__bridge_transfer NSString*) CFURLCreateStringByReplacingPercentEscapes (NULL,
																						  (CFStringRef) [argComponents objectAtIndex:0],
																						  CFSTR(""));
				
				NSString * val = (__bridge_transfer NSString*) CFURLCreateStringByReplacingPercentEscapes (NULL,
																						  (CFStringRef) [argComponents objectAtIndex:1],
																						  CFSTR(""));
				if (key && val)
				{
                    if (xmlEncoding)
                    {
                        [outDict setObject:[NSString encodeForXML:val] forKey:[NSString encodeForXML:key]];
                    }
                    else
                    {
                        [outDict setObject:val forKey:key];                    
                    }
				}
			}
		}
		return outDict;
	}	
	
	return nil;
}

- (BOOL)isEqualToAEMURL:(NSURL*)otherURL
{
	return [[self absoluteURL] isEqual:[otherURL absoluteURL]] ||
	([self isFileURL] && [otherURL isFileURL] &&
	([[self path] isEqual:[otherURL path]]));
}

- (BOOL)isValidCustomURL:(NSString*)scheme hosts:(NSArray*)hostList
{
    BOOL isValidURL = YES;
    
    if (scheme && self.scheme)
    {
        isValidURL = [self.scheme isEqualToString:scheme];
    }
    
    if (isValidURL && [hostList count] > 0 && self.host)
    {
        isValidURL = [hostList containsObject:self.host];
    }
    
    return isValidURL;
}

- (NSString*)stringFromFinalFragment
{
	return [self.baseURL.lastPathComponent stringByAppendingFormat:@"/%@", self.relativeString];
}

@end
