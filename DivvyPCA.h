//
//  DivvyPCA.h
//  Divvy
//
//  Created by Joshua Lewis on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyReducer.h"


@interface DivvyPCA : NSManagedObject <DivvyReducer>

@property (nonatomic, retain) NSString *uniqueID;

@property (nonatomic, retain) NSNumber *firstAxis;
@property (nonatomic, retain) NSNumber *secondAxis;
@property (nonatomic, retain) NSData *rotatedData;

@end
