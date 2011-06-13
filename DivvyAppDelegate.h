//
//  DivvyAppDelegate.h
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DivvyDataset;
@class DivvyDatasetVisualizer;
@class DivvyPointVisualizer;
@class DivvyClusterer;
@class DivvyClustererPanel;
@class DivvyDatasetsPanel;
@class DivvyDatasetWindow;

@interface DivvyAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) DivvyClustererPanel *clustererPanelController;
@property (retain) DivvyDatasetsPanel *datasetsPanelController;
@property (retain) DivvyDatasetWindow *datasetWindowController;

@property (retain) DivvyDataset *selectedDataset;
@property (retain) DivvyDatasetVisualizer *defaultDatasetVisualizer;
@property (retain) DivvyPointVisualizer *defaultPointVisualizer;
@property (retain) DivvyClusterer *defaultClusterer;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)openDatasets:sender;
- (IBAction)closeDatasets:sender;

- (NSArray *)defaultSortDescriptors;

@end
