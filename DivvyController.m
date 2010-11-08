//
//  DivvyController.m
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import "DivvyController.h"
#import <stdlib.h>


@implementation DivvyController

-(void)awakeFromNib {
	model = [[DivvyModel alloc] init];
	
	unsigned int D;
	FILE *fr;        
	const char * filename = "medium.bin";
	
	fr = fopen(filename, "rb");
	fread (&N, sizeof(int) , 1, fr);
	fread (&D, sizeof(int) , 1, fr);
	float *data = (float *)malloc(N * D * sizeof(float));	
	fread (data, sizeof(float), N*D, fr);
	fclose(fr);
	
	k = [kSliderkMeans intValue];
	sigma = [sigmaSlider floatValue];
  skew = [skewSliderkMeans floatValue];
	
	[model setData:data setN:N setD:D];
	
	// Normalize for view to be between -1 and 1
	// Could do this with model data, but want to be flexible for higher D
	float *viewData = (float *)malloc(N * D * sizeof(float));
	float max = FLT_MIN;
	float min = FLT_MAX;
	float curData;
	for(int i = 0; i < N * D; i++) {
		curData = data[i];
		if(data[i] > max)
			max = data[i];
		if(data[i] < min)
			min = data[i];
	}
	for(int i = 0; i < N * D; i++)
		viewData[i] = (2 * (data[i] - min)) / (max - min) - 1;

	int *assignment = [model kmeans:k eig:0 skew:skew];
	//int *knn = [model knn:k];

	[glView setAssignment:assignment];
	//[glView setKNN:knn];
	[glView setData:viewData setN:N];
}

-(IBAction)recompute:(id)sender {
	int *assignment;
	//int *knn;
	printf("Clustering...\n");
	if([methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] == 0) {
		k = [kSliderkMeans intValue];
		assignment = [model kmeans:k eig:0 skew:skew];
		//knn = [model knn:k];
		//[glView setKNN:knn];
	}
	else if([methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] == 1) {
		k = [kSliderSpectral intValue];
		assignment = [model spectral:k sigma:sigma];
	}
	else {
		k = [kSliderLinkage intValue];
		assignment = [model linkage:k skew:skew];
	}

	[glView setAssignment:assignment];
	printf("Drawing...\n");
	[glView drawRect:[glView bounds]];
}

-(IBAction)changeK:(id)sender {
	[self recompute:nil];
}

-(IBAction)changeSigma:(id)sender {
	sigma = [sender intValue];
	[self recompute:nil];
}

-(IBAction)changeSkew:(id)sender {
	skew = [sender floatValue];
	[self recompute:nil];
}


@end
