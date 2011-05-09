//
//  DivvyController.m
//  Divvy
//
//  Created by Joshua Lewis on 4/5/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import "DivvyController.h"


@implementation DivvyController

-(void)awakeFromNib {
	model = [[DivvyModel alloc] init];
  
  int tempOrder[] = {6, 3, 16, 11, 7, 17, 14, 8, 5, 19, 15, 1, 2, 4, 18, 13, 9, 20, 10, 12};
  //int tempOrder[] = {15, 1, 2, 4, 18, 13, 9, 20, 10, 12, 6, 3, 16, 11, 7, 17, 14, 8, 5, 19};

  trialOrder = (int *)malloc(20 * sizeof(int));
  
  for(int i = 0; i < 20; i++)
    trialOrder[i] = tempOrder[i];
  
  data = NULL;
  viewData = NULL;
  
  safe = FALSE;
    
  curTrial = 1;
  forceMethod = 1;
  startup = 1;	
  
	k = [kSliderkMeans intValue];
	sigma = [sigmaSlider floatValue];
  skew = [skewSliderkMeans floatValue];
	
	int *assignment = NULL;
	//int *knn = [model knn:k];
  
  [self nextTrial:nil];
  
	[glView setAssignment:assignment];
	//[glView setKNN:knn];
	[glView setData:viewData setN:N];
  
  startup = 0;
}

-(IBAction)recompute:(id)sender {
	int *assignment;
	//int *knn;
	printf("Clustering...\n");
	if([methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] == 0) {
		k = [kSliderkMeans intValue];
    skew = [skewSliderkMeans floatValue];
		assignment = [model kmeans:k eig:0 skew:skew];
		//knn = [model knn:k];
		//[glView setKNN:knn];
	}
	else if([methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] == 1) {
		assignment = NULL;
	}
	else {
		k = [kSliderLinkage intValue];
    skew = [skewSliderLinkage floatValue];
		assignment = [model linkage:k skew:skew];
	}
  detail = fopen("detail.txt", "a");
  fprintf(detail, "%d\t%d\t%d\t%f\n", trialOrder[curTrial - 2], (int)[methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]], k, skew);
  fclose(detail);
	[glView setAssignment:assignment];
	printf("Drawing...\n");
  
  if(startup == 0)
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

-(IBAction)nextTrial:(id)sender {
  if([satisfiedPopUpButton indexOfSelectedItem] == 0 && curTrial > 1)
  {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"You must indicate your satisfaction with the grouping."];
    //[alert setInformativeText:@"Deleted records cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[glView window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
    return;
  }
  
  if(curTrial == 11 && forceMethod == 1) {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"From here on out, after choosing A or B, you cannot change your choice until the next trial."];
    //[alert setInformativeText:@"Deleted records cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[glView window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
  }
  if(curTrial == 21) {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Experiment complete! Please notify the experimenter."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[glView window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
  }
  if(curTrial > 1 && curTrial < 22 && ([methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] != 1))
  {
    summary = fopen("summary.txt", "a");
    fprintf(summary, "%d\t%d\t%d\t%d\t%f\n", trialOrder[curTrial - 2], (int)[methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]], (int)[satisfiedPopUpButton indexOfSelectedItem], k, skew);
    fclose(summary);
  }    
  if(curTrial <= 20 && ([methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] != 1 || sender == nil)) {
    if(curTrial < 12 && forceMethod == 0) {
      safe = TRUE;
      [methodTabView selectTabViewItemAtIndex:2];
      safe = FALSE;
      forceMethod = 1;
    } else {
      forceMethod = 0;
      [self loadData:trialOrder[curTrial++ - 1]];
      [model setData:data setN:N setD:D];
      [glView setData:viewData setN:N];
      safe = TRUE;
      if(curTrial < 12)
        [methodTabView selectTabViewItemAtIndex:0]; // This calls recompute since you can't get in here unless it is != 1
      else
        [methodTabView selectTabViewItemAtIndex:1];
      safe = FALSE;
    }
  }
  
  [satisfiedPopUpButton selectItemAtIndex:0];
}

-(BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  if(!safe && [methodTabView indexOfTabViewItem:[methodTabView selectedTabViewItem]] != 1)
    return NO;
  else
    return YES;
}

-(void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  [self recompute:nil];
}
-(void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  return;
}

-(void)loadData:(int)trial {
  FILE *fr;
  char filename[80];
  sprintf(filename, "s%02d.bin", trial);
  
  if(data != NULL)
    free(data);
  if(viewData != NULL)
    free(viewData);    
	
	fr = fopen(filename, "rb");
	fread (&N, sizeof(int) , 1, fr);
	fread (&D, sizeof(int) , 1, fr);
	data = (float *)malloc(N * D * sizeof(float));	
	fread (data, sizeof(float), N * D, fr);
	fclose(fr);
  
  // Normalize for view to be between -1 and 1
	// Could do this with model data, but want to be flexible for higher D
	viewData = (float *)malloc(N * D * sizeof(float));
	float max = FLT_MIN;
	float min = FLT_MAX;
	for(int i = 0; i < N * D; i++) {
		if(data[i] > max)
			max = data[i];
		if(data[i] < min)
			min = data[i];
	}
  
  max *= 1.1f; min *= .9f; // Buffer space
  
	for(int i = 0; i < N * D; i++)
    if(i % D == 0)
      viewData[i] = (2 * (data[i] - min)) / (max - min) - 1;
    else
      viewData[i] = (2 * (data[i] - min)) / (max - min) -.75; // Aspect ratio issues

  return;
}

@end
