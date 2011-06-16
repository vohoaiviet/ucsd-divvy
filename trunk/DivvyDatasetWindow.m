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
#import "DivvyAppDelegate.h"

#import "DivvyZhu.h" // Temp hack


@implementation DivvyDatasetWindow

@synthesize datasetViewsBrowser;
@synthesize datasetViewsArrayController;

- (void) loadWindow {
  [super loadWindow];
}

- (IBAction)addDatasetViewAction:(id)sender {
  DivvyDataset *dataset = [[NSApp delegate] selectedDataset];
  DivvyDatasetVisualizer *datasetVisualizer = [[NSApp delegate] defaultDatasetVisualizer];
  DivvyDatasetView *view = [DivvyDatasetView datasetViewInDefaultContextWithDataset:dataset
                                                                  datasetVisualizer:datasetVisualizer];
  [view setPointVisualizer:[[NSApp delegate] defaultPointVisualizer]];
  [view setClusterer:[[NSApp delegate] defaultClusterer]];
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
  NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];

  if(selectionIndexes.count == 0) {
    [[NSApp delegate] setValue:nil forKey:@"selectedDatasetView"];
  }
  else {
    NSArray *datasetViews = [self.datasetViewsArrayController arrangedObjects];
    
    DivvyDatasetView *datasetView = [datasetViews objectAtIndex:[selectionIndexes lastIndex]];
    [[NSApp delegate] setValue:datasetView forKey:@"selectedDatasetView"];
  }
}

@end
