//
//  InMemoryFS.h
//  InMemory
//
//  Created by Jesse Grosjean on 9/22/09.
//  Copyright 2009 Hog Bay Software. All rights reserved.
//

#import <MacFUSE/MacFUSE.h>


@class Item;

@interface InMemoryFS : NSObject  {
	Item *root;
}

@end
