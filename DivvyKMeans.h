//
//  DivvyKMeans.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyClusterer.h"

@interface DivvyKMeans : DivvyClusterer

// Core Data Accessors
@property (nonatomic, retain) NSNumber *k;
@property (nonatomic, retain) NSNumber *numRestarts;
@property (nonatomic, retain) NSNumber *initCentroidsFromPointsInDataset;

+ (id) kMeansInDefaultContext;

@end
