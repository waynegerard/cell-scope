//
//  DataInteractor.m
//  CellScope
//
//  Created by Wayne Gerard on 3/25/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import "DataInteractor.h"
#import "CSAppDelegate.h"

@implementation DataInteractor

+ (cv::Mat) loadCSVWithPath: (NSString*) path {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"csv"];
    NSString* fullBuffer = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvArray = [fullBuffer componentsSeparatedByString:@"\r"]; // Line endings
    int row = 0;
    int col = 0;
    
    int maxRows = [csvArray count];
    NSString* firstRow = [csvArray objectAtIndex:0];
    int maxCols = [[firstRow componentsSeparatedByString:@","] count];
    cv::Mat csvMat(maxRows, maxCols, CV_32F);
    
    for (int i = 0; i < [csvArray count]; i++) {
        NSString* items = [csvArray objectAtIndex:i];
        NSArray* splitRow = [items componentsSeparatedByString:@","];
        col = 0;
        for (int j = 0; j < [splitRow count]; j++) {
            NSString* item = [splitRow objectAtIndex:j];
            CSLog(@"Trying to add item %@", item);
            csvMat.at<float>(row, col) = [item floatValue];
            CSLog(@"Added item: %@", item);
            col++;
        }
        row++;
    }
    
    return csvMat;
}

+ (void) storeScores: (NSMutableArray*) scores withCentroids:(NSMutableArray*) centroids {
    CSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSManagedObject* newScoresAndCentroids;
    
    newScoresAndCentroids = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ScoresAndCentroids"
                             inManagedObjectContext:context];
    
    NSData* scoresData = [NSKeyedArchiver archivedDataWithRootObject:scores];
    NSData* centroidsData = [NSKeyedArchiver archivedDataWithRootObject:centroids];

    [newScoresAndCentroids setValue:scoresData forKey:@"scores"];
    [newScoresAndCentroids setValue:centroidsData forKey:@"centroids"];
    
    NSError *error;
    [context save:&error];
    CSLog(@"Saving down to core data, error: %@", error);
}

+ (NSString*) tknKeyHelper: (NSString*) str {
    return [[str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:0];
}


+ (NSString*) tknValHelper: (NSString*) str {
    return [[str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] objectAtIndex:1];
}

+ (int*) tknIntArrayHelper: (NSString*) str {
    NSArray* components = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int len = [components count] - 1;
    int* arr = new int[len * sizeof(int)];
    for (int i = 0; i < len; i++) {
        arr[i] = [[components objectAtIndex:i] intValue];
    }
    return arr;
}


+ (double*) tknDoubleArrayHelper: (NSString*) str {
    NSArray* components = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int len = [components count] - 1;
    double* arr = new double[len * sizeof(double)];
    for (int i = 0; i < len; i++) {
        arr[i] = [[components objectAtIndex:i] doubleValue];
    }
    return arr;
}

+ (svm_model) loadSVMModelWithPathName: (NSString*) fileName {
    
    svm_model* model = new svm_model();
	model->rho = NULL;
	model->probA = NULL;
	model->probB = NULL;
	model->label = NULL;
	model->nSV = NULL;
    svm_parameter& param = model->param;

    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString* fullBuffer = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray* allStrings = [fullBuffer componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    bool done = false;
    int index = 0;
    while (!done) {
        NSString* cmd = [self tknKeyHelper:[allStrings objectAtIndex:index]];
        if ([cmd isEqualToString:@"svm_type"]) {
            param.svm_type = 0;
        } else if ([cmd isEqualToString:@"kernel_type"]) {
            
        } else if ([cmd isEqualToString:@"nr_class"]) {
            model->nr_class = [[self tknValHelper:[allStrings objectAtIndex:index]] floatValue];
        } else if ([cmd isEqualToString:@"total_sv"]) {
            model->l = [[self tknValHelper:[allStrings objectAtIndex:3]] intValue];            
        } else if ([cmd isEqualToString:@"rho"]) {
            model->rho = [self tknDoubleArrayHelper:[allStrings objectAtIndex:4]];
        } else if ([cmd isEqualToString:@"label"]) {
            model->label = [self tknIntArrayHelper:[allStrings objectAtIndex:5]];
        } else if ([cmd isEqualToString:@"probA"]) {
            model->probA = new double([[self tknValHelper:[allStrings objectAtIndex:6]] doubleValue]);
        } else if ([cmd isEqualToString:@"probB"]) {
            model->probB = new double([[self tknValHelper:[allStrings objectAtIndex:7]] doubleValue]);
        } else if ([cmd isEqualToString:@"nr_sv"]) {
            model->nSV = [self tknIntArrayHelper:[allStrings objectAtIndex:8]];
        } else if ([cmd isEqualToString:@"SV"]) {
            done = true;
        }
    }
    [allStrings objectAtIndex:1]; // Kernel Type
    
    
    /**
    svm_type c_svc   X
    kernel_type (null)
    nr_class 2    X
    total_sv 1654   X
    rho 3.17932
    label 1 0
    probA -3.17405   X
    probB -0.0287109   X
    nr_sv 826 828
    SV
     */
    
    
    
	// read sv_coef and SV
	int elements = 0;
    
	long pos = ftell(fp);
    
	max_line_len = 1024;
	line = Malloc(char,max_line_len);
	char *p,*endptr,*idx,*val;
    
	while(readline(fp)!=NULL)
	{
		p = strtok(line,":");
		while(1)
		{
			p = strtok(NULL,":");
			if(p == NULL)
				break;
			++elements;
		}
	}
	elements += model->l;
    
	fseek(fp,pos,SEEK_SET);
    
	int m = model->nr_class - 1;
	int l = model->l;
	model->sv_coef = Malloc(double *,m);
	int i;
	for(i=0;i<m;i++)
		model->sv_coef[i] = Malloc(double,l);
	model->SV = Malloc(svm_node*,l);
	svm_node *x_space = NULL;
	if(l>0) x_space = Malloc(svm_node,elements);
    
	int j=0;
	for(i=0;i<l;i++)
	{
		readline(fp);
		model->SV[i] = &x_space[j];
        
		p = strtok(line, " \t");
		model->sv_coef[0][i] = strtod(p,&endptr);
		for(int k=1;k<m;k++)
		{
			p = strtok(NULL, " \t");
			model->sv_coef[k][i] = strtod(p,&endptr);
		}
        
		while(1)
		{
			idx = strtok(NULL, ":");
			val = strtok(NULL, " \t");
            
			if(val == NULL)
				break;
			x_space[j].index = (int) strtol(idx,&endptr,10);
			x_space[j].value = strtod(val,&endptr);
            
			++j;
		}
		x_space[j++].index = -1;
	}
	free(line);
    
	setlocale(LC_ALL, old_locale);
	free(old_locale);
    
	if (ferror(fp) != 0 || fclose(fp) != 0)
		return NULL;
    
	model->free_sv = 1;	// XXX
	return model;
    
    svm_model model = svm_load_model(fileName);
}

@end
