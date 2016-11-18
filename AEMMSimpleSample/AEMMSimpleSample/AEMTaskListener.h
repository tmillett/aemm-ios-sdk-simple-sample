//
//  AEMTaskListener.h
//  AEMMSimpleSample
//
//  Created by tmillett on 11/16/16.
//  Copyright © 2016 Adobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AEMMSDK/AEMMSDK.h>

@interface AEMTaskListener : NSObject <AEMTaskSuccessListener, AEMTaskProgressListener, AEMTaskErrorListener>
@end
