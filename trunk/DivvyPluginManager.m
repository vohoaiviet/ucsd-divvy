//
//  DivvyPluginManager.m
//  Divvy
//
//  Created by Joshua Lewis on 7/26/11.
//  Copyright 2011 UCSD. All rights reserved.
//
//  This class uses code based on the CDPlugin project on the Cocoa
//  is my girlfriend blog

#import "DivvyPluginManager.h"
#import "DivvyClusterer.h"
#import "DivvyReducer.h"
#import "DivvyDatasetVisualizer.h"
#import "DivvyPointVisualizer.h"

@implementation DivvyPluginManager

@synthesize pluginClasses;
@synthesize pluginModels;

+ (id)shared;
{
  static DivvyPluginManager *sharedInstance;
  if (!sharedInstance) {
    sharedInstance = [[DivvyPluginManager alloc] init];
  }
  return sharedInstance;
}

- (id)init
{
  if (!(self = [super init])) return nil;
  
  //Find the plugins
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *plugins = [fileManager contentsOfDirectoryAtPath:[self applicationSupportFolder] error:nil];
  
  //Load all of the plugins
  NSMutableArray *loadArray = [NSMutableArray array];
  for (NSString *pluginPath in plugins) {
    if (![pluginPath hasSuffix:@".plugin"]) continue;

    NSBundle *pluginBundle = [NSBundle bundleWithPath:pluginPath];
    Class principalClass = [pluginBundle principalClass];
    
    if (![principalClass conformsToProtocol:@protocol(DivvyClusterer)] &&
        ![principalClass conformsToProtocol:@protocol(DivvyReducer)] &&
        ![principalClass conformsToProtocol:@protocol(DivvyDatasetVisualizer)] &&
        ![principalClass conformsToProtocol:@protocol(DivvyPointVisualizer)]) continue;

    [loadArray addObject:principalClass];
  }
  
  self.pluginClasses = loadArray;
  
  return self;
}

- (NSArray*)pluginModels;
{
  if (pluginModels) return pluginModels;
  
  NSMutableArray *models = [NSMutableArray array];
  for (Class aClass in [self pluginClasses]) {
    NSBundle *myBundle = [NSBundle bundleForClass:aClass];
    NSArray *bundles = [NSArray arrayWithObject:myBundle];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:bundles] retain];
    
    [models addObject:managedObjectModel];
  }
  
  self.pluginModels = models;
  
  return self.pluginModels;
}

- (NSString*)applicationSupportFolder 
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] :NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:@"Divvy"];
}

@end
