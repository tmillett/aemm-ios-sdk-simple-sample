//
//  ViewController.m
//  AEMMSimpleSample
//
//  Created by tmillett on 11/9/16.
//  Copyright © 2016 Adobe. All rights reserved.
//

#import "ViewController.h"
#import <AEMMSDK/AEMMSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	AEMAssetSourceFactory *factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"file:///Users/tmillett/_dev/git/aemm-ios-sdk-simple-sample/AEMMSimpleSample"]];
	NSArray *dirpaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *dirpath = [dirpaths objectAtIndex:0];

	AEMAssetSource *source = [factory createAssetSourceWithIdentifier:@"id1" withRootFilePath:dirpath];
	[source syncInBackground:YES];


}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
