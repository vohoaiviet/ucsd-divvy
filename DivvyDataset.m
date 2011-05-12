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

+ (id) datasetInDefaultContextWithFile:(NSString *)file {
  NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
  
  DivvyDataset * newItem;
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Dataset"
                                          inManagedObjectContext:context];
  
  newItem.title = [file lastPathComponent];
  newItem.n = [NSNumber numberWithUnsignedInt:100];
  newItem.d = [NSNumber numberWithUnsignedInt:5];

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
