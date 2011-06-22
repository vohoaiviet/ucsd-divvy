//
//  DivvyPointVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DivvyDataset;

@protocol DivvyPointVisualizer

- (void) drawImage:(NSImage *) image
       reducedData:(NSData *)reducedData
      exemplarList:(NSData *)exemplarList
           dataset:(DivvyDataset *)dataset;

@end
