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

#import "AEMAssetDownloadInfo.h"
#import "AEMAssetService.h"
#import "AEMAssetSource+Internal.h"
#import "AEMAssetSourceSyncTask+Internal.h"
#import "AEMTask+Internal.h"
#import "AEMTaskErrorListener.h"
#import "AEMTaskProgressListener.h"
#import "AEMTaskSuccessListener.h"
#import "RemoteResponseParser+Internal.h"
#import "AEMAssetSourceSyncTaskDownloadInfo.h"


NS_ASSUME_NONNULL_BEGIN

@interface AEMAssetSourceSyncTask () <NSURLSessionDownloadDelegate>

@property (nonatomic, weak) AEMAssetSource *assetSource;
@property (nonatomic, assign) BOOL forceRefresh;
@property (nonatomic, strong) NSString *stagingFilePath;
@property (nonatomic, strong) NSURLSession *manifestUrlSession;
@property (nonatomic, strong) NSURLSession *urlSession;
@property (nonatomic, strong) AEMAssetSourceSyncTaskDownloadInfo *assetSourceSyncTaskDownloadInfo;
@property (nonatomic, strong) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSDictionary* existingAssetSourceManifest;
@property (nonatomic, assign) BOOL inBackground;
@property (nonatomic, assign) BOOL existingAssetSourceManifestDoesNotExist;
@property (nonatomic, assign) BOOL deleteTaskCompleted;
@property (nonatomic, assign) BOOL downloadTasksCompleted;
@property (nonatomic, assign) BOOL downloadTasksFailed;
@property (nonatomic, strong) NSDictionary *latestAssetSourceManifest;
@property (nonatomic, strong) NSMutableDictionary *assetsAdded;
@property (nonatomic, strong) NSMutableDictionary *assetsRemoved;
@property (nonatomic, strong) NSMutableDictionary *assetsChanged;
@property (nonatomic, copy, nullable) void(^backgroundTransferCompletionHandler)();

@end

@implementation AEMAssetSourceSyncTask

+ (NSString *)sessionIdentifierForAssetSource:(AEMAssetSource *)assetSource {
	return [NSString stringWithFormat:@"AEMAssetSourceSyncTaskSessionIdentifier-%@-%@", assetSource.identifier, assetSource.relativeCachePath];
}

+ (NSString *)sessionIdentifierForManifestForAssetSource:(AEMAssetSource *)assetSource {
	return [[self.class sessionIdentifierForAssetSource:assetSource] stringByAppendingString:@"-manifest.json"];
}

+ (instancetype)assetSourceSyncTaskWithSessionIdentifier:(NSString *)sessionIdentifier withAssetService:(AEMAssetService *)assetService {
	AEMAssetSourceSyncTaskDownloadInfo *downloadInfo = [AEMAssetSourceSyncTaskDownloadInfo assetSourceSyncTaskDownloadInfoWithSessionIdentifier:sessionIdentifier withAssetService:assetService];
	
	if (downloadInfo) {
		AEMAssetSourceSyncTask *syncTask = [[AEMAssetSourceSyncTask alloc] initInBackgroundWithDownloadInfo:downloadInfo];
		return syncTask;
	} else {
		return nil;
	}
}

- (instancetype)initInBackgroundWithDownloadInfo:(AEMAssetSourceSyncTaskDownloadInfo *)downloadInfo {

	if (self = [super init]) {

		self.inBackground = YES;

		self.assetSourceSyncTaskDownloadInfo = downloadInfo;
		self.assetSource = downloadInfo.assetSource;

		self.urlSession = [self.assetSource.assetService createURLSessionWithIdentifier:[self.class sessionIdentifierForAssetSource:self.assetSource] inBackground:self.inBackground withDelegate:self];

		NSLog(@"Creating urlSession with identifier:%@",[self.class sessionIdentifierForAssetSource:self.assetSource]);

		self.urlSession = [self.assetSource.assetService createURLSessionWithIdentifier:[self.class sessionIdentifierForAssetSource:self.assetSource] inBackground:self.inBackground withDelegate:self];
		[self.urlSession finishTasksAndInvalidate];
	}

	return self;
}

- (instancetype)initWithAssetSource:(AEMAssetSource *)assetSource inBackground:(BOOL)inBackground {

	if (self = [super init]) {
		self.assetSource = assetSource;
		self.inBackground = inBackground;

		self.parseQueue = [[NSOperationQueue alloc] init];

		self.assetsAdded = [NSMutableDictionary dictionary];
		self.assetsRemoved = [NSMutableDictionary dictionary];
		self.assetsChanged = [NSMutableDictionary dictionary];

		self.assetSourceSyncTaskDownloadInfo = [AEMAssetSourceSyncTaskDownloadInfo assetSourceSyncTaskDownloadInfoWithSessionIdentifier:[self.class sessionIdentifierForAssetSource:self.assetSource] withAssetSource:self.assetSource];

		[self start];
	}

	return self;
}

- (void)parseExistingManifestAtPath:(NSString *)existingManifestRelativePath
						 withParser:(RemoteResponseParser *)parser
				withCompletionBlock:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completionBlock {

	NSData *data = [NSData dataWithContentsOfFile:[existingManifestRelativePath stringByExpandingTildeInPath]];

	if (data) {
		NSError* jsonError = nil;
		id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];

		if (jsonError) {
			//TODO: Handle error
			ASSERT_FAIL(@"");
		}

		[parser updateWithResponse:nil responseObject:json completionBlock:^(NSArray *parseArray, NSError *error) {

			__block NSInteger bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
				[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
				bgTaskId = UIBackgroundTaskInvalid;
			}];

			if (completionBlock) {
				completionBlock(parseArray.count == 1 ? parseArray[0] : nil, error);
			}

			[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
			bgTaskId = UIBackgroundTaskInvalid;
		}];

		[self queueResponseParser:parser];
	} else {
		if (completionBlock) {
			completionBlock(nil, nil);
		}
	}
}

- (NSURL *)manifestURL {
	return [[self.assetSource.assetService.baseURL URLByAppendingPathComponent:self.assetSource.identifier] URLByAppendingPathExtension:@"caas.json"];
}

- (void)downloadLatestManifest {

	__block NSInteger bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	self.manifestUrlSession = [self.assetSource.assetService createURLSessionWithIdentifier:[self.class sessionIdentifierForManifestForAssetSource:self.assetSource] inBackground:self.inBackground withDelegate:self];

	NSURL *manifestURL = [self manifestURL];

	ASSERT(manifestURL, @"manifestURL is nil");
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:manifestURL];
	[self addCookie:request];
	NSURLSessionTask *manifestDataTask = [self.manifestUrlSession downloadTaskWithRequest:request];

	AEMAssetDownloadInfo *info = [[AEMAssetDownloadInfo alloc] init];
	info.taskIdentifier = manifestDataTask.taskIdentifier;
	info.sessionIdentifier = self.urlSession.configuration.identifier;
	info.remoteURL = manifestURL;
	info.localPath = self.assetSource.latestManifestRelativePath;
	[self.assetSourceSyncTaskDownloadInfo setAssetInfo:info forKey:manifestURL.absoluteString];

	[manifestDataTask resume];

	[self.manifestUrlSession finishTasksAndInvalidate];
}

- (void)start {

	__block NSInteger bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	void (^parseExistingCompletionBlock)(NSDictionary *, NSError *) = ^void(NSDictionary * results, NSError * error) {

		__block NSInteger parseBGTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:parseBGTaskId];
			parseBGTaskId = UIBackgroundTaskInvalid;
		}];

		if (results && error == nil) {
			self.existingAssetSourceManifest = results;
			[self updateToLatestManifest];
		} else if (results == nil && error == nil) {
			self.existingAssetSourceManifestDoesNotExist = YES;
			[self updateToLatestManifest];
		} else {
			//TODO: Handle Error
			ASSERT_FAIL(@"");
		}
		
		[[UIApplication sharedApplication] endBackgroundTask:parseBGTaskId];
		parseBGTaskId = UIBackgroundTaskInvalid;
	};

	NSString *existingManifestRelativePath = [self.assetSource existingManifestRelativePath];

	[self parseExistingManifestAtPath:existingManifestRelativePath
						   withParser:[self.assetSource.assetService createManifestParser]
				  withCompletionBlock:parseExistingCompletionBlock];

	[self downloadLatestManifest];

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

- (void)manifestDownloadCompletedWithResults:(NSDictionary * _Nullable )results withError:(NSError * _Nullable )error {

	__block NSInteger downloadBGTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:downloadBGTaskId];
		downloadBGTaskId = UIBackgroundTaskInvalid;
	}];

	if (results.count) {
		self.latestAssetSourceManifest = results;
		[self updateToLatestManifest];

	} else {
		[self notifyListenersAboutError:error];
	}

	[[UIApplication sharedApplication] endBackgroundTask:downloadBGTaskId];
	downloadBGTaskId = UIBackgroundTaskInvalid;
}

- (void)queueResponseParser:(RemoteResponseParser *)responseParser {
	ASSERT(responseParser, @"missing required param responseParser", self);

	@synchronized(responseParser) {
		if (!responseParser.hasBeenQueued) {
			responseParser.hasBeenQueued = YES;
			[self.parseQueue addOperation:responseParser];
		} else {
			ASSERT_FAIL(@"responseParser has already been queued");
		}
	}
}

- (void)updateToLatestManifest {

	__block NSInteger bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	if ((self.existingAssetSourceManifest || self.existingAssetSourceManifestDoesNotExist) &&
		self.latestAssetSourceManifest) {

		[self reconcileManifests];

		[self downloadAssets];
		[self deleteAssets];
	}

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

- (void)reconcileManifests {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	NSMutableDictionary* existingAssets = [NSMutableDictionary dictionary];
	NSMutableDictionary* latestAssets = [NSMutableDictionary dictionary];

	for (NSDictionary *asset in self.existingAssetSourceManifest[@"assets"]) {
		existingAssets[asset[@"url"]] = asset;
	}

	for (NSDictionary *asset in self.latestAssetSourceManifest[@"assets"]) {
		latestAssets[asset[@"url"]] = asset;
	}

	for (NSString *existingAssetURL in existingAssets) {
		NSDictionary *existingAsset = existingAssets[existingAssetURL];
		NSDictionary *latestAsset = latestAssets[existingAssetURL];
		if (latestAsset == nil) {
			self.assetsRemoved[existingAssetURL] = existingAsset;
		} else if (![latestAsset[@"md5"] isEqualToString:existingAsset[@"md5"]]) {
			self.assetsChanged[existingAssetURL] = latestAsset;
		}
	}

	for (NSString *latestAssetURL in latestAssets) {
		NSDictionary *existingAsset = existingAssets[latestAssetURL];
		NSDictionary *latestAsset = latestAssets[latestAssetURL];
		if (existingAsset == nil) {
			self.assetsAdded[latestAssetURL] = latestAsset;
		}
	}

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

- (void)sortAssetsToDownload:(NSMutableArray *)assetsToDownload {
  [assetsToDownload sortUsingComparator:^NSComparisonResult(id leftObj, id rightObj) {
		NSDictionary *leftAsset = (NSDictionary *)leftObj;
		NSDictionary *rightAsset = (NSDictionary *)rightObj;

		NSNumber *leftSize = leftAsset[@"length"];
		NSNumber *rightSize = rightAsset[@"length"];

		// We want to return longest first
		if (leftSize.longLongValue < rightSize.longLongValue) {
			return NSOrderedDescending;
		} else if (leftSize.longLongValue > rightSize.longLongValue) {
			return NSOrderedAscending;
		} else {
			return NSOrderedSame;
		}
	}];
}

- (void)addCookie:(NSMutableURLRequest *)request {
  [request setValue:@"cq-authoring-mode=TOUCH; login-token=640f96aa-b4d3-4c9c-8497-2791cc501fac%3a85db58a0-1495-4e61-84ba-bb33fc72751e_f33ee54744d6d797%3acrx.default" forHTTPHeaderField:@"Cookie"];
}

- (NSString *)localRelativePathForAsset:(NSDictionary *)asset {
	NSString *localPathFragment = asset[@"localPath"];
	if (!localPathFragment) {
		localPathFragment = [[NSURL URLWithString:asset[@"url"]] path];
	}
	return [self.assetSource.relativeCachePath stringByAppendingPathComponent:localPathFragment];
}

- (void)downloadAssets {

	__block NSInteger bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	NSMutableArray * assetsToDownload = [NSMutableArray array];
	for (NSDictionary *asset in [self.assetsAdded allValues]) {
		[assetsToDownload addObject:asset];
	}

	for (NSDictionary *asset in [self.assetsChanged allValues]) {
		[assetsToDownload addObject:asset];
	}

	if (assetsToDownload.count == 0) {
		self.downloadTasksCompleted = YES;
		[self taskCompletedSuccessfully];
	} else {

		[self sortAssetsToDownload:assetsToDownload];

		self.urlSession = [self.assetSource.assetService createURLSessionWithIdentifier:[self.class sessionIdentifierForAssetSource:self.assetSource] inBackground:self.inBackground withDelegate:self];
		NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:assetsToDownload.count];

		for (NSDictionary *asset in assetsToDownload) {
			NSURL *url = [NSURL URLWithString:asset[@"url"]];
			if (url == nil) {
				url = [NSURL URLWithString:asset[@"url"] relativeToURL:self.assetSource.assetService.baseURL];
			}

			ASSERT(url, @"url is nil");

			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
			[self addCookie:request];

			NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:request];

			AEMAssetDownloadInfo *info = [[AEMAssetDownloadInfo alloc] init];
			info.taskIdentifier = task.taskIdentifier;
			info.sessionIdentifier = self.urlSession.configuration.identifier;
			info.remoteURL = url;
			NSString *localPathFragment = asset[@"localPath"];
			if (!localPathFragment) {
				localPathFragment = url.path;
			}
			NSString *localPath = [self.assetSource.relativeCachePath stringByAppendingPathComponent:localPathFragment];
			info.localPath = localPath;
			[self.assetSourceSyncTaskDownloadInfo setAssetInfo:info forKey:url.absoluteString];

			info.localPath = [self localRelativePathForAsset:asset];

			[tasks addObject:task];
		}

		[self.assetSourceSyncTaskDownloadInfo save];

		for (NSURLSessionTask *task in tasks) {
			[task resume];
		}

		[self.urlSession finishTasksAndInvalidate];
	}

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

- (void)deleteAssets {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	if (self.assetsRemoved.count) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

			for (NSDictionary *asset in [self.assetsRemoved allValues]) {
				if (![[NSFileManager defaultManager] removeItemAtPath:[[self localRelativePathForAsset:asset] stringByExpandingTildeInPath] error:nil]) {
					ASSERT_FAIL(@"");
				}
			}

			self.deleteTaskCompleted = self.assetsRemoved.count > 0;

			dispatch_async(dispatch_get_main_queue(), ^{
				self.deleteTaskCompleted = YES;
				[self taskCompletedSuccessfully];

				[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
				bgTaskId = UIBackgroundTaskInvalid;
			});
		});
	} else {
		self.deleteTaskCompleted = YES;
		[self taskCompletedSuccessfully];

		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}
}

- (double)calculateTotalProgress {

	double totalWritten = 0;
	double totalExpectedToWrite = 0;

	for (AEMAssetDownloadInfo *info in [self.assetSourceSyncTaskDownloadInfo allAssets]) {
		totalWritten += info.sizeWritten;
		totalExpectedToWrite += info.expectedSize;
	}

	return totalWritten / totalExpectedToWrite;
}

- (NSError *)assetDownloadInfosContainErrors {
	NSError *error = nil;
	for (AEMAssetDownloadInfo *info in [self.assetSourceSyncTaskDownloadInfo allAssets]) {
		if (info.downloadError) {
			error = info.downloadError;
			break;
		}
	}

	return error;
}

- (BOOL)assetDownloadInfosDownloadCompleted {
	BOOL downloadCompleted = YES;
	for (AEMAssetDownloadInfo *info in [self.assetSourceSyncTaskDownloadInfo allAssets]) {
		if (!info.downloadComplete) {
			downloadCompleted = NO;
			break;
		}
	}

	return downloadCompleted;
}

- (void)taskCompletedSuccessfully {

	if (self.deleteTaskCompleted && self.downloadTasksCompleted) {

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSError *error = nil;
			if ([[NSFileManager defaultManager] fileExistsAtPath:[self.assetSource.existingManifestRelativePath stringByExpandingTildeInPath]]) {
				if (![[NSFileManager defaultManager] removeItemAtPath:[self.assetSource.existingManifestRelativePath stringByExpandingTildeInPath] error:&error]) {
					//TODO: Handle error
					ASSERT_FAIL(@"");
				};
			}

			if (![[NSFileManager defaultManager] moveItemAtPath:[self.assetSource.latestManifestRelativePath stringByExpandingTildeInPath]
														 toPath:[self.assetSource.existingManifestRelativePath stringByExpandingTildeInPath]
														  error:&error]) {
				//TODO: Handle error
				ASSERT_FAIL(@"");
			}

			[self.assetSourceSyncTaskDownloadInfo remove];
		});

		NSLog(@"AEMAssetSourceSyncTask:%@ succeeded", self.assetSource.identifier);
		[self notifyListenersAboutSuccess];
	} else {
		NSLog(@"[AEMAssetSourceSyncTask taskCompletedSuccessfully] for identifier:%@ called but something not completed deleteTaskCompleted:%@ downloadTasksCompleted:%@",self.assetSource.identifier, @(self.deleteTaskCompleted), @(self.downloadTasksCompleted));
	}
}

- ( NSError * _Nullable )convertHTTPResponseToError:(NSHTTPURLResponse *)httpResponse {

	NSError *error = nil;
	if (httpResponse.statusCode >= 400) {
		NSInteger errorCode = NSURLErrorUnknown;
		if (httpResponse.statusCode == 400) {
			errorCode = NSURLErrorBadURL;
		} else if (httpResponse.statusCode == 401) {
			errorCode = NSURLErrorUserAuthenticationRequired;
		} else if (httpResponse.statusCode == 403) {
			errorCode = NSURLErrorUserAuthenticationRequired;
		} else if (httpResponse.statusCode == 404) {
			errorCode = NSURLErrorFileDoesNotExist;
		} else if (httpResponse.statusCode >= 500) {
			errorCode = NSURLErrorResourceUnavailable;
		}

		error = [NSError errorWithDomain:NSURLErrorDomain code:errorCode userInfo:nil];
	}

	return error;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	NSLog(@"URLSession:didBecomeInvalidWithError: %@",error);

	if ([self.urlSession isEqual:session]) {

		if ([self assetDownloadInfosDownloadCompleted]) {
			self.downloadTasksCompleted = YES;
			[self taskCompletedSuccessfully];
		} else {
			error = error ?: [self assetDownloadInfosContainErrors];
			ASSERT(error, @"AEMAssetSourceSyncTask:%@ failed with no error", self.assetSource.identifier);
			NSLog(@"AEMAssetSourceSyncTask:%@ failed with error:%@", self.assetSource.identifier, error);
			[self notifyListenersAboutError:error];
		}
	}

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {

}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	// Check if all download tasks have been finished.
	[self.urlSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {

		if ([downloadTasks count] == 0) {
			if (self.backgroundTransferCompletionHandler != nil) {
				// Copy locally the completion handler.
				void(^completionHandler)() = self.backgroundTransferCompletionHandler;

				// Make nil the backgroundTransferCompletionHandler.
				self.backgroundTransferCompletionHandler = nil;

				dispatch_async(dispatch_get_main_queue(), ^() {
					// Call the completion handler to tell the system that there are no other background transfers.
					completionHandler();

					[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
					bgTaskId = UIBackgroundTaskInvalid;
				});
			} else {
				[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
				bgTaskId = UIBackgroundTaskInvalid;
			}
		} else {
			ASSERT_FAIL(@"Background session finished with remaining tasks");

			[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
			bgTaskId = UIBackgroundTaskInvalid;
		}
	}];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	NSLog(@"URLSession:downloadTask:didFinishDownloadingToURL: %@",downloadTask.originalRequest.URL);

	AEMAssetDownloadInfo *downloadInfo = [self.assetSourceSyncTaskDownloadInfo assetInfoForKey:downloadTask.originalRequest.URL.absoluteString];

	if ([[downloadInfo.remoteURL absoluteString] isEqualToString:[[self manifestURL] absoluteString]]) {

		NSLog(@"MANIFEST - URLSession:downloadTask:didFinishDownloadingToURL: %@",downloadTask.originalRequest.URL);

		downloadInfo.downloadComplete = YES;

		[self.assetSourceSyncTaskDownloadInfo save];

		NSError *error = nil;

		NSData *data = [NSData dataWithContentsOfFile:location.path];

		if ([[NSFileManager defaultManager] fileExistsAtPath:[self.assetSource.latestManifestRelativePath stringByExpandingTildeInPath]]) {
			if (![[NSFileManager defaultManager] removeItemAtPath:[self.assetSource.latestManifestRelativePath stringByExpandingTildeInPath] error:&error]) {
				//TODO: Handle error
				ASSERT_FAIL(@"");
			}
		}

		id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
		if (error) {
			//TODO: Handle error
			ASSERT_FAIL(@"");
		}

		if (![[json JSONRepresentation] writeToFile:[self.assetSource.latestManifestRelativePath stringByExpandingTildeInPath] atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
			//TODO: Handle error
			ASSERT_FAIL(@"");
		}

		RemoteResponseParser *parser = [self.assetSource.assetService createManifestParser];

		[parser updateWithResponse:(NSHTTPURLResponse *)downloadTask.response responseObject:json completionBlock:^(NSArray *parseArray, NSError *error) {

			NSLog(@"MANIFEST - parse completed with error: %@",error);


			if (parseArray.count) {
				[self manifestDownloadCompletedWithResults:parseArray[0] withError:nil];
			} else {
				[self manifestDownloadCompletedWithResults:nil withError:error];
			}

			[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
			bgTaskId = UIBackgroundTaskInvalid;

		}];

		[self queueResponseParser:parser];

	} else {

		NSLog(@"ASSET - URLSession:downloadTask:didFinishDownloadingToURL: %@",downloadTask.originalRequest.URL);

		ASSERT([downloadTask.response isKindOfClass:NSHTTPURLResponse.class], @"wrong response class");

		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)downloadTask.response;

		NSError *error = [self convertHTTPResponseToError:httpResponse];

		if (error == nil) {
			downloadInfo.downloadComplete = YES;

			NSURL *assetLocationURL = [NSURL fileURLWithPath:[downloadInfo.localPath stringByExpandingTildeInPath]];

			if (assetLocationURL == nil) {
				//TODO: Handle error
				ASSERT_FAIL(@"");
			}

			NSError *error = nil;

			if (![[NSFileManager defaultManager] createDirectoryAtPath:[[downloadInfo.localPath stringByDeletingLastPathComponent] stringByExpandingTildeInPath] withIntermediateDirectories:YES attributes:nil error:&error]) {
				//TODO: Handle error
				if (![error.domain isEqualToString:NSCocoaErrorDomain] ||
					error.code == NSFileWriteFileExistsError) {
					ASSERT_FAIL(@"%@", error);
				}
			}

			if ([[NSFileManager defaultManager] fileExistsAtPath:[downloadInfo.localPath stringByExpandingTildeInPath]]) {
				if (![[NSFileManager defaultManager] removeItemAtURL:assetLocationURL error:&error]) {
					//TODO: Handle error
					ASSERT_FAIL(@"%@", error);
				};
			}

			NSLog(@"Moving item: %@\nto location: %@",downloadInfo.remoteURL, downloadInfo.localPath);

			if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:assetLocationURL error:&error]) {
				//TODO: Handle error
				ASSERT_FAIL(@"%@", error);
			}
		} else {
			downloadInfo.downloadError = error;

			[self.urlSession invalidateAndCancel];
		}

		[self.assetSourceSyncTaskDownloadInfo save];

		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
										  didWriteData:(int64_t)bytesWritten
									 totalBytesWritten:(int64_t)totalBytesWritten
								totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	AEMAssetDownloadInfo *downloadInfo = [self.assetSourceSyncTaskDownloadInfo assetInfoForKey:downloadTask.originalRequest.URL.absoluteString];

	downloadInfo.expectedSize = totalBytesExpectedToWrite;
	downloadInfo.sizeWritten = totalBytesWritten;

	[self notifyListenersAboutProgress:[self calculateTotalProgress]];

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {


}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error {

	__block UIBackgroundTaskIdentifier bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:NSString.guidString expirationHandler:^{
		[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
		bgTaskId = UIBackgroundTaskInvalid;
	}];

	NSLog(@"URLSession:%@ task:%@ didBecomeInvalidWithError:%@",session, task, error);

	AEMAssetDownloadInfo *downloadInfo = [self.assetSourceSyncTaskDownloadInfo assetInfoForKey:task.originalRequest.URL.absoluteString];

	if ([downloadInfo.remoteURL isEqual:[self manifestURL]]) {

	} else {

		if (error == nil && !downloadInfo.downloadError) {
			downloadInfo.downloadComplete = YES;
		} else {
			downloadInfo.downloadError = downloadInfo.downloadError ?: error;

			[self.urlSession invalidateAndCancel];
		}

		[self.assetSourceSyncTaskDownloadInfo save];
	}

	[[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
	bgTaskId = UIBackgroundTaskInvalid;
}

@end

NS_ASSUME_NONNULL_END
