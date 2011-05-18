//
//  DivvyDatasetView.h
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class DivvyDataset;

#import <Cocoa/Cocoa.h>


@interface DivvyDatasetView : NSManagedObject

@property (retain) NSString *uniqueID;

@property (retain) DivvyDataset *dataset;

@property (readonly) NSImage *image;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset;

@end