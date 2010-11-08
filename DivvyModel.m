//
//  DivvyModel.m
//  Divvy
//
//  Created by Joshua Lewis on 4/12/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import "DivvyModel.h"


@implementation DivvyModel
-(id)init {
	if (self = [super init]) {
		cpu = NULL;
		device = NULL;
		
		err = 0;
		
		curSigma = -1.0;
		
		srand(10); //seed by time
	}
	return self;
}

-(void)dealloc{
	teardownCL();
	free(min_index);
	free(data);
	free(eigendata);
	
	[super dealloc];

}

-(void)setData:(float *)newData setN:(int)newN setD:(int)newD {
	if(data != NULL)
		free(data);
	data = newData;
	N = newN;
	D = newD;
	
	local_size = 8;
	
	if(min_index != NULL)
		free(min_index);
	min_index = (int *)malloc(N * sizeof(int));	
	
	if(data_mem != NULL)
		teardownCL();
	setupCL();
}

-(int *)knn:(int)kappa {
    int i, j, h;
	
    float *distance = (float *)malloc(sizeof(float) * N * (N - 1) / 2);
	float *index = (float *)malloc(sizeof(float) * N * (N - 1));
	int *nearest = (int *)malloc(sizeof(int) * N * (N - 1) / 2);
	
    float *copy = (float *)malloc(sizeof(float) * D);
	float norm, min;
	float holddist = -1;
	int holdi, ihIndex;

	// initialize nearest vector
	for (i = 0; i < N * (N - 1) / 2; i++)
		nearest[i] = 0;	
	
    // Compute pairwise distance
    for(i = 0; i < N - 1; i++)
		for(j = i + 1; j < N; j++)
		{
			cblas_scopy(D, &data[j * D], 1, copy, 1);				
			cblas_saxpy(D, -1, &data[i * D], 1, copy, 1);
			norm = cblas_snrm2(D, copy, 1);
			distance[j * (j - 1) / 2 + i] = norm;
			index[j * (j - 1) + 2 * i] = i;
			index[j * (j - 1) + 2 * i + 1] = j;
		}
	
	for (h = 0; h < N; h++)
		for(j = 0; j < kappa ; j++) {
			min = FLT_MAX;
			if (j != 0) // subsequent runs
				holddist = distance[holdi];
			else
				holddist = -1;
			
			for(i = 0; i < N; i++) { 	// find next min dist
				if (h != i) {
					if (h < i)
						ihIndex = i*(i-1)/2 + h;
					else
						ihIndex = h*(h-1)/2 + i;
					if (distance[ihIndex] < min && distance[ihIndex] > holddist) {
						holdi = ihIndex;
						min = distance[holdi];
					}
				}
			}
			
			nearest[holdi] = 1;
		}

    free(copy);
    free(distance);
    free(index);
    return nearest;
}

void assignLaunch(int *dendrite, int k, int N, int *assignment) {
	int curK = 0;
	int index = 0;
	for(int i = 0; i < k - 1; i++)
		for(int j = 0; j < 2; j++) {
			index = 2 * (N - i - 2) + j;
			if(dendrite[index] < N)
				assignment[dendrite[index]] = curK++;
			else if(dendrite[index] <= 2 * (N - 1) - (k - 1))
				assign(dendrite, dendrite[index] - N, curK++, N, assignment);
		}
}

void assign(int *dendrite, int line, int k, int N, int *assignment) {
	for(int i = 0; i < 2; i++) {
		if(dendrite[2 * line + i] < N)
			assignment[dendrite[2 * line + i]] = k;
		else
			assign(dendrite, dendrite[2 * line + i] - N, k, N, assignment);
	}
}

-(int *)linkage:(int)k skew:(float)skew {
    int i, j, l, m, o;
	
	int *tracker = (int *)malloc(sizeof(int) * N);
    float *distance = (float *)calloc(N * (N - 1) / 2, sizeof(float));
	float *index = (float *)malloc(sizeof(float) * N * (N - 1));
	int *dendrite = (int *)malloc(sizeof(int) * 2 * (N - 1));
	
	int blockSize;
	
	float norm;
	float min;
	int hold;
	int a, b, akIndex, bkIndex;
	
	for(i = 0; i < N; i++)
		tracker[i] = i;
	
    // Compute pairwise distance
	uint64_t mbeg, mend;/*
	mbeg = mach_absolute_time();
	//if(FALSE) {
		float *copy = (float *)malloc(sizeof(float) * D);
		for(i = 0; i < N - 1; i++)
			for(j = i + 1; j < N; j++)
			{
				cblas_scopy(D, &data[j * D], 1, copy, 1);				
				cblas_saxpy(D, -1, &data[i * D], 1, copy, 1);
				norm = cblas_snrm2(D, copy, 1);
				distance[j * (j - 1) / 2 + i] = norm;
				index[j * (j - 1) + 2 * i] = i;
				index[j * (j - 1) + 2 * i + 1] = j;
			}
		free(copy);
		mend = mach_absolute_time();
		printf("Pairwise Calc Time (Naive):\t%1.3g\n", machcore(mend, mbeg));
		printf("%1.3g\t%1.3g\t%1.3g\t%1.3g\n", distance[0], distance[20], distance[100], distance[500]);	
*/
	//}
	//else {
		mbeg = mach_absolute_time();
		if(D > N) {
			blockSize = 1;
			float sum;
			#pragma omp parallel private(i, j, l, sum)
			{
				float *copy = (float *)malloc(sizeof(float) * blockSize);
				#pragma omp for nowait
				for(m = 0; m < D / blockSize; m++)
				{
					for(i = 0; i < N - 1; i++)
						for(j = i + 1; j < N; j++)
						{
							cblas_scopy(blockSize, &data[(j * D) + (m * blockSize)], 1, copy, 1);				
							cblas_saxpy(blockSize, -1, &data[(i * D) + (m * blockSize)], 1, copy, 1);
							sum = 0.0f;
							for(l = 0; l < blockSize; l++)
								sum += copy[l] * copy[l];
							distance[j * (j - 1) / 2 + i] += sum;
							if(omp_get_thread_num() == 0) {
								index[j * (j - 1) + 2 * i] = i;
								index[j * (j - 1) + 2 * i + 1] = j;
							}
						}
				}
				free(copy);
			}
		}
		else {
			blockSize = 10;
			#pragma omp parallel private(i, j, l, o, norm)
			{
				float *copy = (float *)malloc(sizeof(float) * D);
				#pragma omp for nowait
				for(m = 0; m < N / blockSize; m++)
					for(o = m; o < N / blockSize; o++)
						for(i = m * blockSize; i < (m + 1) * blockSize - (m == o ? 1 : 0); i++)
							for(j = (m == o ? i + 1 : o * blockSize); j < (o + 1) * blockSize; j++)
							{
								//cblas_scopy(D, &data[j * D], 1, copy, 1);				
								//cblas_saxpy(D, -1, &data[i * D], 1, copy, 1);
								//norm = cblas_snrm2(D, copy, 1);
								//distance[j * (j - 1) / 2 + i] = norm;
                for(int z = 0; z < D; z++)
                  if(z == 0)
                    distance[j * (j - 1) / 2 + i] += skew * (data[j * D + z] - data[i * D + z]) * (data[j * D + z] - data[i * D + z]);
                  else
                    distance[j * (j - 1) / 2 + i] += (1.f - skew) * (data[j * D + z] - data[i * D + z]) * (data[j * D + z] - data[i * D + z]);
								index[j * (j - 1) + 2 * i] = i;
								index[j * (j - 1) + 2 * i + 1] = j;
							}
				free(copy);
			}
		}
	
		mend = mach_absolute_time();
		printf("Pairwise Calc Time (Parallel):\t%1.3g\n", machcore(mend, mbeg));
		printf("%1.3g\t%1.3g\t%1.3g\t%1.3g\n", distance[0], distance[20], distance[100], distance[500]);
	
	//}
	
	for(j = 0; j < N - 1; j++) {
		min = FLT_MAX;
		for(i = 0; i < N * (N - 1) / 2; i++) { // Find minimum distance
			if (distance[i] < min) {
				min = distance[i];
				hold = i;
			}
		}
		
		a = index[2 * hold];
		b = index[2 * hold + 1];
		
		dendrite[2 * j] = tracker[a];
		dendrite[2 * j + 1] = tracker[b];
		//dendrite[3 * j + 2] = min;
		distance[hold] = FLT_MAX;
		
		for (i = 0; i < N; i++) { // Update distance matrix
			
			if (a > i)
				akIndex = a * (a - 1) / 2 + i;
			else
				akIndex = i * (i - 1) / 2 + a;
			
			if (b > i)
				bkIndex = b * (b - 1) / 2 + i;
			else
				bkIndex = i * (i - 1) / 2 + b;
			
			
			if (i == a)
				tracker[i] = N + j;
			else if (i == b)
				tracker[i] = -1;
			else if ((tracker[i] != -1) && (i != a) && (i != b)) {
				distance[akIndex] = fmax(distance[akIndex], distance[bkIndex]);
				distance[bkIndex] = FLT_MAX;
			}
		}
	}

	assignLaunch(dendrite, k, N, min_index);
	
  free(tracker);
  free(distance);
  free(index);
	free(dendrite);
	
  return min_index;	
}

-(int *)spectral:(int)k sigma:(float)sigma {
	int i, j;
	int info = 0;
	int eigenD = 50; // Fix this -- bad if number of data points is less than 50
	float norm;
	
	if(eigendata == NULL)
		eigendata = (float *)malloc(sizeof(float) * N * eigenD);

	if(curSigma != sigma)
	{
		float *affinity = (float *)malloc(sizeof(float) * N * (N + 1) / 2);
		float *affsum = (float *)malloc(sizeof(float) * N);
		float *copy = (float *)malloc(sizeof(float) * D);
		
		float *eigenvalues = (float *)malloc(sizeof(float) * N);
		float *eigenvectors = (float *)malloc(sizeof(float) * N * N);
		float *work = (float *)malloc(sizeof(float) * N * 3);

		curSigma = sigma;
		
		// Compute pairwise affinity
		for(i = 0; i < N; i++)
			for(j = i; j < N; j++)
				if (j == i)
					affinity[j * (j + 1) / 2 + i] = 0;
				else
				{
					cblas_scopy(D, &data[j * D], 1, copy, 1);				
					cblas_saxpy(D, -1, &data[i * D], 1, copy, 1);
					norm = cblas_snrm2(D, copy, 1);
					affinity[j * (j + 1) / 2 + i] = exp(-norm * norm / (2 * sigma * sigma));
				}

		for(i = 0; i < N; i++)
		{
			affsum[i] = 0.0f;
			for(j = 0; j < N; j++)
				if(j <= i)
					affsum[i] += affinity[i * (i + 1) / 2 + j];
				else
					affsum[i] += affinity[j * (j + 1) / 2 + i];
			affsum[i] = 1.0f / sqrt(affsum[i]);
		}

		for(i = 0; i < N; i++)
			for(j = i; j < N; j++)
				affinity[j * (j + 1) / 2 + i] *= affsum[i] * affsum[j];
				
		sspev_("V", "U", &N, affinity, eigenvalues, eigenvectors, &N, work, &info);

		for(i = 0; i < N; i++)
			for(j = 0; j < k; j++)
				eigendata[i * D + j] = eigenvectors[(N - j - 1) * N + i];

		free(copy);
		free(eigenvalues);
		free(eigenvectors);
		free(work);
		free(affinity);
		free(affsum);
	}
		
	return [self kmeans:k eig:1 skew:.5f];
}

-(int *)kmeans:(int)k eig:(int)eig skew:(float)skew {
	
	const int MAX_ITERATIONS = 50;
	const int ACHUNK_SIZE = (int)(N / 2);
	const int MCHUNK_SIZE = (int)(k / 2);
	int i, j, l, m;	
	int count;
	float min_distance, diff, sum;
	
	float *curData;
	
	if(eig == 1)
		curData = eigendata;
	else
		curData = data;
		
	uint64_t mbegA, mendA, mbegM, mendM;
	double sumA = 0.0;
	double sumM = 0.0;
	
	float *centroids = (float *)malloc(k * D * sizeof(float));
	for(i = 0; i < k; i++)
		for(j = 0; j < D; j++)
			centroids[i * D + j] = curData[(rand() % N) * D + j]; // Could double sample, but we check for orphan centroids in move.cl
	
	centroids_size = k * D * sizeof(float);
	centroids_mem = clCreateBuffer(context, CL_MEM_READ_WRITE, centroids_size, NULL, NULL);
	err = clEnqueueWriteBuffer(cmd_queue, centroids_mem, CL_TRUE, 0, centroids_size,
							   (void*)centroids, 0, NULL, NULL);
	assert(err == CL_SUCCESS);
	clFinish(cmd_queue);
	
	i = 0;
	while(i < MAX_ITERATIONS)
	{
		if(TRUE)
		{
			mbegA = mach_absolute_time();
			#pragma omp parallel private(l, m, sum, diff, min_distance)
			{
				#pragma omp for schedule(dynamic, ACHUNK_SIZE) nowait
				for(j = 0; j < N; j++)
				{
					min_distance = 0xFFFFFFFF;
					for(l = 0; l < k; l++)
					{
						sum = 0.f;
						
						for(m = 0; m < D; m++)
						{
							diff = curData[j * D + m] - centroids[l * D + m];
              if(m == 0)
                sum += skew * diff * diff;
              else
                sum += (1.f - skew) * diff * diff;
						}
						
						if(sum < min_distance)
						{
							min_distance = sum;
							min_index[j] = l;
						}
					}
				}
			}
			mendA = mach_absolute_time();
			err = clEnqueueWriteBuffer(cmd_queue, min_index_mem, CL_TRUE, 0, min_index_size,
									   (void*)min_index, 0, NULL, NULL);
			assert(err == CL_SUCCESS);
			clFinish(cmd_queue);
		}
		else
		{
			mbegA = mach_absolute_time();
			executeCL(min_index, N, local_size, 0, k);
			mendA = mach_absolute_time();
		}
		
		//if(k * D < N / 10)
		if(TRUE)
		{
			mbegM = mach_absolute_time();
			#pragma omp parallel private(l, m, count)
			{
				#pragma omp for schedule(dynamic, MCHUNK_SIZE) nowait
				for(j = 0; j < k; j++)
				{
					count = 0;
					for(l = 0; l < D; l++)
						centroids[j * D + l] = 0.f;
					for(m = 0; m < N; m++)
						if(min_index[m] == j)
						{
							count++;
							for(l = 0; l < D; l++)
                //if(l == 0)
                  centroids[j * D + l] += curData[m * D + l];
                //else
                //  centroids[j * D + l] += (1.f - skew) * curData[m * D + l];
						}
					if(count != 0)
						for(l = 0; l < D; l++)
							centroids[j * D + l] /= count;
					else
						for(l = 0; l < D; l++)
							centroids[j * D + l] = curData[j * D + l];
				}
			}
			mendM = mach_absolute_time();
			err = clEnqueueWriteBuffer(cmd_queue, centroids_mem, CL_TRUE, 0, centroids_size,
									   (void*)centroids, 0, NULL, NULL);
			assert(err == CL_SUCCESS);
			clFinish(cmd_queue);
		}
		else
		{
			mbegM = mach_absolute_time();
			executeCL(NULL, k * D, local_size, 1, k);
			mendM = mach_absolute_time();
		}
		
		i++;
		
		//for(int i = 0; i < k * D; i++)
		//	printf("%1.3g ", centroids[i]);
		
		for(int i = 0; i < N; i += N / 20)
			printf("%d ", min_index[i]);
		printf("\t\t%1.3g\t%1.3g\n", machcore(mendA, mbegA), machcore(mendM, mbegM));
		sumA += machcore(mendA, mbegA);
		sumM += machcore(mendM, mbegM);
	}

	printf("Total:\t%1.3g\t%1.3g\n", sumA, sumM);
	
	clReleaseMemObject(centroids_mem);
	free(centroids);
	
	return min_index;
}

double machcore(uint64_t endTime, uint64_t startTime){
	
	uint64_t difference = endTime - startTime;
    static double conversion = 0.0;
	double value = 0.0;
	
    if( 0.0 == conversion )
    {
        mach_timebase_info_data_t info;
        kern_return_t err = mach_timebase_info( &info );
        
        if( 0 == err ){
			/* seconds */
            conversion = 1e-9 * (double) info.numer / (double) info.denom;
			/* nanoseconds */
			//conversion = (double) info.numer / (double) info.denom;
		}
    }
    
	value = conversion * (double) difference;
	
	return value;
}

char * load_program_source(const char *filename)
{ 
	
	struct stat statbuf;
	FILE *fh; 
	char *source; 
	
	fh = fopen(filename, "r");
	if (fh == 0)
		return 0; 
	
	stat(filename, &statbuf);
	source = (char *) malloc(statbuf.st_size + 1);
	fread(source, statbuf.st_size, 1, fh);
	source[statbuf.st_size] = '\0'; 
	
	return source; 
} 

#pragma mark -
#pragma mark Main OpenCL Routine
int setupCL()
{	
#pragma mark Device Information
	{
		// Find the CPU CL device, as a fallback
		err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_CPU, 1, &cpu, NULL);
		assert(err == CL_SUCCESS);
		
		// Find the GPU CL device, this is what we really want
		// If there is no GPU device is CL capable, fall back to CPU
		err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_GPU, 1, &device, NULL);
		if (err != CL_SUCCESS) device = cpu;
		//device = cpu; // Force CPU
		assert(device);
		
		// Get some information about the returned device
		cl_char vendor_name[1024] = {0};
		cl_char device_name[1024] = {0};
		cl_ulong max_mem_alloc_size;
		err = clGetDeviceInfo(device, CL_DEVICE_VENDOR, sizeof(vendor_name), 
							  vendor_name, &returned_size);
		err |= clGetDeviceInfo(device, CL_DEVICE_NAME, sizeof(device_name), 
							   device_name, &returned_size);
		err |= clGetDeviceInfo(device, CL_DEVICE_GLOBAL_MEM_SIZE, sizeof(max_mem_alloc_size), 
							   &max_mem_alloc_size, &returned_size);
		assert(err == CL_SUCCESS);
		//printf("Connecting to %s %s...\nWith %u max memory...\n", vendor_name, device_name, (uint) max_mem_alloc_size);
	}
	
#pragma mark Context and Command Queue
	{
		// Now create a context to perform our calculation with the 
		// specified device 
		context = clCreateContext(0, 1, &device, NULL, NULL, &err);
		assert(err == CL_SUCCESS);
		
		// And also a command queue for the context
		cmd_queue = clCreateCommandQueue(context, device, 0, NULL);
	}
	
#pragma mark Program and Kernel Creation
	{
		// Load the program source from disk
		// The kernel/program is the project directory and in Xcode the executable
		// is set to launch from that directory hence we use a relative path
		const char * filename1 = "assignment.cl";
		char *program_source1 = load_program_source(filename1);
		program[0] = clCreateProgramWithSource(context, 1, (const char**)&program_source1,
											   NULL, &err);
		assert(err == CL_SUCCESS);
		
		err = clBuildProgram(program[0], 0, NULL, NULL, NULL, NULL);
		assert(err == CL_SUCCESS);
		
		// Now create the kernel "objects" that we want to use in the example file 
		kernel[0] = clCreateKernel(program[0], "assignment", &err);
		
		const char * filename2 = "move.cl";
		char *program_source2 = load_program_source(filename2);
		program[1] = clCreateProgramWithSource(context, 1, (const char**)&program_source2,
											   NULL, &err);
		assert(err == CL_SUCCESS);
		
		err = clBuildProgram(program[1], 0, NULL, NULL, NULL, NULL);
		assert(err == CL_SUCCESS);
		
		// Now create the kernel "objects" that we want to use in the example file 
		kernel[1] = clCreateKernel(program[1], "move", &err);
	}
	
#pragma mark Memory Allocation
	{
		// Allocate memory on the device to hold our data and store the results into
		data_size = N * D * sizeof(float);
		min_index_size = N * sizeof(int);
		
		data_mem = clCreateBuffer(context, CL_MEM_READ_ONLY, data_size, NULL, NULL);
		err = clEnqueueWriteBuffer(cmd_queue, data_mem, CL_TRUE, 0, data_size,
								   (void*)data, 0, NULL, NULL);
		
		min_index_mem	= clCreateBuffer(context, CL_MEM_READ_WRITE, min_index_size, NULL, NULL);
		
		// Get all of the stuff written and allocated 
		assert(err == CL_SUCCESS);
		clFinish(cmd_queue);
	}
	
	return CL_SUCCESS;
}

int executeCL(void *return_value, int global_size, int local_size, int kern, int k)
{
	
#pragma mark Kernel Arguments
	{
		// Now setup the arguments to our kernel
		err  = clSetKernelArg(kernel[0],  0, sizeof(cl_mem), &data_mem);
		err |= clSetKernelArg(kernel[0],  1, sizeof(cl_mem), &centroids_mem);
		err |= clSetKernelArg(kernel[0],  2, sizeof(cl_mem), &min_index_mem);
		err |= clSetKernelArg(kernel[0],  3, local_size * D * sizeof(float), NULL);	
		err |= clSetKernelArg(kernel[0],  4, k * D * sizeof(float), NULL);	
		err |= clSetKernelArg(kernel[0],  5, sizeof(int), &D);
		err |= clSetKernelArg(kernel[0],  6, sizeof(int), &k);
		err |= clSetKernelArg(kernel[1],  0, sizeof(cl_mem), &data_mem);
		err |= clSetKernelArg(kernel[1],  1, sizeof(cl_mem), &centroids_mem);
		err |= clSetKernelArg(kernel[1],  2, sizeof(cl_mem), &min_index_mem);
		err |= clSetKernelArg(kernel[1],  3, sizeof(int), &D);
		err |= clSetKernelArg(kernel[1],  4, sizeof(int), &N);
		assert(err == CL_SUCCESS);
	}
#pragma mark Execution and Read
	{
		// Run the calculation by enqueuing it and forcing the 
		// command queue to complete the task
		size_t global_work_size = global_size;
		size_t local_work_size = local_size;
		err = clEnqueueNDRangeKernel(cmd_queue, kernel[kern], 1, NULL, 
									 &global_work_size, &local_work_size, 0, NULL, NULL);
		assert(err == CL_SUCCESS);
		clFinish(cmd_queue);
		
		// Once finished read back the results from the answer 
		// array into the results array
		if(kern == 0)
		{
			err = clEnqueueReadBuffer(cmd_queue, min_index_mem, CL_TRUE, 0, min_index_size, 
									  return_value, 0, NULL, NULL);
			assert(err == CL_SUCCESS);
		}
		/*
		 else
		 {
		 err = clEnqueueReadBuffer(cmd_queue, centroids_mem, CL_TRUE, 0, centroids_size, 
		 return_value, 0, NULL, NULL);
		 assert(err == CL_SUCCESS);
		 }
		 */
		
		clFinish(cmd_queue);
	}
	
	return CL_SUCCESS;
}

int teardownCL()
{
#pragma mark Teardown
	{
		clReleaseMemObject(data_mem);
		clReleaseMemObject(min_index_mem);
		
		clReleaseCommandQueue(cmd_queue);
		clReleaseContext(context);
	}
	return CL_SUCCESS;
}


@end
