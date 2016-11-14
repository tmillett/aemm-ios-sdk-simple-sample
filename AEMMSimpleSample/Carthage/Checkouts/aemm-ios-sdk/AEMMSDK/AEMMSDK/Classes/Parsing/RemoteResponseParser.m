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

#import "RemoteResponseParser+Internal.h"

@interface RemoteResponseParser ()

//implement Internal properties
@property (nonatomic) BOOL ignoreSomeErrors;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSError* error;
@property (nonatomic, strong) NSMutableArray* parsedObjects;
@property (atomic, assign) BOOL hasBeenQueued;
@property (nonatomic, strong) NSHTTPURLResponse* response;

@end

@implementation RemoteResponseParser

- (instancetype)init
{
	if (self = [super init])
	{
		self.parsedObjects = [NSMutableArray array];
	}
	return self;
}

- (instancetype)initWith:(id)responseObject completionBlock:(RemoteResponseParserCompletionBlock)completionBlock
{
	if (self = [self init])
	{
		[self updateWithResponse:nil responseObject:responseObject completionBlock:completionBlock];
	}
	return self;
}

- (void)updateWithResponse:(NSHTTPURLResponse*)response responseObject:(id)responseObject completionBlock:(RemoteResponseParserCompletionBlock)completionBlock;
{
	self.response = response;
	self.responseObject = responseObject;
	[self internalCompletionBlock:completionBlock];
}

- (void)main
{
	ASSERT_OVERRIDDEN();
}

- (void)internalCompletionBlock:(void (^)(NSArray* parseArray, NSError* error))completionBlock
{
	if (completionBlock)
	{
		void (^externalCompletionBlock)(NSArray* parseArray, NSError* error) = [completionBlock copy];
		
		super.completionBlock = ^{
			ASSERT(self.isFinished, @"expected operation to be finished before completion block is invoked");
			ASSERT(![NSThread isMainThread], @"did not expect internal completion block to be called on the main thread");
			
			//Dispatch on main thread because most completion blocks access the main managedObjectContext
			dispatch_async(dispatch_get_main_queue(), ^{
				if (self.error)
				{
					externalCompletionBlock(nil, self.error);
				}
				else if (self.isCancelled)
				{
					NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
					externalCompletionBlock(nil, error);
				}
				else
				{
					externalCompletionBlock(self.parsedObjects, nil);
				}
			});
			
			//release completionBlock because it captures self
			super.completionBlock = nil;
		};
	}
}

@end
