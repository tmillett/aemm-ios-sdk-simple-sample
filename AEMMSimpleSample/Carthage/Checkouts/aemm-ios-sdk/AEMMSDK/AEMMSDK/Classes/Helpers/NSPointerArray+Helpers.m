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

#import "NSPointerArray+Helpers.h"

@implementation NSPointerArray(Helpers)

- (BOOL)containsObject:(id)anObject
{
	return [self indexOfObject:anObject] != NSNotFound;
}

- (void)insertObject:(id)anObject
{
	if (![self containsObject:anObject])
	{
		[self insertPointer:(__bridge void*)anObject atIndex:0];
	}
}

- (void)addObject:(id)anObject
{
	[self addPointer:(__bridge void*)anObject];
}

- (void)removeObject:(id)anObject
{
	NSUInteger index = [self indexOfObject:anObject];
	if (index != NSNotFound)
	{
		[self removePointerAtIndex:index];
	}
}

- (void)removeAllObjects
{
	while (self.count > 0)
	{
		[self removePointerAtIndex:self.count - 1];
	}
}

- (void)removeNilPointers
{
	//Remove nil pointers manually because compact method doesn't seem to work
	NSUInteger pointerIndex = self.count;
	while (pointerIndex > 0)
	{
		--pointerIndex;
		
		if ([self pointerAtIndex:pointerIndex] == nil)
		{
			[self removePointerAtIndex:pointerIndex];
		}
	}
}

- (NSUInteger)indexOfObject:(id)anObject
{
	for (NSUInteger index = 0; index < self.count; ++index)
	{
		if (anObject == [self pointerAtIndex:index])
		{
			return index;
		}
	}
	return NSNotFound;
}

- (id)objectAtIndex:(NSUInteger)index
{
	return (__bridge id)[self pointerAtIndex:index];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj))block
{
	for (NSUInteger index = 0; index < self.count; ++index)
	{
		block((__bridge id)[self pointerAtIndex:index]);
	}
}

@end
