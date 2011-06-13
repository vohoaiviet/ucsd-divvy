//
//  DivvyClusterer.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DivvyDataset;

@interface DivvyClusterer : NSManagedObject

- (void) clusterDataset:(DivvyDataset *)dataset
             parameters:(NSArray *)parameters
             assignment:(NSData *)assignment;

@end
