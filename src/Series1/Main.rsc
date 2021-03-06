module Series1::Main

import IO;
import List;
import DateTime;
import util::Math;

import Series1::Volume;
import Series1::Duplication;
import Series1::UnitAnalysis;

list[str] intToRating 			= 	["++", "+", "o", "-", "--"];
list[int] duplicationBounds 		= 	[3, 5, 10, 20];
list[int] volumeBounds 			= 	[66000, 246000, 665000, 1310000];

list[list[int]] unitCCBounds		= [ [25, 0,  0],  // ++ 
									[30, 5,  0],  // +
									[40, 10, 0],  // o
									[50, 15, 5]]; // -

list[list[int]] unitSizeBounds	= [ [30, 5,  0 ],  // ++
									[35, 10, 0 ],  // +
									[45, 15, 5 ],  // o
									[55, 20, 10]]; // -

public void main () {
	loc project = |project://smallsql0.21_src|;
	//loc project = |project://hsqldb-2.3.1|;
	
	println("Starting analysis for <project> at <now()>");
	
	list[str] lines = getAllFilteredLines(project);
	
	int volume = size(lines);
	println("Lines of code: <volume>");
	
	analyseProject(project);
	list[int] unitSize 	= unitSize(volume);
	list[int] unitCC 	= unitComplexity(volume);
	
	int volumeRating = 4;
	for (i <- index(volumeBounds)) {
		if (volumeBounds[i] >= volume) {
			volumeRating = i;
			break;
		}
	}
	
	int dupResult = percent(duplicatedLines(lines), volume);
	
	int duplicationRating = 4;
	for (i <- index(duplicationBounds)) {
		if (duplicationBounds[i] >= dupResult) {
			duplicationRating = i;
			break;
		}
	}
	
	int unitSizeRating 	= mapRating(unitSize, unitSizeBounds);
	int unitCCRating 	= mapRating(unitCC, unitCCBounds);
	
	println("\n-------");
	println("Volume: \t\t" 			+ intToRating[volumeRating]);
	println("Unit Size: \t\t" 		+ intToRating[unitSizeRating]);
	println("Unit Complexity: \t" 	+ intToRating[unitCCRating]);
	println("Duplication: \t\t" 		+ intToRating[duplicationRating]);
	
	println("-------");
	println("Overall: \t" );
	println("Analysability: \t" 		+ intToRating[(volumeRating+duplicationRating+unitSizeRating)/3]);
	println("Changeability: \t" 		+ intToRating[(duplicationRating+unitCCRating)/2]);
	println("Stability: \tNo data");
	println("Testability: \t" 		+ intToRating[(unitSizeRating+unitCCRating)/2]);
	
	println("-------");
	println("Unit Size");
	println("Risk\t\t Relative LOC (%)");
	println("Low:\t\t <unitSize[0]>");
	println("Moderate:\t <unitSize[1]>");
	println("High:\t\t <unitSize[2]>");
	println("Very high:\t <unitSize[3]>");
	
	println("-------");
	println("Unit Complexity");
	println("Risk\t\t Relative LOC (%)");
	println("Low:\t\t <unitCC[0]>");
	println("Moderate:\t <unitCC[1]>");
	println("High:\t\t <unitCC[2]>");
	println("Very high:\t <unitCC[3]>");
	println("-------");
	
	println("\nAnalysis for <project> complete at <now()>");
}

public int mapRating (list[int] measurements, list[list[int]]bounds) {
	for (i <- index(bounds)){
		if (min([!(tail(measurements)[j] > bounds[i][j]) | j <- index(bounds[i])])) {
			return i;
		}
	}
	return size(intToRating)-1; // Minimal rating
}

