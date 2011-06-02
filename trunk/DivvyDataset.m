// 
//  Dataset.m
//  Divvy
//
//  Created by Joshua Lewis on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDataset.h"

@implementation DivvyDataset 

@dynamic d;
@dynamic data;
@dynamic n;
@dynamic title;

@dynamic datasetViews;

+ (id) datasetInDefaultContextWithFile:(NSString *)path {
  NSManagedObjectContext * context = [[NSApp delegate] managedObjectContext];
  
  DivvyDataset * newItem;
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Dataset"
                                          inManagedObjectContext:context];
  
  newItem.title = [[path lastPathComponent] stringByDeletingPathExtension];
  
  newItem.data = [NSData dataWithContentsOfFile:path];
  
  unsigned int n;
  unsigned int d;
  
  [newItem.data getBytes:&n range:NSMakeRange(0, 4)];
  [newItem.data getBytes:&d range:NSMakeRange(4, 4)];
  
  newItem.n = [NSNumber numberWithUnsignedInt:n];
  newItem.d = [NSNumber numberWithUnsignedInt:d];

  return newItem;
}

- (float *) floatData {
  return (float *)(self.data.bytes + 8); // Offset by 8 bytes to avoid header info
}

- (void) dealloc {
  [super dealloc];
}

@end
