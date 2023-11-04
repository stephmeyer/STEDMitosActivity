/*
 * Macro to process multiple Mitos images in a folder with a trained Weka classifier
 * If input folder contains STED tiff images with 3 z planes, after deconvolution
 * Select middle plane, save in mitos folder and then process it
 * If one image plane, just process that
 * Use  output folder1 for the mitos images
 * Use output folder2 for masks
 * 
 */
//create folders for your output mitos images and masks, but not inside the folder where the images you need to process live
close("*");
#@ File (label = "Input Folder", style = "directory") input
#@ File (label = "Out Mitos Folder", style = "directory") output1
#@ File (label = "Out Mask Folder", style = "directory") output2
#@ File (label = "Classifier .model file", style = "file") classifier
#@ String (label = "File suffix", value = ".tif") suffix
#@ boolean (label = "z-stacks?", value =false) threedim


processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix, then run processFile on each tif file
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output1, output2, list[i], i);
	}
}


function processFile(input, output1, output2,file,i) {
	// If threedim=true, Open file, separate stack to images and save middle image to mitos folder
	// If threedim=false, just open the file
	filename = file.substring(0, file.lastIndexOf("."));
	print("Pre-processing stacks: " + filename);
	if (threedim==true){
		open(input + File.separator + file);
		run("Stack to Images");
		selectImage(filename+"-0002");
		wait(100);
		saveAs("Tiff",output1+File.separator+filename+".tif");
		wait(100);
		close(filename+"*");
		}

	wait(100);
	//If first iteration, open Weka and load classifier
	if (i==0){
		waitForUser("Select the new single plane image if z-stacks, or your first image if not, to open with Weka");
		run("Trainable Weka Segmentation");
		wait(3000);
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", classifier);
		wait(10000);
	}
	//if input folder contained z stacks, apply classifier to single plane tiff image saved
	//if input folder contained single plane images, apply classifier to input image
	if (threedim==true){
		call("trainableSegmentation.Weka_Segmentation.applyClassifier", output1, filename+".tif", "showResults=true", "storeResults=false", "probabilityMaps=false", "");
		print("Classifying: " + output1 + File.separator + filename);
	}
	else{
		call("trainableSegmentation.Weka_Segmentation.applyClassifier", input,filename+".tif", "showResults=true", "storeResults=false", "probabilityMaps=false", "");
		print("Classifying: " + input + File.separator + filename);
	}
	

	//test if done classifying image
	while(!isOpen("Classification result")){
		wait(5000);
	}
	wait(3000);
	//Fix mask so mitos are at high value, then save
	selectImage("Classification result");
	//Flip mask so Mitos are high and background is low
	wait(300);
	run("Calculator Plus", "i1=[Classification result] i2=[Classification result] operation=[Multiply: i2 = (i1*i2) x k1 + k2] k1=-1 k2=1 create");
	wait(300);
	selectImage("Classification result");
	close();
	selectImage("Result");
	//convert image to 8 bit binary and ensure no black padding of image
	run("Multiply...", "value=255.000");
	run("Grays");
	run("Options...", "iterations=1 count=1 black pad do=Nothing");
	print("Saving mask to: " + output2);
	saveAs("Tiff", output2 + File.separator + filename + "_mask.tif" );
	print("Mask saved for: " + filename);
	wait(200);
	//mulitply image by mask, convert to 16bit and then save
	imageCalculator("Multiply create 32-bit", filename+".tif", filename + "_mask.tif");
	selectImage("Result of "+filename+".tif");
	setOption("ScaleConversions", true);
	run("16-bit");
	print("Saving masked mitos image to : " + output1);
	wait(200);
	saveAs("Tiff", output1 + File.separator + filename +"_segmented.tif");
	wait(200);
	print("segmented mitos saved for: " + filename);
	close(filename+"*");
	print("Done with processing" + filename);
}
close("*");