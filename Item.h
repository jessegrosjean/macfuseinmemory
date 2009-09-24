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
@property(readonly) Item *parent;
@property(readonly) Item *root;
@property(retain) NSString *name;
@property(retain) NSString *linkDestination;
@property(retain) NSMutableData *fileContents;
@property(retain) NSMutableDictionary *attributes;

@property(readonly) NSSet *children;
- (void)addChildrenObject:(Item *)child;
- (void)removeChildrenObject:(Item *)child;
- (Item *)itemByResolvingPath:(NSString *)path;

@end
