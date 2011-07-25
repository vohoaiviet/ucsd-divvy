//
//  DivvyDatasetVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DivvyDataset;

@protocol DivvyDatasetVisualizer

- (NSString *) datasetVisualizerID;

- (void) drawImage:(NSImage *) image
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset
           assignment:(NSData *)assignment;

@end
