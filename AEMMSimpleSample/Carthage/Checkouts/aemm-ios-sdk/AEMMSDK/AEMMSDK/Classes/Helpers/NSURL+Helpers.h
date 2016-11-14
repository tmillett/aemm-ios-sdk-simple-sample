/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2014 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

extern NSString* const kApplicationFolioNavigationScheme;

@interface NSURL (Helpers)

/** Constuct a dictionary out of the parameters of the NSURL instance
 */
- (NSDictionary*) queryDictionary;
- (NSDictionary*) queryDictionaryWithXMLEncoding:(BOOL)xmlEncoding;

/** Accurate comparison method for URLs 
 
	Note: There is a hidden api called isEqualToURL in iOS9. If we keep the same name, 
		  then it will go to iOS9's implementation. Therefore we intentionally change 
		  isEqualToURL to isEqualToAEMURL so that our own implementation will be honored.
 */
- (BOOL)isEqualToAEMURL:(NSURL*)otherURL;

/** Check if the given url has the valid scheme and valid hosts provided
 */
- (BOOL)isValidCustomURL:(NSString*)scheme hosts:(NSArray*)hostList;

/** Concatenates the last path component of the baseURL with the relativeURL (handy for trace purposes)
 */
- (NSString*)stringFromFinalFragment;

@end

/** Return YES if fileURL is a file: URL and the file it points to exists
 */
BOOL fileResourceExists(NSURL* fileURL);
/** Return YES if fileURL is a file: URL and the file it points to does not exist
 */
BOOL fileResourceDoesntExist(NSURL* fileURL);
