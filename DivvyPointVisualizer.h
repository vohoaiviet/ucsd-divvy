//
//  DivvyPointVisualizer.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class DivvyDataset;

#import <Cocoa/Cocoa.h>


@interface DivvyPointVisualizer : NSManagedObject

- (void) drawImage:(NSImage *) image
       withDataset:(DivvyDataset *)dataset;

@end
