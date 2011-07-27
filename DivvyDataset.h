//  Written by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award #0963071.
//  Licensed under the New BSD License.
//  
//  DivvyDataset manages the data and metadata associated with a single dataset.
//  It maintains a set of DivvyDatasetViews that represent alternative
//  visualizations, clusterings and embeddings of the dataset.


#import <CoreData/CoreData.h>


@interface DivvyDataset :  NSManagedObject  

@property (nonatomic, retain) NSNumber *d;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSNumber *n;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *zoomValue;

@property (nonatomic, retain) NSSet *datasetViews;

+ (id) datasetInDefaultContextWithFile:(NSString *)file;

- (float *) floatData;

@end