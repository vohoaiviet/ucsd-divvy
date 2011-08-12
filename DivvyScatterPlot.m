//
//  DivvyScatterPlot.m
//  Divvy
//
//  Created by Joshua Lewis on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyScatterPlot.h"
#import "DivvyDataset.h"

@implementation DivvyScatterPlot

@dynamic datasetVisualizerID;
@dynamic name;

@dynamic pointSize;

+ (id <DivvyDatasetVisualizer>) scatterPlotInDefaultContext {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyScatterPlot *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ScatterPlot"
                                          inManagedObjectContext:context];
  
  return newItem;
}

- (void) awakeFromInsert {
  [super awakeFromInsert];

  self.datasetVisualizerID = [[NSProcessInfo processInfo] globallyUniqueString];
  
  self.pointSize = [NSNumber numberWithInt:5];
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset
        assignment:(NSData *)assignment {
  
  float *data = (float *)[reducedData bytes];
  int *cluster_assignment = (int *)[assignment bytes];
  unsigned int n = [[dataset n] unsignedIntValue];

  [image lockFocus];
   
  NSColor* black = [NSColor blackColor];
  NSColor* white = [NSColor whiteColor];
  
  NSArray* clusterColors = [[NSArray alloc] initWithObjects:
                            [NSColor whiteColor], [NSColor blueColor], 
                            [NSColor redColor], [NSColor greenColor], 
                            [NSColor yellowColor], [NSColor magentaColor],
                            [NSColor brownColor], [NSColor grayColor],
                            [NSColor orangeColor], [NSColor cyanColor],
                            [NSColor purpleColor], nil];

  NSRect rect;

  float x, y, rectSize;
  rectSize = [self.pointSize floatValue];

  // get the view geometry and fill the background.

  NSRect bounds = image.alignmentRect;    
  [black set];
  NSRectFill ( bounds );

  bounds = NSInsetRect(bounds, rectSize, rectSize);

  [white set];
  rect.size.width = rectSize;
  rect.size.height = rectSize;

  for(int i = 0; i < n; i++) {
    x = data[i * 2];
    y = data[i * 2 + 1];

    // x and y are guaranteed to be between 0 and 1
    x = bounds.size.width * x;
    y = bounds.size.height * y;

    rect.origin.x = x;
    rect.origin.y = y;

    [(NSColor *)[clusterColors objectAtIndex:cluster_assignment[i]] set];
    NSRectFill(rect); // Make this a NSRectFillListWithColors in the future
  }

  [image unlockFocus];
  
  [clusterColors release];
}

@end
