//
//  Dataset.h
//  Divvy
//
//  Created by Joshua Lewis on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface DivvyDataset :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * d;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * n;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSSet * pointVisualizer;

@end


@interface DivvyDataset (CoreDataGeneratedAccessors)
- (void)addPointVisualizerObject:(NSManagedObject *)value;
- (void)removePointVisualizerObject:(NSManagedObject *)value;
- (void)addPointVisualizer:(NSSet *)value;
- (void)removePointVisualizer:(NSSet *)value;

@end

