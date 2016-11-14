/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2012 Adobe Systems Incorporated
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

#import "HttpHeaders.h"

NSString* const kHTTPHeaderAccept = @"Accept";
NSString* const kHTTPHeaderContentLength = @"Content-Length";
NSString* const kHTTPHeaderContentType = @"Content-Type";
NSString* const kHTTPHeaderIfModifiedSince = @"If-Modified-Since";
NSString* const kHTTPHeaderIfNoneMatch = @"If-None-Match";
NSString* const kHTTPHeaderLastModified = @"Last-Modified";
NSString* const kHTTPHeaderUserAgent = @"User-Agent";
NSString* const kHTTPHeaderAPIVersion = @"x-api-version";
NSString* const kHTTPHeaderNotificationClientId = @"x-notification-client-id";
NSString* const kHTTPHeaderTenantId = @"x-tenant-id";

NSString* const kHTTPAcceptApplicationXML = @"application/xml";
NSString* const kHTTPAcceptWildCard = @"*/*";

NSString* const kHTTPContentTypeApplicationJSON = @"application/json";
NSString* const kHTTPContentTypeApplicationPDF = @"application/pdf";
NSString* const kHTTPContentTypeApplicationXML = @"application/xml";
NSString* const kHTTPContentTypeImageJPEG = @"image/jpeg";
NSString* const kHTTPContentTypeImagePNG = @"image/png";
NSString* const kHTTPContentTypePlain = @"text/plain; charset=utf-8";
NSString* const kHTTPContentTypeXML = @"text/xml; charset=utf-8";
NSString* const kHTTPContentTypeHTML = @"text/html; charset=utf-8";
NSString* const kHTTPContentTypeFormUrlEncoded = @"application/x-www-form-urlencoded; charset=utf-8";
NSString* const kHTTPContentTypeMultipartFormData = @"multipart/form-data";
NSString* const kHTTPContentTypeWildCard = @"*/*";

NSString* const kHTTPHeaderStatusCode200 = @"200 OK";
NSString* const kHTTPHeaderStatusCode400 = @"400 Bad Request";
NSString* const kHTTPHeaderStatusCode403 = @"403 Preview Unavailable";
NSString* const kHTTPHeaderStatusCode404 = @"404 Not Found";
NSString* const kHTTPHeaderStatusCode503 = @"503 Service Unavailable";

NSInteger const kHTTPStatusCode200 = 200;
NSInteger const kHTTPStatusCode304 = 304;
NSInteger const kHTTPStatusCode401 = 401;
NSInteger const kHTTPStatusCode403 = 403;
NSInteger const kHTTPStatusCode404 = 404;
NSInteger const kHTTPStatusCode502 = 502;
NSInteger const kHTTPStatusCode503 = 503;
NSInteger const kHTTPStatusCode504 = 504;

NSString* const kHTTPErrorCodeDomain = @"GCHTTPErrorCodeDomain";
NSString* const kHTTPResponseSizeActualKey = @"responseSizeActual";
NSString* const kHTTPResponseSizeExpectedKey = @"responseSizeExpected";
NSString* const kHTTPResponseHeadersKey = @"responseHeaders";
NSString* const kHTTPResponseBodyKey = @"responseBody";
