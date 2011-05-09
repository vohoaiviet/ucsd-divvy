//
//  DivvyOpenGLView.h
//  Divvy
//
//  Created by Joshua Lewis on 4/9/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <OpenGL/gl.h>
#include <math.h>

@interface DivvyOpenGLView : NSOpenGLView {
	float *data;
	unsigned int N;
	
	int *assignment;
	int *knn;
}

-(void)setData:(float *)newData setN:(int)newN;
-(void)setKNN:(int *)newKNN;
-(void)setAssignment:(int *)newAssignment;
-(void)drawRect:(NSRect)bounds;

@end