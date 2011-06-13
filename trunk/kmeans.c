/*
 *  kmeans.c
 *  Divvy
 *
 *  Created by Joshua Lewis on 6/13/11.
 *  A simple parallel k-means implementation.
 *  Possible improvements include using BLAS to calculate sample to centroid 
 *  distances, tracking whether centroids have moved instead of whether 
 *  assignments have changed (better when N >> D), and modifying the code to
 *  run in one large parallel region, instead of two inside the while loop.
 *
 */

#include "kmeans.h"

void kmeans(float *data, unsigned int n, unsigned int d, unsigned int k, int *assignment) {
  
  float *centroids = (float *)malloc(k * d * sizeof(float));
  int *assignment_changed = (int *)malloc(n * sizeof(int));
  
  float distance, min_distance;
  
  int sample_centroid;
  int num_assigned_points;
  int num_changed_points;
  int previous_assignment;
  int num_iterations = 0;
  int max_iterations = 10000;
  int i, j, l, m;
  
  for(i = 0; i < k; i++) {
    sample_centroid = rand() % n;
    for(j = 0; j < d; j++) {
      // Could double sample, but we check for orphan centroids
      centroids[i * d + j] = data[sample_centroid * d + j];
    }
  }

  while(num_iterations < max_iterations) {

#pragma omp parallel private(l, m, distance, min_distance, previous_assignment)
    {
#pragma omp for schedule(guided) nowait
      // Assign each point to the closest centroid.
      for(j = 0; j < n; j++)
      {
        min_distance = FLT_MAX;
        previous_assignment = assignment[j];
        
        for(l = 0; l < k; l++)
        {
          distance = 0.f;
          
          for(m = 0; m < d; m++)
            distance += (data[j * d + m] - centroids[l * d + m]) * (data[j * d + m] - centroids[l * d + m]);
          
          if(distance < min_distance)
          { 
            min_distance = distance;
            assignment[j] = l;
          }
        }
        
        if(assignment[j] == previous_assignment)
          assignment_changed[j] = 0;
        else
          assignment_changed[j] = 1;

      }
    }
        
    num_changed_points = 0;
    for (l = 0; l < n; l++) {
      num_changed_points += assignment_changed[l];
    }
    
    if(num_changed_points == 0)
      break;
                    
#pragma omp parallel private(l, m, num_assigned_points, sample_centroid)
    {
#pragma omp for schedule(guided) nowait
      // Move the centroids to the center of their assigned points.
      for(j = 0; j < k; j++)
      {
        num_assigned_points = 0;
        
        for(l = 0; l < d; l++)
          centroids[j * d + l] = 0.f;
        
        for(m = 0; m < n; m++)
          if(assignment[m] == j)
          {
            num_assigned_points++;
            for(l = 0; l < d; l++)
              centroids[j * d + l] += data[m * d + l];
          }
        
        if(num_assigned_points != 0)
          for(l = 0; l < d; l++)
            centroids[j * d + l] /= num_assigned_points;
        else {
          sample_centroid = rand() % n;
          for(l = 0; l < d; l++)
            centroids[j * d + l] = data[sample_centroid * d + l];
        }
      }
      
      num_iterations++;
      
    }
  }

  free(centroids);
  free(assignment_changed);
}