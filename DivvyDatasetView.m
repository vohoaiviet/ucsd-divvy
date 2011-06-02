//
//  DivvyDatasetView.m
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetView.h"
#import "DivvyDataset.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"
#import <Quartz/Quartz.h>

@interface DivvyDatasetView ()
@property (retain) NSImage *renderedImage;
- (void) generateUniqueID;
@end

@implementation DivvyDatasetView

@dynamic uniqueID;

@dynamic dataset;
@dynamic datasetVisualizer;
@dynamic pointVisualizer;

@synthesize renderedImage;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset 
                        withDatasetVisualizer:(DivvyDatasetVisualizer *)datasetVisualizer {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyDatasetView *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"DatasetView"
                                          inManagedObjectContext:context];
  
  newItem.dataset = dataset;
  newItem.datasetVisualizer = datasetVisualizer;
  newItem.pointVisualizer = nil;
  
  return newItem;
}

- (NSImage *) image {
  
  if ( self.renderedImage ) return self.renderedImage;
  
  NSSize      size  = NSMakeSize( 1024, 1024 );
  NSImage*    image = [[NSImage alloc] initWithSize:size];
  
  [[self datasetVisualizer] drawImage: image
                          withDataset:[self dataset]];
  
  if([self pointVisualizer])
    [[self pointVisualizer] drawImage: image
                          withDataset:[self dataset]];
    
  
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