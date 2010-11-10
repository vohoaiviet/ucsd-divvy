//
//  DivvyController.h
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DivvyOpenGLView.h"
#import "DivvyModel.h"

#include <stdlib.h>
#include <string.h>


@interface DivvyController : NSObject {
  IBOutlet DivvyOpenGLView *glView;
	
	IBOutlet NSButton	*recomputeButton;
  IBOutlet NSButton	*nextTrialButton;
	
	IBOutlet NSSlider	*kSliderkMeans;
	IBOutlet NSSlider	*kSliderSpectral;
	IBOutlet NSSlider	*kSliderLinkage;
	IBOutlet NSSlider	*sigmaSlider;
	
	IBOutlet NSSlider *skewSliderkMeans;
	IBOutlet NSSlider *skewSliderLinkage;
	
	IBOutlet NSTabView	*methodTabView;
	
	unsigned int N;
  unsigned int D;
	unsigned int k;
  
  unsigned int curTrial;
	
	float sigma;
	float skew;
  
  float *data;
  float *viewData;
  
  int *trialOrder;
  
  FILE *detail;
  FILE *summary;
  
  BOOL safe;
	
	DivvyModel *model;
}

-(IBAction)recompute:(id)sender;
-(IBAction)nextTrial:(id)sender;

-(IBAction)changeK:(id)sender;
-(IBAction)changeSigma:(id)sender;
-(IBAction)changeSkew:(id)sender;

-(BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;
-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;

-(void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

-(void)loadData:(int)trial;

@end
