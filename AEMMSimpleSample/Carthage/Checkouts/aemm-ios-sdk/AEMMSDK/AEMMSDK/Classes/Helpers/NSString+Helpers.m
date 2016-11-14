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

#import "NSString+Helpers.h"
#import "NSURL+Helpers.h"
#import <CommonCrypto/CommonDigest.h>

static NSString* const kURLEscapeCharacters = @" !*'();:@&=+$,/?%#[]";
static NSString* const kURLEscapeCharactersNoSlash = @" !*'();:@&=+$,?%#[]";
static NSString* const kGlobalResourcesDirectory = @"global";

NSString* const kApplicationGeneralStringTable = @"App_General";
NSString* const kArticleViewGeneralStringTable = @"AV_General";
NSString* const kArticleViewWebStringTable = @"AV_Web";
NSString* const kBrowseViewGeneralStringTable = @"BV_General";
NSString* const kAFNetworkingStringTable = @"AFNetworking";

static NSString* const kURIEncodedApostrophe = @"\%27";
static NSString* const kURIEncodedSpace = @"\%20";
static NSString* const kURIEncodedEquals = @"\%3D";

static NSString* const kApostrophe = @"'";
static NSString* const kSpace = @" ";
static NSString* const kEquals = @"=";

NSString* NSLocalizedStringForKey(NSString* key, NSString* table)
{
	//In release, use the key as the localized string if the key is not found in the string table
	NSString* missingKeyValue = nil;
#ifdef DEBUG
	missingKeyValue = [NSString stringWithFormat:@"KEY '%@' NOT FOUND IN STRING TABLE", key];
#endif
	return [[NSBundle mainBundle] localizedStringForKey:key value:missingKeyValue table:table];
}

@implementation NSString (Helpers)

+ (NSString*)NSStringFromBOOL:(BOOL)b
{
	return ((b) ? @"YES" : @"NO");
}

+ (NSString*)guidString
{
	NSString* uuids = nil;
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	if (uuid)
	{
		uuids = (NSString*) CFBridgingRelease(CFUUIDCreateString(nil, uuid));
		CFRelease(uuid);
	}
	return uuids;
}

+ (NSString*)stringForPathComponentInLibraryDirectory:(NSString*) component
{
	NSArray *dirpaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	if (dirpaths == nil || dirpaths.count < 1)
		return nil;
	NSString *dirpath = [dirpaths objectAtIndex:0];
	if (component == nil)
		return dirpath;
	NSString* filepath = [dirpath stringByAppendingPathComponent:component];
	return filepath;
}

+ (NSString*)stringForPathComponentInAppSupportDirectory:(NSString*) component
{
	NSArray *dirpaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	if (dirpaths == nil || dirpaths.count < 1)
		return nil;
	NSString *dirpath = [dirpaths objectAtIndex:0];
	if (component == nil)
		return dirpath;
	NSString* filepath = [dirpath stringByAppendingPathComponent:component];
	return filepath;
}

+ (NSString*)stringForPathComponentInDocumentsDirectory:(NSString*) component
{
	NSArray *dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if (dirpaths == nil || dirpaths.count < 1)
		return nil;
	NSString *dirpath = [dirpaths objectAtIndex:0];
	if (component == nil)
		return dirpath;
	NSString* filepath = [dirpath stringByAppendingPathComponent:component];
	return filepath;
}

+ (NSString*)stringForPathComponentInCachesDirectory:(NSString*) component
{
    NSArray *dirpaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	if (dirpaths == nil || dirpaths.count < 1)
		return nil;
	NSString *dirpath = [dirpaths objectAtIndex:0];
	if (component == nil)
		return dirpath;
	NSString* filepath = [dirpath stringByAppendingPathComponent:component];
	return filepath;
}

+ (NSString*)stringForPathComponentInTemporaryDirectory:(NSString*) component
{
	NSString *dirpath = NSTemporaryDirectory();
	if (component == nil)
		return dirpath;
	return [dirpath stringByAppendingPathComponent:component];
}

+ (NSString*)stringForPathComponentInLocalizedApplicationBundle:(NSString*) component relativeToDirectory:(NSString*) relativeDirectory
{
    NSString* path = [[NSBundle mainBundle] pathForResource:[component stringByDeletingPathExtension] ofType:[component pathExtension] inDirectory:relativeDirectory];
    
    // If we cannot find a localized resource lets attempt to look in our global directory instead
    if (!path)
    {
        NSString* globalLocation = [[kGlobalResourcesDirectory stringByAppendingPathComponent:relativeDirectory] stringByAppendingPathComponent:component];
        path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:globalLocation];
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        if (![fileManager fileExistsAtPath:path])
        {
            path = nil;
        }
    }
    
    return path;
}

+ (NSString*)stringForTemporaryFilePath:(NSString*) extension
{
	NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
	NSString *filename = [NSString stringWithFormat:@"temp%f", t];
	if (extension)
		filename = [filename stringByAppendingPathExtension:extension];
	NSString* temppath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
	return temppath;
}

+ (NSString*)stringWithData:(NSData*)theData encoding:(NSStringEncoding)theEncoding
{
    return [[NSString alloc] initWithData:theData encoding:theEncoding];
}

static const char kBase16EncodingTable[] = { '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' };

+ (NSString*)base16StringFromData:(NSData*)data
{
    NSUInteger len = [data length];
    NSUInteger outputLen = len * 2;
    const unsigned char* bytes = (unsigned char*)[data bytes];
    if(len < 1)
    {
        return nil;
    }
    
    char* buffer = (char*) malloc(outputLen + 1); // one byte extra
    if(buffer)
    {
        for(uint i = 0, j=0; i < len; ++i,j+=2)
        {
            buffer[j + 1] = kBase16EncodingTable[ ((bytes[i] & 0x0F)) ];
            buffer[j] = kBase16EncodingTable[ ((bytes[i] & 0xF0) >> 4) ];
        }
        // null terminate;
        buffer[outputLen] = 0;
        
        // Create an NSString using the existing buffer.
        NSString* result = [[NSString alloc] initWithBytesNoCopy:buffer length:outputLen encoding:NSASCIIStringEncoding freeWhenDone:YES];
        if(result)
        {
            // Success!
            return result;
        }
        else
        {
            // Documentation says that a failure during string creation doesn't free the buffer, so we must do that
            // here.
            free(buffer);
        }
    }
    
    // We failed to allocate a buffer, or there was an error during NSString creation
    return nil;
}

char kBase64EncodingTable[65] = {
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
  'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
  'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/','='
};

+ (NSString*)base64StringFromData:(NSData*)data
{
    NSUInteger len = [data length];
    NSUInteger outputLen = (((len + 2) / 3) * 4);
    const unsigned char* bytes = (const unsigned char*)[data bytes];
    if(len < 1)
    {
        return nil;
    }
    
    char* buffer = (char*)malloc(outputLen);

    if(buffer)
    {   
        bzero(buffer, outputLen);
        
        for(uint i = 0, j=0; i < len; i += 3, j+=4)
        {
            unsigned char index0 = ((bytes[i] & 0xFC) >> 2); // bits 24-19
            unsigned char index1 = ((bytes[i] & 0x03) << 4); // bits 18-17
            unsigned char index2 = 64; // '=';
            unsigned char index3 = 64; // '=';
            // if bytes[i+1] is valid we'll use its contents 
            if((i+1) < len)
            {
                unsigned char b1 = bytes[i+1];
                index1 |= ((b1 & 0xF0) >> 4);  // insert bits 15-12
                index2 = ((b1 & 0x0F) << 2);    // bits 11-8
                
                if((i+2) < len)
                {
                    unsigned char b2 = bytes[i+2];
                    index2 |= ((b2 & 0xC0) >> 6); // insert bits 7-6
                    index3 = ((b2 & 0x3F));    // bits 5-0
                }
            }
             
            buffer[j] = kBase64EncodingTable[index0];
            buffer[j+1] = kBase64EncodingTable[index1];
            buffer[j+2] = kBase64EncodingTable[index2];
            buffer[j+3] = kBase64EncodingTable[index3];
        }
                
        // Create an NSString using the existing buffer.
        NSString* result = [[NSString alloc] initWithBytesNoCopy:buffer length:outputLen encoding:NSASCIIStringEncoding freeWhenDone:YES];
        if(result)
        {
            // Success!
            return result;
        }
        else
        {
            // Documentation says that a failure during string creation doesn't free the buffer, so we must do that
            // here.
            free(buffer);
        }
    }
    
    // We failed to allocate a buffer, or there was an error during NSString creation
    return nil;
}

+ (NSString*)uriEncodedStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order separator:(NSString*)separator joiner:(NSString*)joiner
{
    NSMutableString* queryString = [NSMutableString string];

    // Wrap this in autoreleasepool to catch all the autoreleased strings below
    @autoreleasepool
    {
        NSMutableDictionary* dictCopy = [dict mutableCopy];
        NSUInteger remainingEntries = dictCopy.count;
        // Iterate over order, adding key-value pairs to queryString as we go
        for (NSString* key in order)
        {
            // There's no guarantee that all keys in order are represented in dictCopy,
            // So we need to check first
            NSString* val = [dictCopy objectForKey:key];
            if (val != nil)
            {
                NSString* encodedKey = [NSString stringByAddingExtendedPercentEscapes:key];
                NSString* encodedVal = [NSString stringByAddingExtendedPercentEscapes:val];
                
                [queryString appendFormat:@"%@%@%@",encodedKey,separator,encodedVal];
                
                if (--remainingEntries > 0)
                {
                    [queryString appendString:joiner];
                }
                
                // Remove this key from dictCopy
                // (prevents duplicates and allows us to do the rest unordered)
                [dictCopy removeObjectForKey:key];
            }
        }
        
        // Now iterate over keys left in the dictionary
        for (NSString* key in dictCopy)
        {
            NSString* encodedKey = [NSString stringByAddingExtendedPercentEscapes:key];
            NSString* encodedVal = [NSString stringByAddingExtendedPercentEscapes:[dictCopy objectForKey:key]];
            
            [queryString appendFormat:@"%@%@%@",encodedKey,separator,encodedVal];
            
            if (--remainingEntries > 0)
            {
                [queryString appendString:joiner];
            }
        }
    }

    return queryString;
}

+ (NSString*)stringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order separator:(NSString*)separator joiner:(NSString*)joiner
{
	NSMutableString* queryString = [NSMutableString string];
	
	// Wrap this in autoreleasepool to catch all the autoreleased strings below
	@autoreleasepool
	{
		NSMutableDictionary* dictCopy = [dict mutableCopy];
		NSUInteger remainingEntries = dictCopy.count;
		// Iterate over order, adding key-value pairs to queryString as we go
		for (NSString* key in order)
		{
			// There's no guarantee that all keys in order are represented in dictCopy,
			// So we need to check first
			NSString* val = [dictCopy objectForKey:key];
			if (val != nil)
			{
				[queryString appendFormat:@"%@%@%@",key,separator,val];
				
				if (--remainingEntries > 0)
				{
					[queryString appendString:joiner];
				}
				
				// Remove this key from dictCopy
				// (prevents duplicates and allows us to do the rest unordered)
				[dictCopy removeObjectForKey:key];
			}
		}
		
		// Now iterate over keys left in the dictionary
		for (NSString* key in dictCopy)
		{
			NSString* val = [dictCopy objectForKey:key];
			
			[queryString appendFormat:@"%@%@%@",key,separator,val];
			
			if (--remainingEntries > 0)
			{
				[queryString appendString:joiner];
			}
		}
	}
	
	return queryString;
}

- (NSString*)urlQueryStringFromTemplateWithReplacementValues:(NSDictionary*)replacementValues
{
	NSString* result = [NSString stringWithString:self];

	// Wrap this in autoreleasepool to catch all the autoreleased strings below
	@autoreleasepool
	{
		NSArray* kvPairs = [self componentsSeparatedByString:@"&"];
		NSMutableArray* queryValues = [NSMutableArray arrayWithCapacity:kvPairs.count];
		for (NSString* kvPair in kvPairs)
		{
			NSArray* separatedKVPair = [kvPair componentsSeparatedByString:@"="];
			if (separatedKVPair.count == 2)
			{
				[queryValues addObject:[separatedKVPair objectAtIndex:1]];
			}
		}

		for (NSString* queryValue in queryValues)
		{
			NSString* replacementValue = queryValue;
			if ([queryValue hasPrefix:@"{"])
			{
				NSString* cleanedQueryValue = [queryValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
				replacementValue = replacementValues[cleanedQueryValue];
				if (!replacementValue)
				{
					replacementValue = @"";
				}

			}
			result = [result stringByReplacingOccurrencesOfString:queryValue withString:[NSString stringByAddingExtendedPercentEscapes:replacementValue]];
		}
	}

	return result;
}

+ (NSString*)urlQueryStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order
{
    if (!dict.count)
    {
        return nil;
    }
    
    // Tell it to encode the key-value pairs, with @"=" between key and value, and @"&" joining
    // pairs
    NSString* query = [NSString uriEncodedStringFromDict:dict withOrder:order separator:@"=" joiner:@"&"];
    if (query.length > 0)
    {
        query = [@"?" stringByAppendingString:query];
    }
    return query;
}

+ (NSString*)urlQueryStringFromDict:(NSDictionary*)dict
{
    return [NSString urlQueryStringFromDict:dict withOrder:@[]];
}

+ (NSString*)encodedParameterStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order
{
    // returns a URL-encoded containing key/value pairs in the format 'key1=value1 key2=value2'
    // Start with a URI-encoded apostrophe (')
    NSString* retString = kURIEncodedApostrophe;
    // Convert the dictionary to a key-value string where keys and values are URI encoded, and
    // a URI-encoded equals sign goes between key and value, and a URI encoded space joins
    // pairs
    NSString* theParams = [NSString uriEncodedStringFromDict:dict withOrder:order separator:kURIEncodedEquals joiner:kURIEncodedSpace];
    if (theParams && theParams.length > 1)
    {
        retString = [retString stringByAppendingString:theParams];
    }
    // Make sure we close the string with another encoded apostrophe
    return [retString stringByAppendingString:kURIEncodedApostrophe];
}

+ (NSString*)parameterStringFromDict:(NSDictionary*)dict withOrder:(NSArray*)order
{
	// returns a string containing key/value pairs in the format 'key1=value1 key2=value2'
	// Start with a apostrophe (')
	NSString* retString = kApostrophe;
	// Convert the dictionary to a key-value string ,
	// and a equals sign goes between key and value,
	// and a space joins pairs
	NSString* theParams = [NSString stringFromDict:dict withOrder:order separator:kEquals joiner:kSpace];
	if (theParams && theParams.length > 1)
	{
		retString = [retString stringByAppendingString:theParams];
	}
	// Make sure we close the string with another apostrophe
	return [retString stringByAppendingString:kApostrophe];
}

+ (NSString*)encodedParameterStringFromDict:(NSDictionary*)dict
{
    return [NSString encodedParameterStringFromDict:dict withOrder:nil];
}

+ (NSString*)parameterStringFromDict:(NSDictionary*)dict
{
	return [NSString parameterStringFromDict:dict withOrder:nil];
}

- (NSString*)stringByAppendingQueryStringFromDict:(NSDictionary*)dict
{
	//Convert to NSURL to take advantage of queryDictionary helper method
	NSURL* url = [NSURL URLWithString:self];
	
	//Obtain the current list of query params
	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:url.queryDictionary];
	
	//Add/override with the passed-in query params
	[params addEntriesFromDictionary:dict];
	
	//Recreate the query string using the updated query params
	NSString* queryString = [NSString urlQueryStringFromDict:params];
	
	//If the queryString is nil, make no changes
	if (queryString == nil)
	{
		return self;
	}
	
	//If the string already had a query string, replace it with the updated query string
	if (url.query)
	{
		return [self stringByReplacingOccurrencesOfString:[@"?" stringByAppendingString:url.query] withString:queryString];
	}
	
	//If the string had no query string but did have a fragment, insert the new query string in front of the fragment
	if (url.fragment)
	{
		return [self stringByReplacingOccurrencesOfString:@"#" withString:[queryString stringByAppendingString:@"#"]];
	}
	
	//If the string had no query string or fragment, append the new query string
	return [self stringByAppendingString:queryString];
}

+ (NSString*)stringByAddingExtendedPercentEscapes:(NSString*) unencodedString
{
    // The expected approach of using [NSString stringByAddingPercentEscapesUsingEncoding] fails
    // because it leaves reserved characters (like '+' and '@' unescaped). This forces escaping
    // of all the reserved characters as well
	/*
	 CFURLCreateStringByAddingPercentEscapes(
	 CFAllocatorRef allocator,
	 CFStringRef originalString, 
	 CFStringRef charactersToLeaveUnescaped, 
	 CFStringRef legalURLCharactersToBeEscaped, 
	 CFStringEncoding encoding)
	 
	 */
    
    NSString* encodedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)unencodedString,
                                                                                  NULL,
                                                                                  (CFStringRef)kURLEscapeCharacters,
                                                                                  kCFStringEncodingUTF8 ));
    return encodedString;
}

+ (NSString*)stringByAddingExtendedPercentEscapesToPathComponents:(NSString*)unencodedString
{
    NSString* encodedString = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)unencodedString,
                                                                                  NULL,
                                                                                  (CFStringRef)kURLEscapeCharactersNoSlash,
                                                                                  kCFStringEncodingUTF8 ));

    return encodedString;
}

- (NSString*)stringByAppendingSlashIfNecessary
{
	// Add "/" at the end if it does not exist
	if (![self hasSuffix:@"/"])
	{
		return [self stringByAppendingString:@"/"];
	}
	return self;
}

- (NSString*)stringByRemovingTrailingSlashIfNecessary
{
	// Remove "/" at the end if it exists
	if ([self hasSuffix:@"/"])
	{
		return [self substringToIndex:(self.length-1)];
	}
	return self;
}

- (NSString*)stringByRemovingWhitespace
{
	// Remove whitespace characters from the string
	NSArray* components = [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return [components componentsJoinedByString:@""];
}

- (NSString*)relativePathToPath:(NSString*)path
{    
    if (!path || !path.length || !self.length || ![self isAbsolutePath] || ![path isAbsolutePath])
    {
        return nil;
    }
    
    // Find the common prefix between the two paths, then back up to that prefix
    // and append the suffix of the second string
    // e.g.
    // string A is /1/2/3/4/5/6/a.html
    // string B is /1/2/3/7/8/9/b.html
    // Prefix is /1/2/3/ which leads to
    // ../../../7/8/9/b.html
    
    NSArray* sourceComponents = [self pathComponents];
    NSArray* destComponents = [path pathComponents];
    
    NSInteger lastCommonIndex = -1;
    
    for (NSInteger i = 0; i < sourceComponents.count; ++i)
    {
        if (i >= destComponents.count || 
            ![[sourceComponents objectAtIndex:i] isEqual:[destComponents objectAtIndex:i]])
        {
            break;
        }
        
        lastCommonIndex = i;
    }
    
    // If we have no components in common then we cannot create a relative path
    if (lastCommonIndex == -1)
    {
        return nil;
    }
    
    // If the source path points to a file we have to subtract one directory
    // if the filesystem call cannot ascertain if it is a directory we will use 
    // the presence of a terminating slash to denote a directory
    
    BOOL isDirectory = YES;
    
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:self isDirectory:&isDirectory])
    {
        unichar lastChar = [self characterAtIndex:self.length-1];
        if (lastChar != '\\' && lastChar != '/')
        {
            isDirectory = NO;
        }
    }
    
    NSInteger numDirectoriesInSourceComponents = (isDirectory) ? sourceComponents.count : sourceComponents.count-1;
    
    NSMutableArray* relativePathComponents = [[NSMutableArray alloc] init];
    // Add in .. for all remaining path components
    for (NSInteger i = lastCommonIndex + 1; i < numDirectoriesInSourceComponents; ++i)
    {
        [relativePathComponents addObject:@".."];
    }
    
    for (NSInteger i = lastCommonIndex + 1; i < destComponents.count; ++i)
    {
        [relativePathComponents addObject:[destComponents objectAtIndex:i]];
    }
    
    NSString* relativePath = [NSString pathWithComponents:relativePathComponents];
    
    return relativePath;
}

+ (NSString*)encodeForXML:(NSString*)unencodedString
{
    NSString* string = unencodedString; 
    
    // Encode all the reserved Characters in HTML
    
    string = [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    string = [string stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    string = [string stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    string = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    string = [string stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    
    return string;
}

+ (NSString*)parseStringToPath:(NSString*)urlString
{
    NSString* result = urlString;
    if([urlString hasPrefix:@"documents://"])
    {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        result = [documentsDirectory stringByAppendingPathComponent:[urlString substringFromIndex:12]];
    }
    else if([urlString hasPrefix:@"bundle://"])
    {
        NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
        result = [bundleDirectory stringByAppendingPathComponent:[urlString substringFromIndex:9]];
    }
    else if([urlString hasPrefix:@"appsupport://"])
    {
        NSString *appsupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        result = [appsupportDirectory stringByAppendingPathComponent:[urlString substringFromIndex:13]];
    }
    else if([urlString hasPrefix:@"caches://"])
    {
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        result = [cachesDirectory stringByAppendingPathComponent:[urlString substringFromIndex:9]];
    }
    
    return result;
}

+ (NSURL*)parseStringToURL:(NSString*)urlString
{
    if(urlString)
    {
        NSString* parsedPath = [NSString parseStringToPath:urlString];
        if([parsedPath hasPrefix:@"file"] || [parsedPath hasPrefix:@"http"])
        {
            return [NSURL URLWithString:parsedPath];
        }
        else
        {
            return [NSURL fileURLWithPath:parsedPath];
        }
    }
    else
    {
        return nil;
    }
}

// Convert a filesystem path back into documents://, bundle://, or appsupport:// form
+ (NSString*)debugPath:(NSString*)pathString
{
    if(pathString)
    {
        // Start by checking for the Documents directory
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSRange found = [pathString rangeOfString:documentsDirectory];
        if(found.location != NSNotFound)
        {
            if([pathString isEqualToString:documentsDirectory])
            {
                return @"Documents://";
            }
            else
            {
                return [@"Documents:/" stringByAppendingString:[pathString substringFromIndex:(found.location + found.length)]];
            }
        }
        
        // Check for the application bundle
        NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
        found = [pathString rangeOfString:bundleDirectory];
        if(found.location != NSNotFound)
        {
            if([pathString isEqualToString:bundleDirectory])
            {
                return @"Bundle://";
            }
            else
            {
                return [@"Bundle:/" stringByAppendingString:[pathString substringFromIndex:(found.location + found.length)]];
            }
        }
        
        // Check for the application support directory
        NSString *appsupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        found = [pathString rangeOfString:appsupportDirectory];
        if(found.location != NSNotFound)
        {
            if([pathString isEqualToString:appsupportDirectory])
            {
                return @"Appsupport://";
            }
            else
            {
                return [@"Appsupport:/" stringByAppendingString:[pathString substringFromIndex:(found.location + found.length)]];
            }
        }
        
        // Check for the caches directory
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        found = [pathString rangeOfString:cachesDirectory];
        if(found.location != NSNotFound)
        {
            if([pathString isEqualToString:cachesDirectory])
            {
                return @"Caches://";
            }
            else
            {
                return [@"Caches:/" stringByAppendingString:[pathString substringFromIndex:(found.location + found.length)]];
            }
        }
    }
    return pathString;
}

+ (NSString*)debugURL:(NSURL*)url
{
    if([url isFileURL])
    {
        return [NSString debugPath:[url path]];
    }
    else
    {
        return [url absoluteString];
    }
}

- (NSString*)MD5
{
	// Create pointer to the string as UTF8
	const char *ptr = [self UTF8String];

	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	CC_LONG len = (CC_LONG)[self length];

	// Create 16 byte MD5 hash value, store in buffer
	CC_MD5(ptr, len, md5Buffer);

	// Convert MD5 value in the buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
	{
		[output appendFormat:@"%02x",md5Buffer[i]];
	}

	return output;
}


@end
