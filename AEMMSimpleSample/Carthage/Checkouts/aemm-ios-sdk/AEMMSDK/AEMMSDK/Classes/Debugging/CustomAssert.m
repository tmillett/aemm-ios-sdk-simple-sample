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

#import "CustomAssert.h"

#ifdef DEBUG

#ifdef CALABASH_ENABLED
BOOL gEnableAsserts = NO;
#else
BOOL gEnableAsserts = YES;
#endif
BOOL gThrowExceptionOnAsserts = NO;
BOOL gDebugBreakOnAsserts = YES;

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
bool AmIBeingDebugged(void)
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
	
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    info.kp_proc.p_flag = 0;
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
	
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
	
    // Call sysctl.
	
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
	
    // We're being debugged if the P_TRACED flag is set.
	
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

static void DebugBreak(NSString* messageStr)
{
	NSLog([NSString stringWithFormat:@"\nASSERT: %@", messageStr], nil);
	
#if (TARGET_IPHONE_SIMULATOR)
	__asm__("int $3");
#else
	raise(SIGTRAP);
#endif
}

NSString* ComposeString(NSString* format, ...)
{
    NSString* composed = @"";
    if (format)
    {
        va_list vl;
        va_start(vl, format);
        
        composed = [[NSString alloc] initWithFormat:format arguments:vl];
        
        va_end(vl);
    }

    return composed;
}

void CustomHandleAssert(const char* message, const char* file, uint32_t line)
{
	if (gEnableAsserts)
	{
		NSString* messageStr = [NSString stringWithFormat:@"%s\nFile: %s\nLine: %d", message, file, line];
		
		if (gThrowExceptionOnAsserts)
		{
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:messageStr userInfo:nil];
		}
		else if (gDebugBreakOnAsserts && AmIBeingDebugged())
		{
			DebugBreak(messageStr);
		}
	}
}

#endif
