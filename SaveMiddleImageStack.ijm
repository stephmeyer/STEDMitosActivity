/*
 * Macro to process multiple Mitos images in a folder
 * Input folder contains segmented STED images
 * Output folder will be where final data is saved
 * 
 */
//create folders for your output mitos images and masks, but not inside the folder where the images you need to process live
close("*");
#@ File (label = "3D Folder", style = "directory") input
#@ File (label = "output Folder", style = "directory") output
#@ String (label = "File suffix", value = "_stable.tif") suffix

processFolder(input);
// function to scan folders/subfolders/files to find files with correct suffix, then run processFile on each tif file
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output ,list[i]);
	}
}


function processFile(input, output, file) {
	close("*");
	open(input + File.separator + file);
	filename = file.substring(0, file.lastIndexOf("."));
	open(input + File.separator + file);
	run("Stack to Images");
	selectImage(filename+"-0002");
	wait(100);
	saveAs("Tiff",output+File.separator+filename+".tif");
	wait(100);
	close(filename+"*");
	}


}
