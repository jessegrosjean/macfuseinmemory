//
//  Item.m
//  InMemory
//
//  Created by Jesse Grosjean on 9/22/09.
//  Copyright 2009 Hog Bay Software. All rights reserved.
//

#import "Item.h"


@implementation Item

+ (id)fileWithName:(NSString *)name attributes:(NSDictionary *)attributes {
	return [[[Item alloc] initWithName:name linkDestination:nil fileType:NSFileTypeRegular attributes:attributes] autorelease];
}

+ (id)directoryWithName:(NSString *)name attributes:(NSDictionary *)attributes {
	return [[[Item alloc] initWithName:name linkDestination:nil fileType:NSFileTypeDirectory attributes:attributes] autorelease];
}

+ (id)symbolicLinkWithName:(NSString *)name linkDestination:(NSString *)linkDestination attributes:(NSDictionary *)attributes {
	return [[[Item alloc] initWithName:name linkDestination:linkDestination fileType:NSFileTypeSymbolicLink attributes:attributes] autorelease];
}

- (id)initWithName:(NSString *)aName linkDestination:(NSString *)aLinkDestination fileType:(NSString *)fileType attributes:(NSDictionary *)aDictionary {
	if (self = [super init]) {
		self.name = aName;
		NSDate *date = [NSDate date];
		attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:date, NSFileCreationDate, date, NSFileModificationDate, nil];
		[attributes addEntriesFromDictionary:aDictionary];
		[attributes setObject:fileType forKey:NSFileType];
		linkDestination = [aLinkDestination retain];
		fileContents = [[NSMutableData data] retain];
		childrenByName = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)dealloc {
	parent = nil;
	[name release];
	[linkDestination release];
	[attributes release];
	[fileContents release];
	[childrenByName release];
	[super dealloc];
}

- (BOOL)isFile {
	return [[attributes fileType] isEqualToString:NSFileTypeRegular];
}

- (BOOL)isDirectory {
	return [[attributes fileType] isEqualToString:NSFileTypeDirectory];
}

- (BOOL)isSymbolicLink {
	return [[attributes fileType] isEqualToString:NSFileTypeSymbolicLink];
}

@synthesize name;
@synthesize parent;

- (Item *)root {
	if (parent) {
		return parent.root;
	}
	return self;
}

@synthesize linkDestination;

- (NSDictionary *)attributes {
	return attributes;
}

- (void)applyAttributes:(NSDictionary *)newAttributes {
	[attributes addEntriesFromDictionary:newAttributes];
}

@synthesize fileContents;

- (int)writeFileContentsInto:(char *)buffer size:(size_t)size offset:(off_t)offset {
	NSUInteger availible = [fileContents length] - offset;
	NSUInteger read = MIN(availible, size);
	[fileContents getBytes:buffer range:NSMakeRange(offset, read)];
	return read;
}

- (int)readFileContentsFrom:(const char *)buffer size:(size_t)size offset:(off_t)offset {
	NSInteger length = [fileContents length] - (size + offset);
	if (length < 0) {
		length = [fileContents length] - offset;
	}
	[fileContents replaceBytesInRange:NSMakeRange(offset, length) withBytes:buffer length:size];
	[attributes setObject:[NSDate date] forKey:NSFileModificationDate];
	[attributes setObject:[NSNumber numberWithUnsignedInteger:[fileContents length]] forKey:NSFileSize];
	return size;
}

- (NSSet *)children {
	return [NSSet setWithArray:[childrenByName allValues]];
}

- (void)addChildrenObject:(Item *)child {
	[childrenByName setObject:child forKey:child.name];
}

- (void)removeChildrenObject:(Item *)child {
	[childrenByName removeObjectForKey:child.name];
}

- (Item *)itemByResolvingPathComponents:(NSMutableArray *)pathComponents {
	if ([pathComponents count] == 0) {
		return self;		
	}

	NSString *nextPathComponent = [pathComponents objectAtIndex:0];
	
	[pathComponents removeObjectAtIndex:0];
	
	if ([nextPathComponent isEqualToString:@"/"]) {
		return [self.root itemByResolvingPathComponents:pathComponents];
	} else if ([nextPathComponent isEqualToString:@".."]) {
		return [self.parent itemByResolvingPathComponents:pathComponents];
	} else {
		return [[childrenByName objectForKey:nextPathComponent] itemByResolvingPathComponents:pathComponents];
	}
}

- (Item *)itemByResolvingPath:(NSString *)path {
	return [self itemByResolvingPathComponents:[[[path pathComponents] mutableCopy] autorelease]];
}

@end
