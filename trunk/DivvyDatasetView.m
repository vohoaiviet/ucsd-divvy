//
//  DivvyDatasetView.m
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyDatasetView.h"
#import "DivvyDataset.h"
#import <Quartz/Quartz.h>

#include "stdlib.h"

@interface DivvyDatasetView ()
@property (retain) NSImage *renderedImage;
- (void) generateUniqueID;
@end

@implementation DivvyDatasetView

@dynamic uniqueID;

@dynamic dataset;

@synthesize renderedImage;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyDatasetView *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"DatasetView"
                                          inManagedObjectContext:context];
  
  newItem.dataset = dataset;
  
  return newItem;
}

- (NSImage*) image {
  
  if ( self.renderedImage ) return self.renderedImage;
  
  NSSize      size  = NSMakeSize( 1024, 1024 );
  NSImage*    image = [[NSImage alloc] initWithSize:size];
  
  [image lockFocus];
  
  NSColor* black = [NSColor blackColor];
  NSColor* white = [NSColor whiteColor];
  
  NSRect oval;
  NSBezierPath *ovalPath;
  float x, y, ovalSize;
  ovalSize = 20.0f;
  
  // get the view geometry and fill the background.
  
  NSRect bounds = image.alignmentRect;    
  [black set];
  NSRectFill ( bounds );
  
  bounds = NSInsetRect(bounds, ovalSize, ovalSize);
  
  for(int i = 0; i < 200; i++) {
    x = (float)rand() / RAND_MAX;
    y = (float)rand() / RAND_MAX;
    
    x = bounds.size.width * x;
    y = bounds.size.height * y;
    
    oval.origin.x = x;
    oval.origin.y = y;
    oval.size.width = ovalSize;
    oval.size.height = ovalSize;
    
    ovalPath = [NSBezierPath bezierPathWithOvalInRect:oval];
    
    [white set];
    [ovalPath fill];
  }
  
  [image unlockFocus];
  
  self.renderedImage = image;
  
  [image release];
  
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