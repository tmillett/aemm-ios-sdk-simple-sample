/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2016 Adobe Systems Incorporated
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

#import "AEMTask+Internal.h"
#import "NSPointerArray+Helpers.h"
#import "AEMTaskSuccessListener.h"
#import "AEMTaskErrorListener.h"
#import "AEMTaskProgressListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface AEMTask ()

@property (nonatomic, strong) NSPointerArray *successListeners;
@property (nonatomic, strong) NSPointerArray *errorListeners;
@property (nonatomic, strong) NSPointerArray *progressListeners;
@property (nonatomic, assign) BOOL taskDidSucceed;
@property (nonatomic, strong) NSError *taskCompletedError;

@end

@implementation AEMTask

- (instancetype)init {

	if (self = [super init]) {
		self.successListeners = [NSPointerArray weakObjectsPointerArray];
		self.errorListeners = [NSPointerArray weakObjectsPointerArray];
		self.progressListeners = [NSPointerArray weakObjectsPointerArray];
	}

	return self;
}

- (instancetype)addSuccessListener:(id<AEMTaskSuccessListener>)successListener {

	[self.successListeners addObject:successListener];

	if (self.taskDidSucceed) {
		dispatch_async(dispatch_get_main_queue(), ^() {
			[successListener taskDidComplete:self];
		});
	}

	return self;
}

- (instancetype)addErrorListener:(id<AEMTaskErrorListener>)errorListener {

	[self.errorListeners addObject:errorListener];

	if (self.taskCompletedError) {
		dispatch_async(dispatch_get_main_queue(), ^() {
			[errorListener task:self didCompleteWithError:self.taskCompletedError];
		});
	}

	return self;
}

- (instancetype)addProgressListener:(id<AEMTaskProgressListener>)progressListener {

	[self.progressListeners addObject:progressListener];

	return self;
}

- (instancetype)removeSuccessListener:(id<AEMTaskSuccessListener>)successListener {

	[self.successListeners removeObject:successListener];

	return self;
}

- (instancetype)removeErrorListener:(id<AEMTaskErrorListener>)errorListener {

	[self.errorListeners removeObject:errorListener];

	return self;
}

- (instancetype)removeProgressListener:(id<AEMTaskProgressListener>)progressListener {

	[self.progressListeners removeObject:progressListener];

	return self;
}

- (void)notifyListenersAboutSuccess {

	ASSERT(!self.taskDidSucceed && !self.taskCompletedError, @"task has already succeeded/failed");

	self.taskDidSucceed = YES;

	dispatch_async(dispatch_get_main_queue(), ^() {
		for (id<AEMTaskSuccessListener> successListener in self.successListeners) {
			if (successListener != nil) {
				[successListener taskDidComplete:self];
			}
		}
	});
}

- (void)notifyListenersAboutError:(NSError *)error {

	ASSERT(!self.taskDidSucceed && !self.taskCompletedError, @"task has already succeeded/failed");

	self.taskCompletedError = error;

	dispatch_async(dispatch_get_main_queue(), ^() {
		for (id<AEMTaskErrorListener> errorListener in self.successListeners) {
			if (errorListener != nil) {
				[errorListener task:self didCompleteWithError:error];
			}
		}
	});
}

- (void)notifyListenersAboutProgress:(NSUInteger)progress {

	dispatch_async(dispatch_get_main_queue(), ^() {
		for (id<AEMTaskProgressListener> progressListener in self.successListeners) {
			if (progressListener != nil) {
				[progressListener task:self didSendProgress:progress];
			}
		}
	});
}

@end

NS_ASSUME_NONNULL_END
