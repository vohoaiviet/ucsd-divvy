//
//  DivvyDatasetViewPanel.m
//  Divvy
//
//  Created by Joshua Lewis on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetViewPanel.h"
#import "DivvyAppDelegate.h"
#import "DivvyDatasetView.h"
#import "DivvyClusterer.h"


@implementation DivvyDatasetViewPanel

@synthesize clustererView;
@synthesize datasetVisualizerView;

@synthesize clustererPopUp;
@synthesize datasetVisualizerPopUp;

@synthesize clustererDisclosureButton;
@synthesize datasetVisualizerDisclosureButton;

@synthesize clustererArrayController;
@synthesize datasetVisualizerArrayController;

@synthesize clustererViewControllers;
@synthesize datasetVisualizerViewControllers;

@synthesize clusterers;
@synthesize datasetVisualizers;

- (void) windowWillLoad {
  // TODO: This might not be the best way to do this...
  self.clustererViewControllers = [NSMutableArray array];
  self.datasetVisualizerViewControllers = [NSMutableArray array];  
  
  self.clusterers = [NSMutableArray array];
  self.datasetVisualizers = [NSMutableArray array];
  
  NSArray *properties = [NSArray arrayWithObjects:@"clustererID", @"datasetVisualizerID", nil];
  NSArray *relationships = [NSArray arrayWithObjects:self.clusterers, self.datasetVisualizers, nil];
  NSArray *viewControllers = [NSArray arrayWithObjects:self.clustererViewControllers, self.datasetVisualizerViewControllers, nil];

  for(NSString *aProperty in properties)
    for(NSEntityDescription *anEntityDescription in [[[NSApp delegate] managedObjectModel] entities])
      if([anEntityDescription.propertiesByName objectForKey:aProperty] && 
         ![anEntityDescription.name isEqualToString:@"DatasetView"]) {

        NSMutableArray *entities = [relationships objectAtIndex:[properties indexOfObject:aProperty]];
        [entities addObject:anEntityDescription];
        
        Class controller = NSClassFromString([NSString stringWithFormat:@"%@%@%@", @"Divvy", anEntityDescription.name, @"Controller"]);
        NSMutableArray * controllers = [viewControllers objectAtIndex:[properties indexOfObject:aProperty]];
        id controllerInstance = [[controller alloc] init];
        [controllers addObject:controllerInstance];
        [NSBundle loadNibNamed:[NSString stringWithFormat:@"%@%@", @"Divvy", anEntityDescription.name] owner:controllerInstance];
      }
}

- (IBAction) clustererSelect:(id)sender {
  [self reflow];
  
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSManagedObjectContext *moc = delegate.managedObjectContext;
  DivvyDatasetView *datasetView = delegate.selectedDatasetView;
  
  [moc deleteObject:(NSManagedObject *)datasetView.clusterer];
  
  NSEntityDescription *newClusterer = [clusterers objectAtIndex:[clustererArrayController selectionIndex]];
  datasetView.clusterer = (id <DivvyClusterer>)[NSEntityDescription insertNewObjectForEntityForName:newClusterer.name
                                                                             inManagedObjectContext:moc];

  datasetView.clustererID = datasetView.clusterer.clustererID;
  
  [delegate clustererChanged];
}

- (void) reflow {
  NSViewController *clustererController = [clustererViewControllers objectAtIndex:[clustererArrayController selectionIndex]];
  NSViewController *datasetVisualizerController = [datasetVisualizerViewControllers objectAtIndex:[datasetVisualizerArrayController selectionIndex]];
  
  for(NSView *aView in self.clustererView.subviews)
    [aView removeFromSuperview];
  
  for(NSView *aView in self.datasetVisualizerView.subviews)
    [aView removeFromSuperview];
  
  NSRect topFrame = [[self window] frame];
  
  NSRect clustererFrame = [self.clustererView frame];
  NSRect subClustererFrame = [[clustererController view] frame];
  NSRect clustererPopUpFrame = [self.clustererPopUp frame];
  NSRect clustererDisclosureButtonFrame = [self.clustererDisclosureButton frame];
  
  NSRect datasetVisualizerFrame = [self.datasetVisualizerView frame];
  NSRect subDatasetVisualizerFrame = [[datasetVisualizerController view] frame];
  NSRect datasetVisualizerPopUpFrame = [self.datasetVisualizerPopUp frame];
  NSRect datasetVisualizerDisclosureButtonFrame = [self.datasetVisualizerDisclosureButton frame];
  
  float y = 0.f; // Go from the bottom up
  float popUpOffset = 8.f;
  float disclosureButtonOffset = 8.f;
  
  datasetVisualizerFrame.size.height = subDatasetVisualizerFrame.size.height;
  y += subDatasetVisualizerFrame.size.height;
  
  datasetVisualizerPopUpFrame.origin.y = y - popUpOffset;
  datasetVisualizerDisclosureButtonFrame.origin.y = y - popUpOffset + disclosureButtonOffset;
  y += datasetVisualizerPopUpFrame.size.height - popUpOffset;
  
  clustererFrame.origin.y = y;
  clustererFrame.size.height = subClustererFrame.size.height;
  y += subClustererFrame.size.height;
  
  clustererPopUpFrame.origin.y = y - popUpOffset;
  clustererDisclosureButtonFrame.origin.y = y - popUpOffset + disclosureButtonOffset;
  y += clustererPopUpFrame.size.height - popUpOffset;
  
  y += 26.f; // Top border
  
  topFrame.size.height = y;
  [self.window setFrame:topFrame display:YES animate:YES];
  [self.datasetVisualizerView setFrame:datasetVisualizerFrame];
  [self.datasetVisualizerPopUp setFrame:datasetVisualizerPopUpFrame];
  [self.datasetVisualizerDisclosureButton setFrame:datasetVisualizerDisclosureButtonFrame];
  [self.clustererView setFrame:clustererFrame];
  [self.clustererPopUp setFrame:clustererPopUpFrame];
  [self.clustererDisclosureButton setFrame:clustererDisclosureButtonFrame];
  
  [self.clustererView addSubview:[clustererController view]];
  [self.datasetVisualizerView addSubview:[datasetVisualizerController view]];  
}

- (void) dealloc {
  [self.clustererView release];
  [self.datasetVisualizerView release];

  [self.clustererPopUp release];
  [self.datasetVisualizerPopUp release];

  [self.clustererDisclosureButton release];
  [self.datasetVisualizerDisclosureButton release];  

  [self.clustererArrayController release];
  [self.datasetVisualizerArrayController release];  
  
  [self.clusterers release];
  [self.datasetVisualizers release];
  
  [super dealloc];
}

@end
