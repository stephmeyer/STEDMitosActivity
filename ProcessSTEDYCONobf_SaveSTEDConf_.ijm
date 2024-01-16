
/*
 * Macro to process multiple Mitos images in a folder
 * Input folder contains segmented STED images
 * Output folder will be where final data is saved
 * 
 */
//create folders for your output mitos images and masks, but not inside the folder where the images you need to process live
close("*");
#@ File (label = "Stable or Decon Folder", style = "directory") input1
#@ File (label = "Obf files Folder", style = "directory") input2
#@ File (label = "Conf 3D Folder", style = "directory") output1
#@ File (label = "STED 3D Folder", style = "directory") output2
#@ String (label = "File suffix", value = "_STED_stable.tif") suffix

processFolder(input1); 
// function to scan folders/subfolders/files to find files with correct suffix, then run processFile on each tif file
function processFolder(input1) {
	list = getFileList(input1);
	list = Array.sort(list);
	//Ask user if they want to save conf and/or sted 3D images (can add other options in the future)
	rows = 2;
  	columns = 1;
  	n = rows*columns;
  	labels = newArray(n);
  	defaults = newArray(n);
  	results = newArray(n);
  	labels[0] = "Confocal 3D";
  	labels[1] = "STED 3D";
  	defaults[0] = true;
  	defaults[1] = true;
  	Dialog.create("Images to Save?");
  	Dialog.addCheckboxGroup(rows,columns,labels,defaults);
  	Dialog.show();
  	results[0] = Dialog.getCheckbox();
  	results[1] = Dialog.getCheckbox();
	for (i = 0; i < list.length; i++) 
		//if(File.isDirectory(input1 + File.separator + list[i]))
			//processFolder(input1 + File.separator + list[i]);
		if(endsWith(list[i], suffix)) {
			filename = list[i].substring(0, lengthOf(list[i])-lengthOf(suffix));
			processFile(input2, output1, output2, suffix, filename, results);
	}
}
// IMG0009_Control_STED_stable.tif
// IMG0009_Control.obf
//"IMG0009_Control.obf - ATTO 647N.Confocal"
function processFile(input2, output1, output2, suffix, filename, results) {
	close("*");
	
	open(input2 + File.separator + filename + ".obf");
	wait(100);
	if(results[0] == true) {
		selectImage(filename + ".obf - ATTO 647N.Confocal");
		wait(100);
		saveAs("Tiff",output1+File.separator+filename+"_Confocal.tif");
		wait(100);
	}
	if(results[1]==true){
		selectImage(filename + ".obf - ATTO 647N.STED");
		saveAs("Tiff",output2+File.separator+filename+"_STED.tif");
		wait(100);
	}
	close(filename+"*");
	}