//
//  DivvyClustererPanel.m
//  Divvy
//
//  Created by Joshua Lewis on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DivvyClustererPanel.h"
#import "DivvyAppDelegate.h"

@implementation DivvyClustererPanel

-(IBAction) changeK:(id)sender {
  [(DivvyAppDelegate *)[NSApp delegate] clustererChanged];
}

@end
