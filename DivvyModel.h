//
//  DivvyModel.h
//  Divvy
//
//  Created by Joshua Lewis on 4/12/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenCL/OpenCL.h>

#include <stdio.h>
#include <assert.h>
#include <sys/sysctl.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <mach/mach_time.h>
#include <math.h>
#include <float.h>
#include <vecLib/cblas.h>
#include <vecLib/clapack.h>
#include <omp.h>

#include "distance.h"
#include "linkage.h"


@interface DivvyModel : NSObject {
  int N;
  int D;
  int local_size;
  float curSigma;
  
  float *data;
  float *eigendata;
  int *min_index;	
}

cl_program program[2];
cl_kernel kernel[2];

cl_command_queue cmd_queue;
cl_context   context;

cl_device_id cpu, device;

cl_int err;
size_t returned_size;
size_t data_size;
size_t centroids_size;
size_t min_index_size;

cl_mem data_mem, centroids_mem, min_index_mem;

double machcore(uint64_t endTime, uint64_t startTime);
char * load_program_source(const char *filename);
int setupCL(float *data, int N, int D);
int executeCL(void *return_value, int global_size, int local_size, int kern, int k, int N, int D);
int teardownCL();

void assignLaunch(int *dendrite, int k, int N, int *assignment);
void assign(int *dendrite, int line, int k, int N, int *assignment);

-(int *)kmeans:(int)k eig:(int)eig skew:(float)skew;
-(int *)linkage:(int)k skew:(float)skew;
-(int *)spectral:(int)k sigma:(float)sigma;
-(int *)knn:(int)kappa;

-(void)setData:(float *)newData setN:(int)newN setD:(int)newD;

@end