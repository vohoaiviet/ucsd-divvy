//
//  DivvyDatasetViewPanel.m
//  Divvy
//
//  Created by Joshua Lewis on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetViewPanel.h"


@implementation DivvyDatasetViewPanel

@synthesize clustererView;
@synthesize datasetVisualizerView;

@synthesize clustererPopUp;
@synthesize datasetVisualizerPopUp;

@synthesize clustererDisclosureButton;
@synthesize datasetVisualizerDisclosureButton;

@synthesize clusterers;
@synthesize datasetVisualizers;

- (void) windowWillLoad {
  // TODO: This might not be the best way to do this...
  self.clusterers = [NSMutableArray array];
  self.datasetVisualizers = [NSMutableArray array];
  
  NSArray *properties = [NSArray arrayWithObjects:@"clustererID", @"datasetVisualizerID", nil];
  NSArray *relationships = [NSArray arrayWithObjects:self.clusterers, self.datasetVisualizers, nil];

  for(NSString *aProperty in properties)
    for(NSEntityDescription *anEntityDescription in [[[NSApp delegate] managedObjectModel] entities])
      if([anEntityDescription.propertiesByName objectForKey:aProperty] && 
         ![anEntityDescription.name isEqualToString:@"DatasetView"])
        [(NSMutableArray *)[relationships objectAtIndex:[properties indexOfObject:aProperty]] addObject:anEntityDescription];

}

- (void) dealloc {
  [self.clustererView release];
  [self.datasetVisualizerView release];

  [self.clustererPopUp release];
  [self.datasetVisualizerPopUp release];

  [self.clustererDisclosureButton release];
  [self.datasetVisualizerDisclosureButton release];  
  
  [self.clusterers release];
  
  [super dealloc];
}

@end
