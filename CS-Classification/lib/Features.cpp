#include "Features.h"

namespace Features 
{

	Mat geometricFeatures(Mat* binPatch)  
	{
		Mat geometricFeatures = Mat(14, 1, CV_8UC3);

		ContourContainerType contours;
		cv::vector<Vec4i> hierarchy;

		findContours(*binPatch, contours, hierarchy, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
		if (contours.size() == 0) {
			return cv::Mat::zeros(14, 1, CV_8UC3);
		}
    
		std::map<const char*, float> regionProperties = Region::getProperties(contours, *binPatch);
		
		NSArray* keys = [NSArray arrayWithObjects:@"area", @"convexArea", @"eccentricity",
						 @"equivDiameter", @"extent", @"filledArea", @"minorAxisLength",
						 @"majorAxisLength", @"maxIntensity", @"minIntensity", @"meanIntensity",
						 @"perimeter", @"solidity", @"eulerNumber", nil];

		for (int i = 0; i < keys.count; i++) {
			geometricFeatures.at<float>(0, i) = [[regionProperties valueForKey:[keys objectAtIndex:i]] floatValue];
		}
    
    
		return geometricFeatures;    
	}

	bool checkPartialPatch(int row, int col, int patchSize, int maxRow, int maxCol)
	{
		bool partial = false;
    
		// Lower bounds checking
		int lowerC = col - patchSize / 2;
		int lowerR = row - patchSize / 2;
		if (lowerC <= 0 || lowerR <= 0) {
			partial = true;
		}
    
		// Higher bounds checking
		int higherC = (col + (patchSize / 2 - 1));
		int higherR = (row + (patchSize / 2 - 1));
    
		if ((higherC > maxCol) || (higherR  > maxRow)) {
			partial = true;
		}

		return partial;
	}

	Patch* makePatch(int row, int col, int patchSize, Mat original) 
	{
		// Indices in matlab are 1 based
		int row_start = (row - patchSize / 2) - 1;
		int row_end = row + (patchSize / 2 - 1) - 1;
		int col_start = col - patchSize / 2 - 1;
		int col_end = col + (patchSize / 2 - 1) - 1;
		Range rows = Range(row_start, row_end);
		Range cols = Range(col_start, col_end);
    
		Mat patchMatrix = original.operator()(rows, cols);
		Patch* patch = new Patch(row, col, patchMatrix);
    
		return patch;
	}


	+ (NSMutableArray*) calculateFeatures: (NSMutableArray*) blobs {

		NSMutableArray* newBlobs = [NSMutableArray array];
		for (int i = 0; i < [blobs count]; i++) {
			NSMutableDictionary* stats = [blobs objectAtIndex:i];
			Mat* patch = (__bridge Mat*) [stats valueForKey:@"patch"];
        
			// Calculate the hu moments
			Moments m = cv::moments(*patch);
			Mat huMoments;
			HuMoments(m, huMoments);
        
			// Grab the geometric features and return
			Mat* binPatch = (__bridge Mat*) [stats valueForKey:@"binpatch"];
			Mat geometricFeatures = [self geometricFeaturesWithPatch:patch withBinPatch:binPatch];
			id huPtr = [NSValue valueWithPointer:(Mat*)&huMoments];
			id geomPtr = [NSValue valueWithPointer:(Mat*)&geometricFeatures];
			[stats setValue:huPtr forKey: @"phi"];
			[stats setValue:geomPtr forKey:@"geom"];
			[newBlobs addObject:stats];
		}
		return newBlobs;



		- (NSMutableDictionary*) storeGoodCentroidsWithRow:(int) row withCol:(int) col {
    
		NSMutableDictionary* stats = [NSMutableDictionary dictionary];
    
		/////////////////////////////////
		// Patch Completeness Checking //
		/////////////////////////////////
		bool partial = NO;
    
		// Lower bounds checking
		int lowerC = col - self.patchSize / 2;
		int lowerR = row - self.patchSize / 2;
		if (lowerC <= 0 || lowerR <= 0) {
			partial = YES;
		}
    
		// Higher bounds checking
		int higherC = (col + (self.patchSize / 2 - 1));
		int higherR = (row + (self.patchSize / 2 - 1));
    
		if ((higherC > self.orig.cols) || (higherR  > self.orig.rows)) {
			partial = YES;
		}
    
		if (partial) {
			return NULL;
		}
    
		//////////////////////////
		// Store good centroids //
		//////////////////////////
    
		[stats setValue:[NSNumber numberWithInt:col] forKey:@"col"];
		[stats setValue:[NSNumber numberWithInt:row] forKey:@"row"];
    
		// Indices in matlab are 1 based
		int row_start = (row - self.patchSize / 2) - 1;
		int row_end = row + (self.patchSize / 2 - 1) - 1;
		int col_start = col - self.patchSize / 2 - 1;
		int col_end = col + (self.patchSize / 2 - 1) - 1;
		Range rows = Range(row_start, row_end);
		Range cols = Range(col_start, col_end);
    
		Mat _patch = self.orig.operator()(rows, cols);
		id patch = [MatrixOperations convertMatToObject:_patch];
		[stats setValue:patch forKey: @"patch"];
    
		return stats;
	}
}