//
//  Item.h
//  InMemory
//
//  Created by Jesse Grosjean on 9/22/09.
//  Copyright 2009 Hog Bay Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Item : NSObject {
	Item *parent;
	NSString *name;
	NSString *linkDestination;
	NSMutableDictionary *attributes;
	NSMutableData *fileContents;
	NSMutableDictionary *childrenByName;
}

+ (id)fileWithName:(NSString *)name attributes:(NSDictionary *)attributes;
+ (id)directoryWithName:(NSString *)name attributes:(NSDictionary *)attributes;
+ (id)symbolicLinkWithName:(NSString *)name linkDestination:(NSString *)linkDestination attributes:(NSDictionary *)attributes;

- (id)initWithName:(NSString *)name linkDestination:(NSString *)aLinkDestination fileType:(NSString *)fileType attributes:(NSDictionary *)aDictionary;

@property(readonly) BOOL isFile;
@property(readonly) BOOL isDirectory;
@property(readonly) BOOL isSymbolicLink;

@property(retain) NSString *name;
@property(readonly) Item *parent;
@property(readonly) Item *root;
@property(readonly) NSString *linkDestination;

@property(readonly) NSDictionary *attributes;
- (void)applyAttributes:(NSDictionary *)newAttributes;

@property(readonly) NSData *fileContents;
- (int)writeFileContentsInto:(char *)buffer size:(size_t)size offset:(off_t)offset;
- (int)readFileContentsFrom:(const char *)buffer size:(size_t)size offset:(off_t)offset;		

@property(readonly) NSSet *children;
- (void)addChildrenObject:(Item *)child;
- (void)removeChildrenObject:(Item *)child;
- (Item *)itemByResolvingPath:(NSString *)path;

@end
