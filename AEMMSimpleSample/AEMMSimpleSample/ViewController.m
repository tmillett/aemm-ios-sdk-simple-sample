//
//  ViewController.m
//  AEMMSimpleSample
//
//  Created by tmillett on 11/9/16.
//  Copyright © 2016 Adobe. All rights reserved.
//

#import "ViewController.h"
#import <AEMMSDK/AEMMSDK.h>
#import "AEMTaskListener.h"

@interface ViewController ()

@property (nonatomic, strong) AEMTaskListener *listener;
@property (nonatomic, strong) AEMAssetSource *source;
@property (nonatomic, strong) AEMAssetSourceSyncTask *task;
@property (nonatomic, strong) AEMAssetSourceFactory *factory;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSMutableArray *leftBtns = [[NSMutableArray alloc] init];

	UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(leftButtonPressed)];
	[leftBtns addObject:leftBtn];

	[self.navigationItem setLeftBarButtonItems:leftBtns animated:NO];

	NSMutableArray *rightBtns = [[NSMutableArray alloc] init];

	UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(rightButtonPressed)];
	[rightBtns addObject:rightBtn];

	[self.navigationItem setRightBarButtonItems:rightBtns animated:NO];




}

-(void)leftButtonPressed
{
	int *x = NULL;
	*x = 42;
}

-(void)rightButtonPressed
{
	NSLog(@"Left Button Tapped");

	NSURL *url = [NSURL URLWithString:@"http://10.50.213.159:4502/content/entities"];

	self.factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:url];
	NSArray *dirpaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *dirpath = [dirpaths objectAtIndex:0];

	NSLog(@"cache location:%@",dirpath);

	self.source = [self.factory createAssetSourceWithIdentifier:@"hotelBuddy" withRootFilePath:dirpath];
	self.task = [self.source syncInBackground:NO];
	self.listener = [[AEMTaskListener alloc] init];

	[self.task addSuccessListener:self.listener];
	[self.task addErrorListener:self.listener];

}



- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
