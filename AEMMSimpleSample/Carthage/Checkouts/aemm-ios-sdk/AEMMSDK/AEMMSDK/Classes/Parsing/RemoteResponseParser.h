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

typedef void (^RemoteResponseParserCompletionBlock)(NSArray* parseArray, NSError* error);

@interface RemoteResponseParser : NSOperation

/** @return the raw HTTP resonse
 */
@property (nonatomic, strong, readonly) NSHTTPURLResponse* response;

/** @return a new response parser
	@param responseObject - the data to parse
	@param completionBlock - the block to call when parsing is completed; will be invoked on the main thread
 */
- (instancetype)initWith:(id)responseObject completionBlock:(RemoteResponseParserCompletionBlock)completionBlock;

/** Update the response parser
	@param response - the raw response
	@param responseObject - the data to parse
	@param completionBlock - the block to call when parsing is completed; will be invoked on the main thread
 */
- (void)updateWithResponse:(NSHTTPURLResponse*)response responseObject:(id)responseObject completionBlock:(RemoteResponseParserCompletionBlock)completionBlock;


@end

#ifdef DEBUG

@interface RemoteResponseParser (Testing)

/** If set to YES, parser will ignore some errors.
*/
@property (nonatomic, readonly) BOOL ignoreSomeErrors;

@end

#endif
