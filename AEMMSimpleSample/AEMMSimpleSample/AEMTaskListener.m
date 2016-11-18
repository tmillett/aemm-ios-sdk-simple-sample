//
//  AEMTaskListener.m
//  AEMMSimpleSample
//
//  Created by tmillett on 11/16/16.
//  Copyright © 2016 Adobe. All rights reserved.
//

#import "AEMTaskListener.h"
#import <AEMMSDK/AEMMSDK.h>

@implementation AEMTaskListener


- (void)taskDidComplete:(AEMTask *)task {
	NSLog(@"task:  %@ completed successfully",[(AEMAssetSourceSyncTask*)task assetSource]);
}

- (void)task:(AEMTask *)task didSendProgress:(NSUInteger)progress {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AEMAssetSourceSyncTaskSentProgress" object:task];
}

- (void)task:(AEMTask *)task didCompleteWithError:(NSError *)error {
	NSLog(@"task:  %@ completed with error: %@",[(AEMAssetSourceSyncTask*)task assetSource], error);
}


@end
