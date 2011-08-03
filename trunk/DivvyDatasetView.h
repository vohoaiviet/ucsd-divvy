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

@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) NSNumber *version;

@property (nonatomic, retain) DivvyDataset *dataset;

@property (nonatomic, retain) NSString *datasetVisualizerID;
@property (nonatomic, retain) NSString *pointVisualizerID;
@property (nonatomic, retain) NSString *clustererID;
@property (nonatomic, retain) NSString *reducerID;

@property (nonatomic, retain) NSDate *dateCreated;

@property (nonatomic, retain) NSData *assignment;
@property (nonatomic, retain) NSData *reducedData;
@property (nonatomic, retain) NSData *exemplarList;

@property (nonatomic, retain) id <DivvyDatasetVisualizer> datasetVisualizer;
@property (nonatomic, retain) id <DivvyPointVisualizer> pointVisualizer;
@property (nonatomic, retain) id <DivvyClusterer> clusterer;

@property (readonly) NSImage *image;

+ (id) datasetViewInDefaultContextWithDataset:(DivvyDataset *)dataset 
                            datasetVisualizer:(id <DivvyDatasetVisualizer>)datasetVisualizer;

- (void) clustererChanged;
- (void) datasetVisualizerChanged;

@end