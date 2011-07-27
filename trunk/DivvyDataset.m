//  Written by Joshua Lewis at the UC San Diego Natural Computation Lab,
//  PI Virginia de Sa, supported by NSF Award #0963071.
//  Licensed under the New BSD License.
//  

#import "DivvyDataset.h"

@implementation DivvyDataset 

@dynamic d;
@dynamic data;
@dynamic n;
@dynamic title;
@dynamic zoomValue;

@dynamic datasetViews;

+ (id) datasetInDefaultContextWithFile:(NSString *)path {
  NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
  
  DivvyDataset *newItem;
  newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Dataset"
                                          inManagedObjectContext:context];
  
  newItem.title = [[path lastPathComponent] stringByDeletingPathExtension];
  
  newItem.data = [NSData dataWithContentsOfFile:path];
  
  unsigned int n;
  unsigned int d;
  
  [newItem.data getBytes:&n range:NSMakeRange(0, 4)];
  [newItem.data getBytes:&d range:NSMakeRange(4, 4)];
  
  newItem.n = [NSNumber numberWithUnsignedInt:n];
  newItem.d = [NSNumber numberWithUnsignedInt:d];

  return newItem;
}

- (float *) floatData {
  return (float *)(self.data.bytes + 8); // Offset by 8 bytes to avoid header info
}

- (void) dealloc {
  [super dealloc];
}

@end
