//
//  DivvyDatasetView.m
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetView.h"

#import "DivvyAppDelegate.h"
#import "DivvyDataset.h"

#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import "DivvyClusterer.h"
#import "DivvyReducer.h"

@interface DivvyDatasetView ()
@property (retain) NSImage *renderedImage;
- (void) generateUniqueID;
@end

@implementation DivvyDatasetView

@dynamic uniqueID;
@dynamic version;
@dynamic dateCreated;

@dynamic dataset;

@dynamic datasetVisualizerIDs;
@dynamic pointVisualizerIDs;
@dynamic clustererIDs;
@dynamic reducerIDs;

@dynamic selectedDatasetVisualizerID;
@dynamic selectedPointVisualizerID;
@dynamic selectedClustererID;
@dynamic selectedReducerID;

@dynamic datasetVisualizerResults;
@dynamic pointVisualizerResults;
@dynamic clustererResults;
@dynamic reducerResults;

@synthesize datasetVisualizers;
@synthesize pointVisualizers;
@synthesize clusterers;
@synthesize reducers;

@synthesize selectedDatasetVisualizer;
@synthesize selectedPointVisualizer;
@synthesize selectedClusterer;
@synthesize selectedReducer;

@synthesize renderedImage;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset {
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSManagedObjectContext* moc = delegate.managedObjectContext;
  NSManagedObjectModel* mom = delegate.managedObjectModel;
  NSArray *pluginTypes = delegate.pluginTypes;
  NSArray *pluginDefaults = delegate.pluginDefaults;
  
  DivvyDatasetView *datasetView;    
  datasetView = [NSEntityDescription insertNewObjectForEntityForName:@"DatasetView"
                                               inManagedObjectContext:moc];

  datasetView.dateCreated = [NSDate date];  
  
  datasetView.dataset = dataset;
  
  
  for(NSString *pluginType in pluginTypes) {
    [datasetView setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@s", pluginType]];
    [datasetView setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
    
    for(NSEntityDescription *anEntityDescription in [mom entities])
      if([anEntityDescription.propertiesByName objectForKey:[NSString stringWithFormat:@"%@ID", pluginType]]) {
        
        id anEntity = [NSEntityDescription insertNewObjectForEntityForName:anEntityDescription.name inManagedObjectContext:moc];
        
        [[datasetView valueForKey:[NSString stringWithFormat:@"%@s", pluginType]] addObject:anEntity];
        [[datasetView valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]] addObject:[anEntity valueForKey:[NSString stringWithFormat:@"%@ID", pluginType]]];
        
        if([anEntityDescription.name isEqual:[pluginDefaults objectAtIndex:[pluginTypes indexOfObject:pluginType]]]) {
          [datasetView setValue:anEntity 
                         forKey:[NSString stringWithFormat:@"selected%@%@", 
                                 [[pluginType substringToIndex:1] capitalizedString], 
                                 [pluginType substringFromIndex:1]]];
        }
      }

    NSMutableArray *pluginResults = [[NSMutableArray alloc] init];
    for(id aPlugin in [datasetView valueForKey:[NSString stringWithFormat:@"%@s", pluginType]])
      [pluginResults addObject:[NSNull null]];
    [datasetView setValue:pluginResults forKey:[NSString stringWithFormat:@"%@Results", pluginType]];
  }
  
  return datasetView;
}

- (void) reloadImage {
  self.renderedImage = nil;

  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];  
  [self.datasetVisualizerResults replaceObjectAtIndex:datasetVisualizerIndex withObject:[NSNull null]];  
  
  NSNumber *newVersion = [NSNumber numberWithInt:self.version.intValue + 1];
  self.version = nil;
  self.version = newVersion;
}

- (void) clustererChanged {
  int clustererIndex = [self.clusterers indexOfObject:self.selectedClusterer];  
  [self.clustererResults replaceObjectAtIndex:clustererIndex withObject:[NSNull null]];
  
  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];  
  [self.datasetVisualizerResults replaceObjectAtIndex:datasetVisualizerIndex withObject:[NSNull null]];  
}

- (void) datasetVisualizerChanged {
}

- (NSImage *) image {
  
  if ( self.renderedImage ) return self.renderedImage;
  
  NSSize imageSize = NSMakeSize(1024, 1024); // Size of output image
    
  int clustererIndex = [self.clusterers indexOfObject:self.selectedClusterer];
  NSData *assignment = [self.clustererResults objectAtIndex:clustererIndex];
  if(assignment == (NSData *)[NSNull null]) {
    int numBytes = [self.dataset.n intValue] * sizeof(int);
    int *newAssignment = malloc(numBytes);
    NSData *newData = [NSData dataWithBytesNoCopy:newAssignment length:numBytes freeWhenDone:YES];
    [self.clustererResults replaceObjectAtIndex:clustererIndex withObject:newData];
    
    [self.selectedClusterer clusterDataset:self.dataset
                                assignment:[self.clustererResults objectAtIndex:clustererIndex]];
  }
  
  int reducerIndex = [self.reducers indexOfObject:self.selectedReducer];
  NSData *reducedData = [self.reducerResults objectAtIndex:reducerIndex];
  if(reducedData == (NSData *)[NSNull null]) {
    int numBytes = [self.dataset.n intValue] * 2 * sizeof(int);
    int *newReducedData = malloc(numBytes);
    NSData *newData = [NSData dataWithBytesNoCopy:newReducedData length:numBytes freeWhenDone:YES];
    [self.reducerResults replaceObjectAtIndex:reducerIndex withObject:newData];
    
    [self.selectedReducer reduceDataset:self.dataset
                            reducedData:[self.reducerResults objectAtIndex:reducerIndex]];
  }
  
  int datasetVisualizerIndex = [self.datasetVisualizers indexOfObject:self.selectedDatasetVisualizer];
  NSImage *dataImage = [self.datasetVisualizerResults objectAtIndex:datasetVisualizerIndex];
  if(dataImage == (NSImage *)[NSNull null]) {
    NSImage *newImage = [[NSImage alloc] initWithSize:imageSize];

    [self.datasetVisualizerResults replaceObjectAtIndex:datasetVisualizerIndex withObject:newImage];
    
    [self.selectedDatasetVisualizer drawImage:[self.datasetVisualizerResults objectAtIndex:datasetVisualizerIndex]
                                  reducedData:[self.reducerResults objectAtIndex:reducerIndex]
                                      dataset:self.dataset
                                   assignment:[self.clustererResults objectAtIndex:clustererIndex]];
  }  

  int pointVisualizerIndex = [self.pointVisualizers indexOfObject:self.selectedPointVisualizer];
  NSImage *pointImage = [self.pointVisualizerResults objectAtIndex:pointVisualizerIndex];
  if(pointImage == (NSImage *)[NSNull null]) {
    NSImage *newImage = [[NSImage alloc] initWithSize:imageSize];
    
    [self.pointVisualizerResults replaceObjectAtIndex:pointVisualizerIndex withObject:newImage];
    
    [self.selectedPointVisualizer drawImage:[self.pointVisualizerResults objectAtIndex:pointVisualizerIndex]
                                reducedData:[self.reducerResults objectAtIndex:reducerIndex]
                                    dataset:self.dataset];
  }
  
  NSImage *image = [[NSImage alloc] initWithSize:imageSize];
  
  [image lockFocus];
  [[self.datasetVisualizerResults objectAtIndex:datasetVisualizerIndex] drawAtPoint:NSMakePoint(0.f, 0.f) 
                                                                           fromRect:NSZeroRect 
                                                                          operation:NSCompositeSourceOver 
                                                                           fraction:1.0];
  [[self.pointVisualizerResults objectAtIndex:pointVisualizerIndex] drawAtPoint:NSMakePoint(0.f, 0.f) 
                                                                       fromRect:NSZeroRect 
                                                                      operation:NSCompositeSourceOver 
                                                                       fraction:1.0];  
  [image unlockFocus];
  
  self.renderedImage = image;
  
  return self.renderedImage;
}

#pragma mark -
#pragma mark Core Data Methods

- (void) awakeFromInsert {
  [super awakeFromInsert];
  
  // called when the object is first created.
  [self generateUniqueID];
}

- (void) awakeFromFetch {
  [super awakeFromFetch];
  
  DivvyAppDelegate *delegate = [NSApp delegate];
  
  // Reconnect datasetView with its components.
  NSManagedObjectContext *moc = [delegate managedObjectContext];
  NSManagedObjectModel *mom = [delegate managedObjectModel];
  NSError *error = nil;
  
  NSArray *pluginTypes = [delegate pluginTypes];
  
  for(NSString *pluginType in pluginTypes) {
    [self setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@s", pluginType]];
    
    NSMutableArray *plugins = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
    
    NSArray *pluginIDs = [self valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
    
    NSString *pluginIDString = [NSString stringWithFormat:@"%@ID", pluginType];
    NSString *selectedPluginString = [NSString stringWithFormat:@"selected%@%@", 
                                      [[pluginType substringToIndex:1] capitalizedString], 
                                      [pluginType substringFromIndex:1]];
    
    NSString *selectedPluginIDString = [NSString stringWithFormat:@"selected%@%@ID", 
                                        [[pluginType substringToIndex:1] capitalizedString], 
                                        [pluginType substringFromIndex:1]];
    
    for(NSString *anID in pluginIDs)
      for(NSEntityDescription *anEntityDescription in mom.entities) {
        if([anEntityDescription.propertiesByName objectForKey:pluginIDString]) {
          NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
          NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"(%K LIKE %@)", pluginIDString, anID];
          
          [request setEntity:anEntityDescription];
          [request setPredicate:idPredicate];
          
          NSArray *pluginArray = [moc executeFetchRequest:request error:&error];
          
          for(id aPlugin in pluginArray) { // Should only be one
            [plugins addObject:aPlugin];
            if([[self valueForKey:selectedPluginIDString] isEqual:[aPlugin valueForKey:pluginIDString]])
              [self setValue:aPlugin forKey:selectedPluginString];
          }
        }
    }
  }
}

- (void) willSave { // Don't save all the images--it makes things slow and takes up a lot of disk
  for(NSImage *anImage in self.datasetVisualizerResults)
    if(anImage != (NSImage *)[NSNull null]) {
      [self.datasetVisualizerResults replaceObjectAtIndex:[self.datasetVisualizerResults indexOfObject:anImage] withObject:[NSNull null]];
      [anImage release];
    }
  for(NSImage *anImage in self.pointVisualizerResults)
    if(anImage != (NSImage *)[NSNull null]) {
      [self.pointVisualizerResults replaceObjectAtIndex:[self.pointVisualizerResults indexOfObject:anImage] withObject:[NSNull null]];
      [anImage release];
    }
}

- (void) setSelectedDatasetVisualizer:(id <DivvyDatasetVisualizer>)aDatasetVisualizer {
  self.selectedDatasetVisualizerID = aDatasetVisualizer.datasetVisualizerID;
  selectedDatasetVisualizer = aDatasetVisualizer;
}

- (void) setSelectedPointVisualizer:(id <DivvyPointVisualizer>)aPointVisualizer {
  self.selectedPointVisualizerID = aPointVisualizer.pointVisualizerID;
  selectedPointVisualizer = aPointVisualizer;
}

- (void) setSelectedClusterer:(id <DivvyClusterer>)aClusterer {
  self.selectedClustererID = aClusterer.clustererID;
  selectedClusterer = aClusterer;
}

- (void) setSelectedReducer:(id <DivvyReducer>)aReducer {
  self.selectedReducerID = aReducer.reducerID;
  selectedReducer = aReducer;
}

#pragma mark -
#pragma mark 'IKImageBrowserItem' Protocol Methods

-(NSString *) imageTitle {
  return @"Temp";
}

- (NSString*) imageUID {
  
  // return uniqueID if it exists.
  NSString* uniqueID = self.uniqueID;
  if ( uniqueID ) return uniqueID;
  [self generateUniqueID];
  return self.uniqueID;
}

- (NSString *) imageRepresentationType {
  return IKImageBrowserNSImageRepresentationType;
}

- (id) imageRepresentation {
  return self.image;
}

- (NSUInteger) imageVersion {
  return [[self version] unsignedIntValue];
}

#pragma mark -
#pragma mark Private

- (void) generateUniqueID {
  
  NSString* uniqueID = self.uniqueID;
  if ( uniqueID != nil ) return;
  self.uniqueID = [[NSProcessInfo processInfo] globallyUniqueString];
}

- (void) dealloc {
  
  // Core Data properties automatically managed.
  // Only release sythesized properties.
  [[self renderedImage] release];
  
  // Are the releases below needed? Warnings about release not being found in the protocol.
  //[[self datasetVisualizer] release];
  //[[self pointVisualizer] release];
  //[[self clusterer] release];
  [super dealloc];
}

@end