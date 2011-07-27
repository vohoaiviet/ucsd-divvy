//
//  DivvyDatasetViewPanel.h
//  Divvy
//
//  Created by Joshua Lewis on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DivvyDatasetViewPanel : NSWindowController

@property (retain) IBOutlet NSView *clustererView;
@property (retain) IBOutlet NSView *datasetVisualizerView;

@property (retain) IBOutlet NSPopUpButton *clustererPopUp;
@property (retain) IBOutlet NSPopUpButton *datasetVisualizerPopUp;

@property (retain) IBOutlet NSButton *clustererDisclosureButton;
@property (retain) IBOutlet NSButton *datasetVisualizerDisclosureButton;

@property (retain) NSArray *clusterers;
@property (retain) NSArray *datasetVisualizers;

@end
