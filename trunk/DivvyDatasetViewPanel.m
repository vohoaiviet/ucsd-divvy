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
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSArray *pluginTypes = delegate.pluginTypes;

  for(NSString *pluginType in pluginTypes) {
    if(![pluginType isEqual:@"clusterer"] && ![pluginType isEqual:@"datasetVisualizer"]) continue;
    
    [self setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@ViewControllers", pluginType]];
    [self setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@s", pluginType]];
  }

  for(NSString *pluginType in pluginTypes) {
        if(![pluginType isEqual:@"clusterer"] && ![pluginType isEqual:@"datasetVisualizer"]) continue;
    
    for(NSEntityDescription *anEntityDescription in [[[NSApp delegate] managedObjectModel] entities])
      if([anEntityDescription.propertiesByName objectForKey:[NSString stringWithFormat:@"%@ID", pluginType]] && 
         ![anEntityDescription.name isEqualToString:@"DatasetView"]) {

        NSMutableArray *entities = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
        [entities addObject:anEntityDescription];
        
        Class controller = NSClassFromString([NSString stringWithFormat:@"%@%@%@", @"Divvy", anEntityDescription.name, @"Controller"]);
        NSMutableArray *controllers = [self valueForKey:[NSString stringWithFormat:@"%@ViewControllers", pluginType]];
        id controllerInstance = [[controller alloc] init];
        [controllers addObject:controllerInstance];
        [NSBundle loadNibNamed:[NSString stringWithFormat:@"%@%@", @"Divvy", anEntityDescription.name] owner:controllerInstance];
      }
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
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSArray *pluginTypes = delegate.pluginTypes;
  
  NSRect topFrame = [[self window] frame];
  
  float y = 0.f; // Go from the bottom up
  float popUpOffset = 13.f; // View borders from IB are 20px, we want 7px separation
  float disclosureButtonOffset = 7.f; // Centered disclosure buttons are 7px above their corresponding popups
  
  // Need to set topFrame height before positioning the subviews
  for(NSString *pluginType in pluginTypes) {
    if(![pluginType isEqual:@"clusterer"] && ![pluginType isEqual:@"datasetVisualizer"]) continue;
    
    NSArray *viewControllers = [self valueForKey:[NSString stringWithFormat:@"%@ViewControllers", pluginType]];
    NSArrayController *arrayController = [self valueForKey:[NSString stringWithFormat:@"%@ArrayController", pluginType]];
    NSView *view = [self valueForKey:[NSString stringWithFormat:@"%@View", pluginType]];
    NSView *popup = [self valueForKey:[NSString stringWithFormat:@"%@PopUp", pluginType]];
    
    for(NSView *aView in view.subviews)
      [aView removeFromSuperview];
    
    NSViewController *aController = [viewControllers objectAtIndex:[arrayController selectionIndex]];
        
    NSRect subFrame = [[aController view] frame];
    NSRect popUpFrame = [popup frame];
    
    y += subFrame.size.height;
    y += popUpFrame.size.height - popUpOffset;
    
  }
  
  y += 30.f; // Top border
  
  topFrame.origin.y += topFrame.size.height - y;
  topFrame.size.height = y;
  [self.window setFrame:topFrame display:YES animate:YES];
  
  y = 0.f; // Reset to position subviews
  
  for(NSString *pluginType in pluginTypes) {
    if(![pluginType isEqual:@"clusterer"] && ![pluginType isEqual:@"datasetVisualizer"]) continue;
    
    NSArray *viewControllers = [self valueForKey:[NSString stringWithFormat:@"%@ViewControllers", pluginType]];
    NSArrayController *arrayController = [self valueForKey:[NSString stringWithFormat:@"%@ArrayController", pluginType]];
    NSView *view = [self valueForKey:[NSString stringWithFormat:@"%@View", pluginType]];
    NSView *popUp = [self valueForKey:[NSString stringWithFormat:@"%@PopUp", pluginType]];
    NSView *disclosureButton = [self valueForKey:[NSString stringWithFormat:@"%@DisclosureButton", pluginType]];
    
    NSViewController *aController = [viewControllers objectAtIndex:[arrayController selectionIndex]];
    
    NSRect frame = [view frame];
    NSRect subFrame = [[aController view] frame];
    NSRect popUpFrame = [popUp frame];
    NSRect disclosureButtonFrame = [disclosureButton frame];
    
    frame.origin.y = y;
    frame.size.height = subFrame.size.height;
    y += subFrame.size.height;
    
    popUpFrame.origin.y = y - popUpOffset;
    disclosureButtonFrame.origin.y = y - popUpOffset + disclosureButtonOffset;
    y += popUpFrame.size.height - popUpOffset;
    
    [view setFrame:frame];
    [popUp setFrame:popUpFrame];
    [disclosureButton setFrame:disclosureButtonFrame];
    
    [view addSubview:[aController view]];
  }
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
