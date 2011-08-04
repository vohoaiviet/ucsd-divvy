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

#import "DivvyClusterer.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"

@interface DivvyDatasetView ()
@property (retain) NSImage *renderedImage;
- (void) generateUniqueID;
@end

@implementation DivvyDatasetView

@dynamic uniqueID;
@dynamic version;

@dynamic dataset;

@dynamic datasetVisualizerID;
@dynamic pointVisualizerID;
@dynamic clustererIDs;
@dynamic reducerID;

@dynamic dateCreated;

@dynamic assignment;
@dynamic reducedData;
@dynamic exemplarList;

@synthesize datasetVisualizer;
@synthesize pointVisualizer;
@synthesize clusterers;

@dynamic selectedClustererID;

@synthesize selectedClusterer;

@synthesize renderedImage;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset {
  DivvyAppDelegate *delegate = [NSApp delegate];
  NSManagedObjectContext* moc = delegate.managedObjectContext;
  NSManagedObjectModel* mom = delegate.managedObjectModel;
  NSArray *pluginTypes = delegate.pluginTypes;
  
  DivvyDatasetView *datasetView;    
  datasetView = [NSEntityDescription insertNewObjectForEntityForName:@"DatasetView"
                                               inManagedObjectContext:moc];
  
  datasetView.dataset = dataset;
  
  
  for(NSString *pluginType in pluginTypes) {
    if(![pluginType isEqual:@"clusterer"]) continue;
    
    [datasetView setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@s", pluginType]];
    [datasetView setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
    
    for(NSEntityDescription *anEntityDescription in [mom entities])
      if([anEntityDescription.propertiesByName objectForKey:[NSString stringWithFormat:@"%@ID", pluginType]]) {
        
        id anEntity = [NSEntityDescription insertNewObjectForEntityForName:anEntityDescription.name inManagedObjectContext:moc];
        
        [[datasetView valueForKey:[NSString stringWithFormat:@"%@s", pluginType]] addObject:anEntity];
        [[datasetView valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]] addObject:[anEntity valueForKey:[NSString stringWithFormat:@"%@ID", pluginType]]];
        
        if([anEntityDescription.name isEqual:[delegate defaultClusterer]]) {
          [datasetView setValue:anEntity 
                         forKey:[NSString stringWithFormat:@"selected%@%@", 
                                 [[pluginType substringToIndex:0] capitalizedString], 
                                 [[pluginType substringFromIndex:0] capitalizedString]]];
          
          [datasetView setValue:[anEntity valueForKey:[NSString stringWithFormat:@"%@ID", pluginType]]
                         forKey:[NSString stringWithFormat:@"selected%@%@ID", 
                                 [[pluginType substringToIndex:0] capitalizedString], 
                                 [[pluginType substringFromIndex:0] capitalizedString]]];

        }
      }
  }
  
  datasetView.datasetVisualizer = [delegate defaultDatasetVisualizer];
  datasetView.datasetVisualizerID = datasetView.datasetVisualizer.datasetVisualizerID;
  
  datasetView.dateCreated = [NSDate date];
    
  unsigned int n = [[dataset n] unsignedIntValue];
  unsigned int d = [[dataset d] unsignedIntValue];
  float *data = [dataset floatData];
  
  // reducedData is by default the first two dimensions scaled to be between
  // 0 and 1
  float x, y, min, max;
  min = FLT_MAX;
  max = FLT_MIN;
  for(int i = 0; i < n; i++) {
    x = data[i * d];
    y = data[i * d + 1];
    
    if(x < min) min = x;
    if(x > max) max = x;
    if(y < min) min = y;
    if(y > max) max = y;
  }
  
  unsigned int numBytes = sizeof(float) * n * 2;
  float *newReducedData = malloc(numBytes);
  
  for(int i = 0; i < n; i++) {
    newReducedData[i * 2] = (data[i * d] - min) / (max - min);
    newReducedData[i * 2 + 1] = (data[i * d + 1] - min) / (max - min);
  }
  
  datasetView.reducedData = [NSData dataWithBytesNoCopy:newReducedData
                                             length:numBytes
                                       freeWhenDone:YES]; // Hands responsibility for freeing reduced to the NSData object
  datasetView.exemplarList = nil;
  
  numBytes = sizeof(int) * n;
  int *newAssignment = calloc(numBytes, sizeof(int));
  datasetView.assignment = [NSData dataWithBytesNoCopy:newAssignment
                                            length:numBytes
                                      freeWhenDone:YES];
  
  return datasetView;
}

- (void) clustererChanged {
  self.renderedImage = nil;
  NSNumber *newVersion = [NSNumber numberWithInt:self.version.intValue + 1];
  self.version = nil;
  self.version = newVersion;
}

- (void) datasetVisualizerChanged {
  [self clustererChanged];
}

- (NSImage *) image {
  
  if ( self.renderedImage ) return self.renderedImage;
  
  NSSize      size  = NSMakeSize( 1024, 1024 );
  NSImage*    image = [[NSImage alloc] initWithSize:size];
  
  if([self selectedClusterer] )
    [[self selectedClusterer] clusterDataset:[self dataset]
                          assignment:[self assignment]];
  
  [[self datasetVisualizer] drawImage:image
                          reducedData:[self reducedData]
                              dataset:[self dataset]
                           assignment:[self assignment]];
  
  if([self pointVisualizer])
    [[self pointVisualizer] drawImage:image
                          reducedData:[self reducedData]
                         exemplarList:[self exemplarList]
                              dataset:[self dataset]];
    
  
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
    if([pluginType isEqual:@"clusterer"]) {
      [self setValue:[[NSMutableArray alloc] init] forKey:[NSString stringWithFormat:@"%@s", pluginType]];
      
      NSMutableArray *plugins = [self valueForKey:[NSString stringWithFormat:@"%@s", pluginType]];
      
      NSArray *pluginIDs = [self valueForKey:[NSString stringWithFormat:@"%@IDs", pluginType]];
      
      NSString *pluginIDString = [NSString stringWithFormat:@"%@ID", pluginType];
      
      for(NSString *anID in pluginIDs)
        for(NSEntityDescription *anEntityDescription in mom.entities) {
          if([anEntityDescription.propertiesByName objectForKey:pluginIDString] && 
             ![anEntityDescription.name isEqualToString:@"DatasetView"]) {
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"(%K LIKE %@)", pluginIDString, anID];
            
            [request setEntity:anEntityDescription];
            [request setPredicate:idPredicate];
            
            NSArray *pluginArray = [moc executeFetchRequest:request error:&error];
            
            for(id aPlugin in pluginArray) { // Should only be one
              [plugins addObject:aPlugin];
              if([self.selectedClustererID isEqual:[aPlugin valueForKey:pluginIDString]])
                self.selectedClusterer = aPlugin;
            }
          }
        }
    }
    else {
      NSString *pluginID = [NSString stringWithFormat:@"%@ID", pluginType];
      
      for(NSEntityDescription *anEntityDescription in mom.entities) {
        if([anEntityDescription.propertiesByName objectForKey:pluginID] && 
           ![anEntityDescription.name isEqualToString:@"DatasetView"]) {
          NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
          NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"(%K LIKE %@)", pluginID, [self valueForKey:pluginID]];
          
          [request setEntity:anEntityDescription];
          [request setPredicate:idPredicate];
          
          NSArray *pluginArray = [moc executeFetchRequest:request error:&error];
          
          for(id aPlugin in pluginArray) // Should only be one
            [self setValue:aPlugin forKey:pluginType];
        }
      }
    }
  }
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