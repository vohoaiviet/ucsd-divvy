//
//  DivvyDatasetPanel.m
//  Divvy
//
//  Created by Joshua Lewis on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyAppDelegate.h"
#import "DivvyDatasetsPanel.h"
#import "DivvyDataset.h"

@implementation DivvyDatasetsPanel

@synthesize datasetsTable;
@synthesize datasetsArrayController;

- (void) loadWindow {
  [super loadWindow];
}

- (IBAction) editDatasets:(id)sender {
  NSInteger selectedSegment = [sender selectedSegment];
  NSInteger clickedSegmentTag = [[sender cell] tagForSegment:selectedSegment];
  
  if (clickedSegmentTag == 0) // Add button
    [[NSApp delegate] openDatasets:sender];
  else // Remove button
    [[NSApp delegate] closeDatasets:sender];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  
  NSTableView* table     = [notification object];
  NSInteger    selection = table.selectedRow;
  
  if(selection == -1) {
    [[NSApp delegate] setValue:nil forKey:@"selectedDataset"];
  }
  else {
    NSArray *datasets = [self.datasetsArrayController arrangedObjects];
    
    DivvyDataset *dataset = [datasets objectAtIndex:selection];
    [[NSApp delegate] setValue:dataset forKey:@"selectedDataset"];
  }
}

- (void) dealloc {
  
  [self.datasetsTable release];
  [self.datasetsArrayController release];
  
  [super dealloc];
}

@end
