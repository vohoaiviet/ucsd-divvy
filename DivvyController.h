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


@interface DivvyController : NSObject {
    IBOutlet DivvyOpenGLView *glView;
	
	IBOutlet NSButton	*recomputeButton;
	
	IBOutlet NSSlider	*kSliderkMeans;
	IBOutlet NSSlider	*kSliderSpectral;
	IBOutlet NSSlider	*kSliderLinkage;
	IBOutlet NSSlider	*sigmaSlider;
  
  IBOutlet NSSlider *skewSliderkMeans;
  IBOutlet NSSlider *skewSliderLinkage;
	
	IBOutlet NSTabView	*methodTabView;
	
	unsigned int N;
	unsigned int k;
  
	float sigma;
  float skew;
  
	DivvyModel *model;
}

-(IBAction)recompute:(id)sender;

-(IBAction)changeK:(id)sender;
-(IBAction)changeSigma:(id)sender;
-(IBAction)changeSkew:(id)sender;

@end
