//
//  AppDelegate.m
//  AEMMSimpleSample
//
//  Created by tmillett on 11/9/16.
//  Copyright © 2016 Adobe. All rights reserved.
//

#import "AppDelegate.h"
#import <AEMMSDK/AEMMSDK.h>
#import "AEMTaskListener.h"

@interface AppDelegate ()

@property (nonatomic, strong) AEMTaskListener *listener;
@property (nonatomic, strong) AEMAssetSource *source;
@property (nonatomic, strong) AEMAssetSourceSyncTask *task;
@property (nonatomic, strong) AEMAssetSourceFactory *factory;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {

	NSLog(@"application:(UIApplication *)application handleEventsForBackgroundURLSession:%@ completionHandler:",identifier);

	self.factory = [AEMAssetSourceFactory createAssetSourceFactoryWithBaseURL:[NSURL URLWithString:@"http://pepsi.sea.adobe.com/stage/tmillett/aemmsdk"]];

	self.task = [self.factory createAssetSourceSyncTaskWithBackgroundURLSessionIdentifier:identifier withBackgroundCompletionHandler:completionHandler];
	self.source = self.task.assetSource;
	self.listener = [[AEMTaskListener alloc] init];

	[self.task addSuccessListener:self.listener];
	[self.task addErrorListener:self.listener];


}


@end
