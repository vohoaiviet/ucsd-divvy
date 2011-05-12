//
//  DivvyDatasetPanel.m
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetsPanel.h"
#import "DivvyDataset.h"

@implementation DivvyDatasetsPanel

@synthesize datasetsTable;
@synthesize datasetsArrayController;

- (void) loadWindow {
  [super loadWindow];
}

- (void) dealloc {
  
  [self.datasetsTable release];
  [self.datasetsArrayController release];
  
  [super dealloc];
}

@end
