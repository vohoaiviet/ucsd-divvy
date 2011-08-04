//
//  DivvyDatasetWindow.m
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetWindow.h"

#import "DivvyAppDelegate.h"

#import "DivvyDataset.h"
#import "DivvyDatasetView.h"

#import "DivvyDatasetViewPanel.h"

#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import "DivvyClusterer.h"

#import "DivvyAppDelegate.h"

@implementation DivvyDatasetWindow

@synthesize datasetViewsBrowser;
@synthesize datasetViewsArrayController;

- (void) loadWindow {
  [super loadWindow];
  
  NSSortDescriptor *dateCreatedDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES] autorelease];
  NSArray *sortDescriptors = [NSArray arrayWithObjects:dateCreatedDescriptor, nil];
  
  [datasetViewsArrayController setSortDescriptors:sortDescriptors];
}

- (IBAction)addDatasetViewAction:(id)sender {
  DivvyDataset *dataset = [[NSApp delegate] selectedDataset];
  
  DivvyDatasetView *view = [DivvyDatasetView datasetViewInDefaultContextWithDataset:dataset];
  
  view.pointVisualizer = [[NSApp delegate] defaultPointVisualizer];
  view.pointVisualizerID = view.pointVisualizer.pointVisualizerID;
}

- (void) imageBrowserSelectionDidChange:(IKImageBrowserView *) aBrowser {
  NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];
  DivvyAppDelegate *delegate = [NSApp delegate];

  if(selectionIndexes.count == 0) {
    [delegate setValue:nil forKey:@"selectedDatasetView"];
    [delegate.datasetViewPanelController reflow];
  }
  else {
    NSArray *datasetViews = [self.datasetViewsArrayController arrangedObjects];
    
    DivvyDatasetView *datasetView = [datasetViews objectAtIndex:[selectionIndexes lastIndex]];
    [delegate setValue:nil forKey:@"selectedDatasetView"];
    [delegate setValue:datasetView forKey:@"selectedDatasetView"];
    
    //[delegate.datasetViewPanelController.clustererPopUp selectItemAtIndex:[datasetView.clusterers indexOfObject:datasetView.selectedClusterer]];
    [delegate.datasetViewPanelController reflow];
  }
}

- (void) dealloc {
  [self.datasetViewsBrowser release];
  [self.datasetViewsArrayController release];
  
  [super dealloc];
}

@end
