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
		self.linkDestination = aLinkDestination;
		attributes = [[NSMutableDictionary alloc] init];
		[attributes addEntriesFromDictionary:aDictionary];
		[attributes setObject:fileType forKey:NSFileType];
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

@synthesize parent;

- (Item *)root {
	if (parent) {
		return parent.root;
	}
	return self;
}

@synthesize name;
@synthesize linkDestination;
@synthesize fileContents;
@synthesize attributes;

- (NSMutableDictionary *)attributes {
	if (![attributes fileCreationDate]) [attributes setObject:[NSDate date] forKey:NSFileCreationDate];
	if (![attributes fileModificationDate]) [attributes setObject:[NSDate date] forKey:NSFileModificationDate];
	[attributes setObject:[NSNumber numberWithUnsignedInteger:[fileContents length]] forKey:NSFileSize];
	return attributes;
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
