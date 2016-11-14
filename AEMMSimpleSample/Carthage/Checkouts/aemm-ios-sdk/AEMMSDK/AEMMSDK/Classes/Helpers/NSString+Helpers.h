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

#define NSStringFromBOOL(b) ((b) ? @"YES" : @"NO")

#define NSLocalizedStringFromApplication(key) NSLocalizedStringForKey((key), kApplicationGeneralStringTable)
#define NSLocalizedStringFromArticleView(key) NSLocalizedStringForKey((key), kArticleViewGeneralStringTable)
#define NSLocalizedStringFromArticleViewWeb(key) NSLocalizedStringForKey((key), kArticleViewWebStringTable)
#define NSLocalizedStringFromBrowseView(key) NSLocalizedStringForKey((key), kBrowseViewGeneralStringTable)
#define NSLocalizedStringFromAFNetworking(key) NSLocalizedStringForKey((key), kAFNetworkingStringTable)

extern NSString* const kApplicationGeneralStringTable;
extern NSString* const kArticleViewGeneralStringTable;
extern NSString* const kArticleViewWebStringTable;
extern NSString* const kBrowseViewGeneralStringTable;
extern NSString* const kAFNetworkingStringTable;

#ifdef __cplusplus
extern "C" {
#endif
	NSString* NSLocalizedStringForKey(NSString* key, NSString* table);
#ifdef __cplusplus
}
#endif

@interface NSString (Helpers)

/** Returns a string whose value is either YES or NO
 */
+ (NSString*)NSStringFromBOOL:(BOOL)b;

/** Returns a string whose value is a new GUID. 
 */
+ (NSString*)guidString;

/** Returns the string that results from appending the path component to the path
	for the documents directory. If the component is nil, returns the path for the
	documents directory.
 */
+ (NSString*)stringForPathComponentInDocumentsDirectory:(NSString*) component;

/** Returns the string that results from appending the path component to the path
	for the ~/Library directory. If the component is nil, returns the path for the
	Library directory.
 */
+ (NSString*)stringForPathComponentInLibraryDirectory:(NSString*) component;

/** Returns the string that results from appending the path component to the path
	for the ~/Library/Application Support/ directory. If the component is nil, 
	returns the path for the Application Support directory.
 */
+ (NSString*)stringForPathComponentInAppSupportDirectory:(NSString*) component;

/** Returns the string that results from appending the path component to the path
	for the ~/Library/Caches directory. If the component is nil, returns the path 
	for the Caches directory.
 */
+ (NSString*)stringForPathComponentInCachesDirectory:(NSString*) component;

/** Returns the string that results from appending the path component to the path
	for the temporary directory. If the component is nil, returns the path for the 
	temporary directory.
 */
+ (NSString*)stringForPathComponentInTemporaryDirectory:(NSString*) component;

/** Returns the string that results from appending the path component to the path
    for the relative directory in the application bundle. 
 */
+ (NSString*)stringForPathComponentInLocalizedApplicationBundle:(NSString*) component relativeToDirectory:(NSString*) relativeDirectory;

/** Returns the path for a temporary file. If extension is non-nil then it is
	assigned as the extension for the temporary file. 
 */
+ (NSString*)stringForTemporaryFilePath:(NSString*) extension;

/** Returns the string constructed by reading the data using the specified encoding
 */
+ (NSString*)stringWithData:(NSData*)theDate encoding:(NSStringEncoding)theEncoding;

/** Construct a UTF-8 encoded query string for the key-value pairs in the dictionary
 @param replacementValues - dictionary with NSString keys and NSString values that will be added to the query
 @return query string beginning with '?' or nil if dict is empty or the url string cannot be constructed
 @note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
- (NSString*)urlQueryStringFromTemplateWithReplacementValues:(NSDictionary*)replacementValues;

/** Construct a UTF-8 encoded query string for the key-value pairs in the dictionary
    @param dict - dictionary with NSString keys and NSString values that will be added to the query
    @return query string beginning with '?' or nil if dict is empty or the url string cannot be constructed
    @note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
+ (NSString*)urlQueryStringFromDict:(NSDictionary*)dict;

/** Construct a UTF-8 encoded query string for the key-value pairs in the dictionary, using a 
    partial order defined by the NSString* keys in order.
 
    @param dict - dictionary whose keys and values will be URI encoded and added to the string
    @param order - array defining the order to assemble keys. keys not in dict will be omitted, and keys not in order will appear at the end in unspecified order.
    @return query string beginning with '?' or nil if dict is empty or the url string cannot be constructed
    @note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
+ (NSString*)urlQueryStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order;

/** Append a UTF-8 encoded query string for the key-value pairs in the dictionary; will add to existing query string
	 @param dict - dictionary with NSString keys and NSString values that will be added to the query
	 @return query string beginning with '?' or nil if dict is empty or the url string cannot be constructed
	 @note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
- (NSString*)stringByAppendingQueryStringFromDict:(NSDictionary*)dict;

/** Construct a string representation of the key-value pairs in the dictionary in the form 
	'key=value key=value ... ' where each key and value are separated by '=', each pair is separated
	by ' ' and there is an apostrophe at the beginning and end. This string is finally URI-encoded
	so that any reserved or non-ascii characters are replaced by a %XX where the X corresponds to a
	hexadecimal digit (i.e. 0-9A-F).
	This lets us embed a dictionary as the value for a key in a query string.

	e.g.  @{ @"A": @"B", @"C":@"D", @"E":@"F"} -> 'A=B C=D E=F' -> %27A%3DB%20C%3DD%20E%3DF%27
		  @{} -> '' -> %27%27

	@param dict - dictionary whose keys and values will be URI encoded and added to the string
	@return URI-encoded single quoted string containing encoded keys and values separated by encoded '=' and ' ' characters.
	@note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
+ (NSString*)encodedParameterStringFromDict:(NSDictionary*)dict;

/** Construct a string representation of the key-value pairs in the dictionary in the form
	'key=value key=value ... ' where each key and value are separated by '=', each pair is separated
	by ' ' and there is an apostrophe at the beginning and end.
	e.g.  @{ @"A": @"B", @"C":@"D", @"E":@"F"} -> 'A=B C=D E=F'
	@{} -> '' -> ''
	@param dict - dictionary whose keys and values will be added to the string
	@return the quoted string containing encoded keys and values separated by encoded '=' and ' ' characters.
	@note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
+ (NSString*)parameterStringFromDict:(NSDictionary*)dict;

/** Construct a string representation of the key-value pairs in the dictionary in the form
	'key=value key=value ... ' where each key and value are separated by '=', each pair is separated
	by ' ' and there is an apostrophe at the beginning and end. This string is finally URI-encoded
	so that any reserved or non-ascii characters are replaced by a %XX where the X corresponds to a
	hexadecimal digit (i.e. 0-9A-F). Keys appearing in the order array will appear with their values
	before keys not in the order array, and all others will appear in an unspecified order defined
	by iteration over the keys in dict.
	This lets us embed a dictionary as the value for a key in a query string.

	e.g.  @{ @"A": @"B", @"C":@"D", @"E":@"F"} withOrder: @[ @"E"] -> 'E=F A=B C=D' -> %27E%3DF%20A%3DB%20C%3DD%27
		  @{} -> '' -> %27%27

	@param dict - dictionary whose keys and values will be URI encoded and added to the string
	@param order - array defining the order to assemble keys. keys not in dict will be omitted, and keys not in order will appear at the end in unspecified order.
	@return URI-encoded single quoted string containing encoded keys and values separated by encoded '=' and ' ' characters.
	@note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
+ (NSString*)encodedParameterStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order;

/** Construct a string representation of the key-value pairs in the dictionary in the form
	key<separator>value<joiner>key<separator>value ...  where each key and value are separated
	by <separator>, each pair is separated by <joiner>. The keys and values are individually URI-encoded
	so that any reserved or non-ascii characters are replaced by a %XX where the X corresponds to a
	hexadecimal digit (i.e. 0-9A-F). Keys appearing in the order array will appear with their values
	before keys not in the order array, and all others will appear in an unspecified order defined
	by iteration over the keys in dict.
	This lets us embed a dictionary as the value for a key in a query string.

	e.g.  @{ @"A": @"B", @"C":@"D", @"E":@"F"} withOrder: @[ @"E"] separator:@"=" joiner:@"&"-> E=F&A=B&C=D'

	@param dict - dictionary whose keys and values will be URI encoded and added to the string
	@param order - array defining the order to assemble keys. keys not in dict will be omitted, and keys not in order will appear at the end in unspecified order.
	@param separator - string that will be placed in between the key and value of a key-value pair
	@param joiner = string that will be placed in between the key-value pairs
	@return URI-encoded string containing encoded keys and values separated by <separator> and <joiner> characters.
	@note Will behave unpredictably (and possibly throw) if dict has keys or values that are not NSString
 */
+ (NSString*)uriEncodedStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order separator:(NSString*)separator joiner:(NSString*)joiner;

/** Returns an encoded string which replaces reserved HTML/XML characters with proper entity encodings
    ("&"->"&amp;", "<"->"&lt;", ">"->"&gt;", "\""->"&quot;", "'"->"&apos;")
 */
+ (NSString*)encodeForXML:(NSString*)unencodedString;

/** Returns a UTF-8 URL encoded string 
 */
+ (NSString*)stringByAddingExtendedPercentEscapes:(NSString*)unencodedString;

/** Returns a UTF-8 URL encoded string; doesn't encode '/' 
 */
+ (NSString*)stringByAddingExtendedPercentEscapesToPathComponents:(NSString*)unencodedString;

/** Appends a slash to the string if the last character is not a slash.
	To use a string as a relative URL it must end with a slash.
 */
- (NSString*)stringByAppendingSlashIfNecessary;

/** Removes the last character of the string if it is a slash. 
 */
- (NSString*)stringByRemovingTrailingSlashIfNecessary;

/** Removes the whitespace characters from a string.
 */
- (NSString*)stringByRemovingWhitespace;

/** Returns the relative path from one absolute path to another
    Returns nil if either of the strings is not an absolute path 
 */
- (NSString*)relativePathToPath:(NSString*)path;

/** Helper that converts documents://, bundle://, appsupport:// into
	the correct filesystem locations
 */
+ (NSString*)parseStringToPath:(NSString*)urlString;

/** Helper that converts documents://, bundle://, appsupport:// into
	the correct filesystem locations 
 */
+ (NSURL*)parseStringToURL:(NSString*)urlString;

/** Create an MD5 hash for this string
 */
- (NSString*)MD5;

#ifdef DEBUG

/** Helper that converts file system paths back into documents://, bundle://, appsupport:// 
 */
+ (NSString*)debugPath:(NSString*)pathString;

/** Helper that converts file system paths back into documents://, bundle://, appsupport:// 
 */
+ (NSString*)debugURL:(NSURL*)url;

#endif

@end
