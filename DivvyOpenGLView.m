//
//  DivvyOpenGLView.m
//  Divvy
//
//  Created by Joshua Lewis on 4/9/10.
//  Copyright 2010 UCSD. All rights reserved.
//

#import "DivvyOpenGLView.h"
#include <OpenGL/gl.h>

@implementation DivvyOpenGLView
-(void)awakeFromNib {
}

-(void)setData:(float *)newData setN:(int)newN {
	data = newData;
	N = newN;
}

-(void)setAssignment:(int *)newAssignment {
	assignment = newAssignment;
}

-(void)setKNN:(int *)newKNN {
	if(knn != NULL)
		free(knn);
	knn = newKNN;
}

-(void) drawRect:(NSRect) bounds {
	int curAssignment;
	unsigned int D = 2;
	float kColor[] = {
		1.0f, 0.0f, 0.0f,
		0.0f, 1.0f, 0.0f,
		1.0f, 1.0f, 0.0f,
		0.0f, 0.0f, 1.0f,
		0.0f, 1.0f, 1.0f,
		1.0f, 0.0f, 1.0f,
		1.0f, 0.85f, 0.35f,
		0.85f, 1.0f, 0.35f,
		0.85f, 0.35f, 1.0f,
		1.0f, 0.35f, 0.85f,
		1.0f, 0.0f, 0.5f,
		1.0f, 0.5f, 0.0f,
		0.5f, 1.0f, 0.0f,
		0.5f, 0.0f, 1.0f,
		0.0f, 0.5f, 1.0f,
		0.0f, 1.0f, 0.5f,
		1.0f, 1.0f, 1.0f,
		0.5f, 0.5f, 0.5f,
		0.2f, 0.2f, 0.2f,
		0.8f, 0.8f, 0.8f};
	
	
	glClearColor(0, 0, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT);
	glViewport(0, 0, bounds.size.width, bounds.size.height);

	/*
	glBegin(GL_LINES);
	glColor3f(0.2f, 0.2f, 0.2f);
    for(int i = 0; i < N - 1; i++)
		for(int j = i + 1; j < N; j++)
			if(knn[j * (j - 1) / 2 + i] == 1)
			{
				glVertex2f(data[i * D], data[i * D + 1]);
				glVertex2f(data[j * D], data[j * D + 1]);
			}
    glEnd();
	 */
    
	glBegin(GL_POINTS);
	for(int i = 0; i < N; i++)
	{
		curAssignment = assignment[i];
		glColor3f(kColor[curAssignment * 3], 
				  kColor[curAssignment * 3 + 1], 
				  kColor[curAssignment * 3 + 2]);
		glVertex2f(data[i * D], data[i * D + 1]);
	}
    glEnd();
	
	glFlush();
}

@end

