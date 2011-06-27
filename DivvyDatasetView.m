//
//  DivvyDatasetView.m
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetView.h"
#import "DivvyDataset.h"

#import "DivvyClusterer.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"

#import <Quartz/Quartz.h>

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
@dynamic clustererID;
@dynamic reducerID;

@dynamic assignment;
@dynamic reducedData;
@dynamic exemplarList;

@synthesize datasetVisualizer;
@synthesize pointVisualizer;
@synthesize clusterer;

@synthesize renderedImage;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset 
                            datasetVisualizer:(id <DivvyDatasetVisualizer>)datasetVisualizer {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyDatasetView *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"DatasetView"
                                          inManagedObjectContext:context];
  
  newItem.dataset = dataset;
  
  newItem.datasetVisualizer = datasetVisualizer;
  newItem.datasetVisualizerID = [datasetVisualizer uniqueID];
  
  newItem.pointVisualizer = nil;
  newItem.pointVisualizerID = nil;
  
  newItem.clusterer = nil;
  newItem.clustererID = nil;
  
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
  
  newItem.reducedData = [NSData dataWithBytesNoCopy:newReducedData
                                             length:numBytes
                                       freeWhenDone:YES]; // Hands responsibility for freeing reduced to the NSData object
  newItem.exemplarList = nil;
  
  numBytes = sizeof(int) * n;
  int *newAssignment = calloc(numBytes, sizeof(int));
  newItem.assignment = [NSData dataWithBytesNoCopy:newAssignment
                                            length:numBytes
                                      freeWhenDone:YES];
  
  return newItem;
}

- (void) clustererChanged {
  self.renderedImage = nil;
  NSNumber *newVersion = [NSNumber numberWithInt:[[self version] intValue] + 1];
  self.version = nil;
  self.version = newVersion;
}

- (NSImage *) image {
  
  if ( self.renderedImage ) return self.renderedImage;
  
  NSSize      size  = NSMakeSize( 1024, 1024 );
  NSImage*    image = [[NSImage alloc] initWithSize:size];
  
  if([self clusterer])
    [[self clusterer] clusterDataset:[self dataset]
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
  
  // called when the object is first created.
  [self generateUniqueID];
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
  [super dealloc];
}

@end