//
//  DivvyPCA.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyPCA.h"


@implementation DivvyPCA

@dynamic reducerID;
@dynamic name;

@dynamic firstAxis;
@dynamic secondAxis;
@dynamic rotatedData;

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  self.name = @"Principal Components Analysis";
  self.reducerID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) reduceDataset:(DivvyDataset *)dataset
           reducedData:(NSData *)reducedData {
}

@end