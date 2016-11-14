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

extern const NSInteger JSONOperationCouldntBeCompletedErrorCode;

@interface NSObject (JSONHelpers)

/**
 Will attempt to serialize an object into JSON.
 If serialization fails an exception will be caught and nil will be returned
 */
- (NSString*)JSONRepresentation;

@end

#pragma mark JSON Parsing


@interface NSString (JSONHelpers)

/**
 Will attempt to create a Foundation object from a UTF-8 encoded string.
 If creation fails it will return nil.
 */
- (id)JSONValue;

@end

@interface NSURL (JSONHelpers)

/**
 Will attempt to create a Foundation object from a URL.
 If creation fails it will return nil.
 */
- (id)JSONValue;

@end

@interface NSDictionary (JSONHelpers)

/**
 Return the value for the specified key if it exists AND is of the specified class, otherwise nil
 */
- (id)valueForKey:(NSString*)key ofClass:(Class)clazz;

/** Return the value for the last key in the array keys after traversing the contained dictionaries.
 */
- (id)valueForKeys:(NSArray*)keys ofClass:(Class)clazz;

/**
 Return YES if the value of the specified key is @"auto"
 */
- (BOOL)isAutoForKey:(NSString*)key;

@end
