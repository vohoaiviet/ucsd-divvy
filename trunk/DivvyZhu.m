//
//  DivvyZhu.m
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyZhu.h"
#import "DivvyDataset.h"

@implementation DivvyZhu

+ (id) zhuInDefaultContext {
  
  NSManagedObjectContext* context = [[NSApp delegate] managedObjectContext];
  
  DivvyZhu *newItem;    
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Zhu"
                                          inManagedObjectContext:context];
  
  return newItem;
}

- (void) drawImage:(NSImage *) image 
       withDataset:(DivvyDataset *)dataset {
  
  float *data = [dataset floatData];
  unsigned int n = [[dataset n] unsignedIntValue];
  
  [image lockFocus];
  
  NSColor* black = [NSColor blackColor];
  NSColor* white = [NSColor whiteColor];
  
  NSRect bounds = image.alignmentRect;
  
  NSRect rect, zhuVertical, zhuHorizontal;
  //NSBezierPath *path = [NSBezierPath bezierPath];
  
  float x, y, rectSize, frameSize;
  rectSize = 50.0f;
  frameSize = 10.0f;
  
  // Some temp code to make sure things draw in bounds, in the future calculate
  // this just once
  float minX, minY, maxX, maxY;
  minX = minY = FLT_MAX;
  maxX = maxY = FLT_MIN;
  for(int i = 0; i < n; i++) {
    x = data[i * 2];
    y = data[i * 2 + 1];
    
    if(x < minX) minX = x;
    if(x > maxX) maxX = x;
    if(y < minY) minY = y;
    if(y > maxY) maxY = y;
  }
  
  [white set];
  rect.size.width = rectSize;
  rect.size.height = rectSize;
  
  zhuVertical.size.width = 4;
  zhuVertical.size.height = rectSize - frameSize;
  zhuHorizontal.size.width = rectSize - frameSize;
  zhuHorizontal.size.height = 4;
  
  int index;
  for(int i = 0; i < 30; i++) {
    index = rand() % n;
    
    x = (data[index * 2] - minX) / (maxX - minX);
    y = (data[index * 2 + 1] - minY) / (maxY - minY);
    
    rect.origin.x = bounds.size.width * x - rectSize / 2;
    rect.origin.y = bounds.size.height * y - rectSize / 2;
    
    [white set];
    NSRectFill(rect);
    [black set];
    NSFrameRect(rect);
    
    
    zhuVertical.origin.x = rect.origin.x + frameSize / 2 + x * (rectSize - frameSize);
    zhuVertical.origin.y = rect.origin.y + frameSize / 2;
    NSRectFill(zhuVertical);
    zhuHorizontal.origin.x = rect.origin.x + frameSize / 2;
    zhuHorizontal.origin.y = rect.origin.y + frameSize / 2 + y * (rectSize - frameSize);
    NSRectFill(zhuHorizontal);
  }
  
  [image unlockFocus];
}


@end
