// 
//  Dataset.m
//  Divvy
//
//  Created by Joshua Lewis on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDataset.h"

@interface DivvyDataset ()
- (void) generateUniqueID;
@end

@implementation DivvyDataset 

@dynamic d;
@dynamic data;
@dynamic n;
@dynamic title;
@dynamic uniqueID;

+ (id) datasetInDefaultContextWithFile:(NSString *)path {
  NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
  
  DivvyDataset * newItem;
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Dataset"
                                          inManagedObjectContext:context];
  
  newItem.title = [path lastPathComponent];
  
  newItem.data = [NSData dataWithContentsOfFile:path];
  
  unsigned int n;
  unsigned int d;
  
  [newItem.data getBytes:&n range:NSMakeRange(0, 4)];
  [newItem.data getBytes:&d range:NSMakeRange(4, 4)];
  
  newItem.n = [NSNumber numberWithUnsignedInt:n];
  newItem.d = [NSNumber numberWithUnsignedInt:d];

  return newItem;
}

- (void) awakeFromInsert {
  [self generateUniqueID];
}

- (void) generateUniqueID {
  NSString * unqiueID = self.uniqueID;
  if(unqiueID != nil) return;
  self.uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) dealloc {
  [super dealloc];
}

@end
