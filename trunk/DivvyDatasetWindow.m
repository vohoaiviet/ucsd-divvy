//
//  DivvyDatasetWindow.m
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetWindow.h"

#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import "DivvyClusterer.h"

#import "DivvyAppDelegate.h"

@implementation DivvyDatasetWindow

@synthesize datasetViewsBrowser;
@synthesize datasetViewsArrayController;

- (void) loadWindow {
  [super loadWindow];
}

- (IBAction)addDatasetViewAction:(id)sender {
  DivvyDataset *dataset = [[NSApp delegate] selectedDataset];
  id <DivvyDatasetVisualizer> datasetVisualizer = [[NSApp delegate] defaultDatasetVisualizer];
  
  DivvyDatasetView *view = [DivvyDatasetView datasetViewInDefaultContextWithDataset:dataset
                                                                  datasetVisualizer:datasetVisualizer];
  
  view.pointVisualizer = [[NSApp delegate] defaultPointVisualizer];
  view.pointVisualizerID = view.pointVisualizer.pointVisualizerID;
  
  view.clusterer = [[NSApp delegate] defaultClusterer];
  view.clustererID = view.clusterer.clustererID;
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
  NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];

  if(selectionIndexes.count == 0) {
    [[NSApp delegate] setValue:nil forKey:@"selectedDatasetView"];
  }
  else {
    NSArray *datasetViews = [self.datasetViewsArrayController arrangedObjects];
    
    DivvyDatasetView *datasetView = [datasetViews objectAtIndex:[selectionIndexes lastIndex]];
    [[NSApp delegate] setValue:nil forKey:@"selectedDatasetView"];
    [[NSApp delegate] setValue:datasetView forKey:@"selectedDatasetView"];
  }
}

- (void) dealloc {
  [self.datasetViewsBrowser release];
  [self.datasetViewsArrayController release];
  
  [super dealloc];
}

@end
