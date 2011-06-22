//
//  DivvyDatasetView.h
//  Divvy
//
//  Created by Joshua Lewis on 5/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class DivvyDataset;

@protocol DivvyClusterer;
@protocol DivvyDatasetVisualizer;
@protocol DivvyPointVisualizer;

@interface DivvyDatasetView : NSManagedObject

@property (retain) NSString *uniqueID;
@property (retain) NSNumber *version;

@property (retain) DivvyDataset *dataset;

@property (retain) id <DivvyDatasetVisualizer> datasetVisualizer;
@property (retain) id <DivvyPointVisualizer> pointVisualizer;
@property (retain) id <DivvyClusterer> clusterer;

@property (retain) NSData *assignment;
@property (retain) NSData *reducedData;
@property (retain) NSData *exemplarList;

@property (readonly) NSImage *image;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset 
                            datasetVisualizer:(id <DivvyDatasetVisualizer>)datasetVisualizer;

- (void) clustererChanged;

@end