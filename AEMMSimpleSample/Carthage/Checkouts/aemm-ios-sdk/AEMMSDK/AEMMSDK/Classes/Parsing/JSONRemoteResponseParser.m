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

#import "JSONRemoteResponseParser.h"
#import "RemoteResponseParser+Internal.h"

@implementation JSONRemoteResponseParser

- (void)main
{
	if (self.responseObject)
	{
		ASSERT([self.responseObject isKindOfClass:NSDictionary.class], @"responseObject is unexpected class");
		
		NSError* error = nil;
		NSDictionary* dict = [self parseDict:self.responseObject withError:&error];
		
		if (error)
		{
			self.error = error;
		}
		else if (dict)
		{
			[self.parsedObjects addObject:dict];
		}
	}
	else
	{
		self.error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotParseResponse userInfo:nil];
	}
}

- (NSDictionary*)parseDict:(NSDictionary*)responseDict withError:(NSError**)error
{
	ASSERT_OVERRIDDEN();
	return nil;
}

- (NSError*)missingRequiredValueErrorForKey:(NSString*)key
{
	return [self missingRequiredValueErrorForKeys:key, nil];
}

- (NSError*)missingRequiredValueErrorForKeys:(NSString*)key,...
{
	NSMutableString* keyList = [NSMutableString stringWithString:key];
	id nextKey = nil;
	va_list argsList;
	va_start(argsList,key);
	while ((nextKey = va_arg(argsList, id)))
	{
		[keyList appendFormat:@" : %@", nextKey];
	}
	va_end(argsList);
	return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotParseResponse userInfo:
			[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Missing required value for key %@", keyList]
										forKey:NSLocalizedFailureReasonErrorKey]];
}

@end
