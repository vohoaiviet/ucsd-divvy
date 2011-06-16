//
//  DivvyKMeans.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyKMeans.h"
#import "DivvyDataset.h"

#include "kmeans.h"


@implementation DivvyKMeans

@dynamic k;
@dynamic numRestarts;
@dynamic initCentroidsFromPointsInDataset;

+ (id) kMeansInDefaultContext {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyKMeans *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"KMeans"
                                          inManagedObjectContext:context];
  
  return newItem;
}

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  
  kmeans([dataset floatData], 
         [[dataset n] unsignedIntValue], 
         [[dataset d] unsignedIntValue], 
         [[self k] unsignedIntValue],
         (int *)[assignment bytes]);
}

@end
