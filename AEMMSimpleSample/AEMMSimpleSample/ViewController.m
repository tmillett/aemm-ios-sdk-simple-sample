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

	self.factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://pepsi.sea.adobe.com/stage/tmillett/aemmsdk"]];

	self.source = [self.factory createAssetSourceWithIdentifier:@"hotel1" withRelativeCachePath:@"~/Library/Caches"];
	self.task = [self.source syncInBackground:YES];
	self.listener = [[AEMTaskListener alloc] init];

	[self.task addSuccessListener:self.listener];
	[self.task addErrorListener:self.listener];
}



- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
