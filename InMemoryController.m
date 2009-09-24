//
//  InMemoryController.m
//  InMemory
//
//  Created by Jesse Grosjean on 9/22/09.
//  Copyright 2009 Hog Bay Software. All rights reserved.
//

#import "InMemoryController.h"
#import "InMemoryFS.h"
#import <MacFUSE/MacFUSE.h>


@implementation InMemoryController

- (void)mountFailed:(NSNotification *)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSError* error = [userInfo objectForKey:kGMUserFileSystemErrorKey];
	NSLog(@"kGMUserFileSystem Error: %@, userInfo=%@", error, [error userInfo]);  
	NSRunAlertPanel(@"Mount Failed", [error localizedDescription], nil, nil, nil);
	[[NSApplication sharedApplication] terminate:nil];
}

- (void)didMount:(NSNotification *)notification {
	NSDictionary* userInfo = [notification userInfo];
	NSString* mountPath = [userInfo objectForKey:kGMUserFileSystemMountPathKey];
	NSString* parentPath = [mountPath stringByDeletingLastPathComponent];
	[[NSWorkspace sharedWorkspace] selectFile:mountPath inFileViewerRootedAtPath:parentPath];
}

- (void)didUnmount:(NSNotification*)notification {
	[[NSApplication sharedApplication] terminate:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(mountFailed:) name:kGMUserFileSystemMountFailed object:nil];
	[center addObserver:self selector:@selector(didMount:) name:kGMUserFileSystemDidMount object:nil];
	[center addObserver:self selector:@selector(didUnmount:) name:kGMUserFileSystemDidUnmount object:nil];
	
	NSString* mountPath = @"/Volumes/InMemory";
	delegate = [[InMemoryFS alloc] init];
	fs = [[GMUserFileSystem alloc] initWithDelegate:delegate isThreadSafe:NO];
	
	NSMutableArray* options = [NSMutableArray array];
	NSString* volArg = [NSString stringWithFormat:@"volicon=%@", [[NSBundle mainBundle] pathForResource:@"InMemory" ofType:@"icns"]];
	[options addObject:volArg];
	[options addObject:@"volname=InMemory"];
	[options addObject:@"local"];
	[fs mountAtPath:mountPath withOptions:options];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[fs unmount];
	[fs release];
	[delegate release];
	return NSTerminateNow;
}

@end
