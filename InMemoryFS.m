//
//  InMemoryFS.m
//  InMemory
//
//  Created by Jesse Grosjean on 9/22/09.
//  Copyright 2009 Hog Bay Software. All rights reserved.
//

#import <sys/xattr.h>
#import <sys/stat.h>
#import "InMemoryFS.h"
#import "Item.h"


@interface NSError (POSIX)
+ (NSError *)errorWithPOSIXCode:(int)code;
@end

@implementation InMemoryFS

- (id)init {
	if (self = [super init]) {
		root = [[Item directoryWithName:@"/" attributes:[NSDictionary dictionary]] retain];
	}
	return self;
}

- (void)dealloc { 
	[root release];
	[super dealloc];
}

- (Item *)itemForPath:(NSString *)path error:(NSError **)error {
	Item *item = [root itemByResolvingPath:path];
	if (!item) {
		if (error) {
			*error = [NSError errorWithPOSIXCode:ENOENT];
		}
	}
	return item;
}

#pragma mark Directory Contents

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
	return [[[[root itemByResolvingPath:path] children] valueForKey:@"name"] allObjects];
}

#pragma mark Attributes

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path userData:(id)userData error:(NSError **)error {
	return [[self itemForPath:path error:error] attributes];
}

- (NSDictionary *)attributesOfFileSystemForPath:(NSString *)path error:(NSError **)error {
	if ([self itemForPath:path error:error]) {
		return [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kGMUserFileSystemVolumeSupportsExtendedDatesKey];
	}
	return nil;
}

- (BOOL)setAttributes:(NSDictionary *)attributes ofItemAtPath:(NSString *)path userData:(id)userData error:(NSError **)error {
	Item *item = [self itemForPath:path error:error];
	if (item) {
		[item applyAttributes:attributes];
		return YES;
	}
	return NO; 
}

#pragma mark File Contents

- (BOOL)openFileAtPath:(NSString *)path mode:(int)mode userData:(id *)userData error:(NSError **)error {
	*userData = [[self itemForPath:path error:error] retain];
	return *userData != nil;
}

- (void)releaseFileAtPath:(NSString *)path userData:(id)userData {
	[userData release];
}

- (int)readFileAtPath:(NSString *)path userData:(id)userData buffer:(char *)buffer size:(size_t)size offset:(off_t)offset error:(NSError **)error {
	if (userData) {
		return [userData writeFileContentsInto:buffer size:size offset:offset];
	}
	return -1;
}

- (int)writeFileAtPath:(NSString *)path userData:(id)userData buffer:(const char *)buffer size:(size_t)size offset:(off_t)offset error:(NSError **)error {
	Item *item = [self itemForPath:path error:error];
	if (item) {
		return [item readFileContentsFrom:buffer size:size offset:offset];
	}	
	return -1;
}

#pragma mark Creating an Item

- (BOOL)createDirectoryAtPath:(NSString *)path attributes:(NSDictionary *)attributes error:(NSError **)error {
	Item *parent = [root itemByResolvingPath:[path stringByDeletingLastPathComponent]];
	if (parent) {
		[parent addChildrenObject:[Item directoryWithName:[path lastPathComponent] attributes:attributes]];
		return YES;
	}
	return NO;
}

- (BOOL)createFileAtPath:(NSString *)path attributes:(NSDictionary *)attributes userData:(id *)userData error:(NSError **)error {
	Item *parent = [root itemByResolvingPath:[path stringByDeletingLastPathComponent]];
	if (parent) {
		[parent addChildrenObject:[Item fileWithName:[path lastPathComponent] attributes:attributes]];
		return YES;
	}
	return NO;
}

#pragma mark Symbolic Links

- (BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)otherPath error:(NSError **)error {
	if ([self itemForPath:path error:NULL]) {
		return NO;
	}
	
	Item *linkParent = [self itemForPath:[path stringByDeletingLastPathComponent] error:error];
	if (linkParent != nil) {
		[linkParent addChildrenObject:[Item symbolicLinkWithName:[path lastPathComponent] linkDestination:otherPath attributes:nil]];
		return YES;
	}
	
	return NO;
}

- (NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError **)error {
	return [self itemForPath:path error:error].linkDestination;
}

#pragma mark Moving an Item

- (BOOL)moveItemAtPath:(NSString *)source toPath:(NSString *)destination error:(NSError **)error {
	Item *newParent = [self itemForPath:[destination stringByDeletingLastPathComponent] error:error];;
	if (newParent) {
		Item *oldParent = [self itemForPath:[source stringByDeletingLastPathComponent] error:error];
		Item *toMove = [[[self itemForPath:source error:error] retain] autorelease];
		if (toMove) {
			[oldParent removeChildrenObject:toMove];
			toMove.name = [destination lastPathComponent];
			[newParent addChildrenObject:toMove];
			return YES;
		}
	}
	return NO;
}

#pragma mark Removing an Item

- (BOOL)removeDirectoryAtPath:(NSString *)path error:(NSError **)error {
	Item *toRemove = [self itemForPath:path error:error];
	Item *parent = [self itemForPath:[path stringByDeletingLastPathComponent] error:error];
	if (parent != nil && toRemove != nil && toRemove.isDirectory && [toRemove.children count] == 0) {
		[parent removeChildrenObject:toRemove];
		return YES;
	}
	return NO;
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
	Item *toRemove = [self itemForPath:path error:error];
	Item *parent = [self itemForPath:[path stringByDeletingLastPathComponent] error:error];
	if (parent != nil && toRemove != nil && !toRemove.isDirectory) {
		[parent removeChildrenObject:toRemove];
		return YES;
	}
	return NO;
}

@end

@implementation NSError (POSIX)

+ (NSError *)errorWithPOSIXCode:(int) code {
	return [NSError errorWithDomain:NSPOSIXErrorDomain code:code userInfo:nil];
}

@end