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

#import "JSONHelpers.h"

const NSInteger JSONOperationCouldntBeCompletedErrorCode = 3840;

@implementation NSObject (JSONHelpers)

- (NSString*)JSONRepresentation
{
	NSString* jsonString = nil;
	NSError* error = nil;
	@try
	{
		jsonString = [NSString stringWithData:[NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error] encoding:NSUTF8StringEncoding];
	}
	@catch (NSException *exception)
	{
		ASSERT_FAIL(@"Could not convert NSObject to JSON: %@", exception);
	}
	@finally
	{
		return jsonString;
	}
}

@end


@implementation NSString (JSONHelpers)

- (id)JSONValue
{
	return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

@end

@implementation NSURL (JSONHelpers)

- (id)JSONValue
{
	id jsonObj = nil;
	NSError* error = nil;
	@try
	{
		NSData *jsonData = [[NSData alloc] initWithContentsOfURL:self];
		if (jsonData)
		{
			jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
			
			if (error)
			{
				ASSERT_FAIL(@"Could not convert JSON to id: %@", [error localizedDescription]);
				jsonObj = nil;
			}
		}
	}
	@catch (NSException *exception)
	{
		ASSERT_FAIL(@"Could not convert JSON to id: %@", exception);
	}
	@finally
	{
		return jsonObj;
	}
}

@end


@implementation NSDictionary (JSONHelpers)

- (id)valueForKey:(NSString*)key ofClass:(Class)clazz
{
	id value = [self valueForKey:key];
	if (value == nil || [value isKindOfClass:clazz])
	{
		return value;
	}

	return nil;
}

- (id)valueForKeys:(NSArray*)keys ofClass:(Class)clazz
{
	ASSERT(keys.count, @"list of keys is empty");
	NSDictionary* dict = self;
	for (NSInteger i=0; i<keys.count-1; i++)
	{
		dict = dict[keys[i]];
		if (![dict isKindOfClass:NSDictionary.class])
		{
			return nil;
		}
	}

	return [dict valueForKey:keys.lastObject ofClass:clazz];
}

- (BOOL)isAutoForKey:(NSString*)key
{
	NSString* autoString = [self valueForKey:key ofClass:[NSString class]];
	return autoString && [autoString isEqualToString:@"auto"];
}

@end
