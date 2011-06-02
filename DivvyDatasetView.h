//
//  DivvyDatasetView.h
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class DivvyDataset;
@class DivvyDatasetVisualizer;
@class DivvyPointVisualizer;

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@interface DivvyDatasetView : NSManagedObject

@property (retain) NSString *uniqueID;

@property (retain) DivvyDataset *dataset;
@property (retain) DivvyDatasetVisualizer *datasetVisualizer;
@property (retain) DivvyPointVisualizer *pointVisualizer;

@property (readonly) NSImage *image;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset 
                               withDatasetVisualizer:(DivvyDatasetVisualizer *)datasetVisualizer;

@end