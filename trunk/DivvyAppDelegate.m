//
//  DivvyAppDelegate.m
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"
#import "DivvyDatasetView.h"
#import "DivvyDatasetViewPanel.h"
#import "DivvyDatasetsPanel.h"
#import "DivvyDatasetWindow.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyScatterPlot.h"
#import "DivvyPointVisualizer.h"
#import "DivvyZhu.h"
#import "DivvyClusterer.h"
#import "DivvyKMeans.h"

@implementation DivvyAppDelegate

@synthesize datasetViewPanelController;
@synthesize datasetsPanelController;
@synthesize datasetWindowController;

@synthesize selectedDataset;
@synthesize selectedDatasetView;

@synthesize defaultDatasetVisualizer;
@synthesize defaultPointVisualizer;
@synthesize defaultClusterer;

@synthesize persistentStoreCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;


- (void) clustererChanged {
  [[self selectedDatasetView] clustererChanged];
  [[[self datasetWindowController] datasetViewsBrowser] reloadData];
}

- (void) datasetVisualizerChanged {}
- (void) pointVisualizerChanged {}
- (void) reducerChanged {}

- (id <DivvyDatasetVisualizer>)defaultDatasetVisualizer {
  if (defaultDatasetVisualizer) return defaultDatasetVisualizer;
  
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"ScatterPlot" inManagedObjectContext:moc];
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  
  NSError *error = nil;
  NSArray *array = [moc executeFetchRequest:request error:&error];
  if (array == nil || array.count == 0) {
    self.defaultDatasetVisualizer = [DivvyScatterPlot scatterPlotInDefaultContext];
  }
  else {
    self.defaultDatasetVisualizer = (id <DivvyDatasetVisualizer>)[array objectAtIndex:0];
  }
  
  return defaultDatasetVisualizer;
}

- (id <DivvyPointVisualizer>)defaultPointVisualizer {
  if (defaultPointVisualizer) return defaultPointVisualizer;
  
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSEntityDescription *entityDescription = [NSEntityDescription
                                            entityForName:@"Zhu" inManagedObjectContext:moc];
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  [request setEntity:entityDescription];
  
  NSError *error = nil;
  NSArray *array = [moc executeFetchRequest:request error:&error];
  if (array == nil || array.count == 0) {
    self.defaultPointVisualizer = [DivvyZhu zhuInDefaultContext];
  }
  else {
    self.defaultPointVisualizer = (id <DivvyPointVisualizer>)[array objectAtIndex:0];
  }
  
  return defaultPointVisualizer;
}

- (id <DivvyClusterer>)defaultClusterer {
  //return [DivvyKMeans kMeansInDefaultContext];
  return nil;
}

- (NSArray *)defaultSortDescriptors {
  return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
}

- (IBAction) openDatasets:(id)sender {
  int result;
  NSArray *fileTypes = [NSArray arrayWithObject:@"bin"];
  NSOpenPanel *oPanel = [NSOpenPanel openPanel];
  
  [oPanel setAllowsMultipleSelection:YES];
  result = [oPanel runModalForDirectory:NSHomeDirectory()
                                   file:nil types:fileTypes];
  if (result == NSOKButton) {
    NSArray *filesToOpen = [oPanel filenames];
    int i, count = [filesToOpen count];
    for (i=0; i<count; i++) {
      NSString *aFile = [filesToOpen objectAtIndex:i];
      [DivvyDataset datasetInDefaultContextWithFile:aFile];
    }
  }
}

- (IBAction) closeDatasets:(id)sender {
  DivvyDatasetsPanel *panelController = self.datasetsPanelController;
  NSTableView *datasetsTable = [panelController datasetsTable];
  NSIndexSet *selections = datasetsTable.selectedRowIndexes;
  NSArray *datasets = [[datasetsPanelController datasetsArrayController] arrangedObjects];
  
  NSArray *selectedDatasets = [datasets objectsAtIndexes:selections];
  for (id dataset in selectedDatasets) {
    for (id datasetView in [[dataset datasetViews] allObjects])
      [managedObjectContext deleteObject:datasetView];
    [managedObjectContext deleteObject:dataset];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  DivvyDatasetsPanel *panelController;
  panelController = [[DivvyDatasetsPanel alloc] initWithWindowNibName:@"DatasetsPanel"];
  [panelController showWindow:nil];  
  self.datasetsPanelController = panelController;
  [panelController release];

  DivvyDatasetViewPanel *panelController2;
  panelController2 = [[DivvyDatasetViewPanel alloc] initWithWindowNibName:@"DatasetViewPanel"];
  [panelController2 showWindow:nil];  
  self.datasetViewPanelController = panelController2;
  [panelController2 release];  
  
  DivvyDatasetWindow *windowController;
  windowController = [[DivvyDatasetWindow alloc] initWithWindowNibName:@"DatasetWindow"];
  [windowController showWindow:nil];  
  self.datasetWindowController = windowController;
  [windowController release];
}

/**
 Returns the support directory for the application, used to store the Core Data
 store file.  This code uses a directory named "Divvy" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:@"Divvy"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
  
  if (managedObjectModel) return managedObjectModel;
	
  managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
  return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The directory for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
  
  if (persistentStoreCoordinator) return persistentStoreCoordinator;
  
  NSManagedObjectModel *mom = [self managedObjectModel];
  if (!mom) {
    NSAssert(NO, @"Managed object model is nil");
    NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
    return nil;
  }
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *applicationSupportDirectory = [self applicationSupportDirectory];
  NSError *error = nil;
  
  if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
      NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
      NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
      return nil;
		}
  }
  
  NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType 
                                                configuration:nil 
                                                          URL:url 
                                                      options:nil 
                                                        error:&error]){
    [[NSApplication sharedApplication] presentError:error];
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    return nil;
  }    
  
  return persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
  
  if (managedObjectContext) return managedObjectContext;
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (!coordinator) {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
    [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
    NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
    [[NSApplication sharedApplication] presentError:error];
    return nil;
  }
  managedObjectContext = [[NSManagedObjectContext alloc] init];
  [managedObjectContext setPersistentStoreCoordinator: coordinator];
  
  return managedObjectContext;
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
  return [[self managedObjectContext] undoManager];
}


/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */

- (IBAction) saveAction:(id)sender {
  
  NSError *error = nil;
  
  if (![[self managedObjectContext] commitEditing]) {
    NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
  }
  
  if (![[self managedObjectContext] save:&error]) {
    [[NSApplication sharedApplication] presentError:error];
  }
}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {  
  // Stops a bunch of CoreGraphics errors from the binding between the dataset window
  // title and the selected dataset title. There's probably a better way to fix them though.
  self.selectedDataset = nil;
  
  if (!managedObjectContext) return NSTerminateNow;
  
  if (![managedObjectContext commitEditing]) {
    NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
    return NSTerminateCancel;
  }
  
  if (![managedObjectContext hasChanges]) return NSTerminateNow;
  
  NSError *error = nil;
  if (![managedObjectContext save:&error]) {
    
    // This error handling simply presents error information in a panel with an 
    // "Ok" button, which does not include any attempt at error recovery (meaning, 
    // attempting to fix the error.)  As a result, this implementation will 
    // present the information to the user and then follow up with a panel asking 
    // if the user wishes to "Quit Anyway", without saving the changes.
    
    // Typically, this process should be altered to include application-specific 
    // recovery steps.  
    
    BOOL result = [sender presentError:error];
    if (result) return NSTerminateCancel;
    
    NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
    NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
    NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
    NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:question];
    [alert setInformativeText:info];
    [alert addButtonWithTitle:quitButton];
    [alert addButtonWithTitle:cancelButton];
    
    NSInteger answer = [alert runModal];
    [alert release];
    alert = nil;
    
    if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
    
  }
  
  return NSTerminateNow;
}


/**
 Implementation of dealloc, to release the retained variables.
 */

- (void)dealloc {
  
  [managedObjectContext release];
  [persistentStoreCoordinator release];
  [managedObjectModel release];
  
  [datasetsPanelController release];
  [datasetViewPanelController release];
  [datasetWindowController release];
  
  [super dealloc];
}

@end
