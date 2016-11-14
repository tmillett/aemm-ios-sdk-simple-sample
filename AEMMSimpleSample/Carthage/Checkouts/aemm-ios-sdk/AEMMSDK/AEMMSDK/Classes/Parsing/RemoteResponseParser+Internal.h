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

@interface RemoteResponseParser (Internal)

/** @return the response data to parse
 */
@property (nonatomic, strong) id responseObject;

/** @return the current parse error, or nil if none
 */
@property (nonatomic, strong) NSError* error;

/** @return the parsed objects
 */
@property (nonatomic, strong) NSMutableArray* parsedObjects;

/** If set to YES, parser will ignore some errors.
 */
@property (nonatomic, assign) BOOL ignoreSomeErrors;

/** Do set to YES when adding parser to a queue
 */
@property (atomic, assign) BOOL hasBeenQueued;

@end

//NB Properties declared here (in the Internal category) must be re-declared in the .m file
