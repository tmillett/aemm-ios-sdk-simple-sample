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

#if defined(DEBUG) && TARGET_OS_IPHONE

extern BOOL gEnableAsserts;
extern BOOL gThrowExceptionOnAsserts;
extern BOOL gDebugBreakOnAsserts;
extern BOOL gShowDialogOnAsserts;


#if defined(__cplusplus)
extern "C"
{
#endif

/** @return YES if the debugger is active
 */
bool AmIBeingDebugged(void);

NSString* ComposeString(NSString* format, ...);

// Displays a UIAlertView given an assert message, and a file and line the assert occured on.
// Breaks into the debugger if a debugger is attached.
void CustomHandleAssert(const char* message, const char* file, uint32_t line);

#if defined(__cplusplus)
}
#endif

#define ASSERT(condition, desc, ...)	do { \
    if (!(condition)) { \
        NSString* msg = ComposeString(desc, ##__VA_ARGS__);   \
        CustomHandleAssert([msg UTF8String], __FILE__, __LINE__); \
    } \
} while(0)

#define ASSERT_FAIL(desc, ...)		do { \
    NSString* msg = ComposeString(desc, ##__VA_ARGS__);   \
    CustomHandleAssert([msg UTF8String], __FILE__, __LINE__); \
} while(0)

#define ASSERT_OVERRIDDEN() do { \
    NSString* msg = ComposeString(@"%s should be overridden by %@.",__FUNCTION__,self.class); \
    CustomHandleAssert([msg UTF8String], __FILE__, __LINE__); \
} while(0)
#else

#define ASSERT(condition, desc, ...) NSAssert(condition,ComposeString(desc, ##__VA_ARGS__))
#define ASSERT_FAIL(desc, ...) NSAssert(YES,ComposeString(desc, ##__VA_ARGS__))
#define ASSERT_OVERRIDDEN() NSAssert(YES,ComposeString(@"%s should be overridden by %@.",__FUNCTION__,self.class))
#endif
