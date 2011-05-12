//
//  DivvyAppDelegate.h
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DivvyDatasetsPanel;

@interface DivvyAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) DivvyDatasetsPanel *datasetsPanelController;

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)openDatasets:sender;
- (IBAction)closeDatasets:sender;

@end
