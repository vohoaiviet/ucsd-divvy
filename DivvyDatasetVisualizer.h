//
//  DivvyDatasetVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class DivvyDataset;

#import <Cocoa/Cocoa.h>

@interface DivvyDatasetVisualizer : NSManagedObject

- (void) drawImage:(NSImage *) image
       reducedData:(NSData *)reducedData
           dataset:(DivvyDataset *)dataset;

@end
