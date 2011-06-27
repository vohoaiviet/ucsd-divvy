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

@dynamic uniqueID;
@dynamic k;
@dynamic numRestarts;
@dynamic initCentroidsFromPointsInDataset;

- (void) clusterDataset:(DivvyDataset *)dataset
             assignment:(NSData *)assignment {
  
  kmeans([dataset floatData], 
         [[dataset n] unsignedIntValue], 
         [[dataset d] unsignedIntValue], 
         [[self k] unsignedIntValue],
         (int *)[assignment bytes]);
}

@end
