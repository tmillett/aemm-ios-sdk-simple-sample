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

#import <Foundation/Foundation.h>

@interface NSPointerArray(Helpers)

/** @return YES if the object is already in the array
 */
- (BOOL)containsObject:(id)anObject;

/** Insert in front the object if it is not already in the array, otherwise do nothing
 */
- (void)insertObject:(id)anObject;

/** Add the object if it is not already in the array, otherwise do nothing
*/
- (void)addObject:(id)anObject;

/** Remove the object if it is in the array, otherwise do nothing
*/
- (void)removeObject:(id)anObject;

/** Remove any and all objects in the array
 */
- (void)removeAllObjects;

/** Remove any and all nil pointers in the array
 */
- (void)removeNilPointers;

/** @return the index of the object in the array, or NSNotFound
 */
- (NSUInteger)indexOfObject:(id)anObject;

/** @return the object in the array at the specified index, or nil
 */
- (id)objectAtIndex:(NSUInteger)index;

/** Apply the block to each object in the array
 */
- (void)enumerateObjectsUsingBlock:(void (^)(id obj))block;

@end
