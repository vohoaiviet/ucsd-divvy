//
//  DivvyPluginManager.h
//  Divvy
//
//  Created by Joshua Lewis on 7/26/11.
//  Copyright 2011 UCSD. All rights reserved.
//
//  This class uses code based on the CDPlugin project on the Cocoa
//  is my girlfriend blog

#import <Cocoa/Cocoa.h>


@interface DivvyPluginManager : NSObject

@property (retain) NSArray *pluginClasses;
@property (retain) NSArray *pluginModels;

+ (id)shared;

- (NSString*)applicationSupportFolder;

@end
