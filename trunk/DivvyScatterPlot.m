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

+ (id) scatterPlotInDefaultContext {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyScatterPlot *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ScatterPlot"
                                          inManagedObjectContext:context];
  
  return newItem;
}

- (void) drawImage:(NSImage *) image 
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset {
  
  float *data = (float *)[reducedData bytes];
  unsigned int n = [[dataset n] unsignedIntValue];

  [image lockFocus];
   
  NSColor* black = [NSColor blackColor];
  NSColor* white = [NSColor whiteColor];

  NSRect rect;

  float x, y, rectSize;
  rectSize = 5.0f;

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

    NSRectFill(rect); // Make this a NSRectFillListWithColors in the future
  }

  [image unlockFocus];
}


@end
