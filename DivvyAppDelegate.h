//
//  DivvyAppDelegate.h
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DivvyDataset;
@class DivvyDatasetView;
@class DivvyDatasetViewPanel;
@class DivvyDatasetsPanel;
@class DivvyDatasetWindow;

@protocol DivvyClusterer;
@protocol DivvyDatasetVisualizer;
@protocol DivvyPointVisualizer;

@interface DivvyAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) DivvyDatasetViewPanel *datasetViewPanelController;
@property (retain) DivvyDatasetsPanel *datasetsPanelController;
@property (retain) DivvyDatasetWindow *datasetWindowController;

@property (retain) DivvyDataset *selectedDataset;
@property (retain) DivvyDatasetView *selectedDatasetView;

@property (retain) id <DivvyDatasetVisualizer> defaultDatasetVisualizer;
@property (retain) id <DivvyPointVisualizer> defaultPointVisualizer;
@property (retain) id <DivvyClusterer> defaultClusterer;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)openDatasets:sender;
- (IBAction)closeDatasets:sender;

- (NSArray *)defaultSortDescriptors;

- (void) datasetVisualizerChanged;
- (void) pointVisualizerChanged;
- (void) clustererChanged;
- (void) reducerChanged;

@end
