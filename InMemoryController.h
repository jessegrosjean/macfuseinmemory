//
//  InMemoryController.h
//  InMemory
//
//  Created by Jesse Grosjean on 9/22/09.
//  Copyright 2009 Hog Bay Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GMUserFileSystem;
@class InMemoryController;

@interface InMemoryController : NSObject {
	GMUserFileSystem* fs;
	InMemoryController* delegate;
}

@end