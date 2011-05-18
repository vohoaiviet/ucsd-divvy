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
#import "DivvyAppDelegate.h"


@implementation DivvyDatasetWindow

@synthesize datasetViewsBrowser;
@synthesize datasetViewsArrayController;

- (void) loadWindow {
  [super loadWindow];
}

- (IBAction)addDatasetViewAction:(id)sender {
  DivvyDataset *dataset = [[NSApp delegate] selectedDataset];
  [DivvyDatasetView datasetViewInDefaultContextWithDataset:dataset];
}

@end
