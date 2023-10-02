/*
 * Macro to process multiple Mitos images in a folder
 * Input folder contains STED tiff images with 3 z planes, after deconvolution
 * Process only the middle plane of the tiff file
 * Use  output folder1 for the masks
 * 
 */
//create folders for your output mitos images and masks, but not inside the folder where the images you need to process live
close("*");
#@ File (label = "Input Folder", style = "directory") input
#@ File (label = "Out Mitos Folder", style = "directory") output1
#@ File (label = "Out Mask Folder", style = "directory") output2
#@ String (label = "File suffix", value = ".tif") suffix

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix, then run processFile on each tif file
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output1, output2, list[i]);
	}
}


function processFile(input, output1, output2,file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	open(input + File.separator + file);
	filename = file.substring(0, file.lastIndexOf("."));
	run("Stack to Images");
	selectImage(filename+"-0002");
	print("Processing: " + input + File.separator + filename);
	saveAs("Tiff",output1+File.separator+filename+"-2.tif");
	wait(1000);
	//if this is the first image we are processing, we need to open Weka and load the classifier
	run("Trainable Weka Segmentation");
	wait(3000);
	call("trainableSegmentation.Weka_Segmentation.loadClassifier", "/Users/Stephanie/Library/CloudStorage/OneDrive-TheUniversityofColoradoDenver/From Dropbox/STED/STED Data/230802/Classification/Glutamate_Image14_Traindata_classifier.model");
	wait(10000);
	call("trainableSegmentation.Weka_Segmentation.applyClassifier", output1,filename+"-2.tif", "showResults=true", "storeResults=false", "probabilityMaps=false", "");
	wait(30000);
	selectImage("Classification result");
	run("Calculator Plus", "i1=[Classification result] i2=[Classification result] operation=[Multiply: i2 = (i1*i2) x k1 + k2] k1=-1 k2=1 create");
	selectImage("Result");
	run("Multiply...", "value=255.000");
	run("Grays");
	run("Options...", "iterations=1 count=1 black pad do=Nothing");
	print("Saving mask to: " + output2);
	saveAs("Tiff", output2 + File.separator + filename + "_mask.tif" );
	imageCalculator("Multiply create 32-bit", filename+"-2.tif", filename + "_mask.tif");
	selectImage("Result of "+filename+"-2.tif");
	print("Saving masked mitos image to : " + output1);
	saveAs("Tiff", output1 + File.separator + filename +"_segmented.tif");
	close("*");
	
}